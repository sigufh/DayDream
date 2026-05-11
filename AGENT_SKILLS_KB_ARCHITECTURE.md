# Daydream 技术架构说明

本文档只覆盖以下四部分：
- 大模型调用层
- Agent 编排层
- Skills 运行时
- 本地知识库 / RAG 层

不包含 UI、导航、视觉设计、普通业务页面说明。

## 1. 总体架构

当前应用的智能能力可以分成四层：

1. 模型层
   统一通过 `DashScopeClient` 调用外部大模型能力，包括文本生成与图像生成。

2. Agent 编排层
   由 `AgentOrchestrator` 负责问题分类、技能选择、工具选择、上下文拼装、最终回答合成。

3. Skills 层
   将应用内部的“风格能力”“检索能力”“解释能力”“行动建议能力”标准化为可注册、可选择、可执行的 skill。

4. 知识库 / RAG 层
   使用本地向量化文档存储梦境记忆和塔罗规则，提供检索增强上下文。

对应主要文件：
- [daydream/Core/Network/DashScopeClient.swift](/Users/sigufh/daydream/daydream/Core/Network/DashScopeClient.swift:1)
- [daydream/Core/Agent/AgentOrchestrator.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentOrchestrator.swift:1)
- [daydream/Core/Agent/AgentTools.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentTools.swift:1)
- [daydream/Core/Agent/AgentResponseTemplate.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentResponseTemplate.swift:1)
- [daydream/Core/Skills/SkillRuntime.swift](/Users/sigufh/daydream/daydream/Core/Skills/SkillRuntime.swift:1)
- [daydream/Core/Skills/AgentSkills.swift](/Users/sigufh/daydream/daydream/Core/Skills/AgentSkills.swift:1)
- [daydream/Core/RAG/KnowledgeStore.swift](/Users/sigufh/daydream/daydream/Core/RAG/KnowledgeStore.swift:1)

---

## 2. 大模型调用层

### 2.1 DashScopeClient

统一模型入口是 `DashScopeClient`：
- `chat(system:userMessage:maxTokens:)`
- `generateImage(prompt:negativePrompt:size:)`

实现位置：
- [daydream/Core/Network/DashScopeClient.swift](/Users/sigufh/daydream/daydream/Core/Network/DashScopeClient.swift:3)

关键点：
- 使用 `actor` 保证并发安全。
- 文本模型当前走 DashScope 兼容接口。
- `chat` 默认模型为 `qwen-flash`。
- 图像生成根据用户配置切换不同模型实现。
- 请求超时、HTTP 状态码、JSON 解析都在客户端层统一处理。

### 2.2 模型在应用中的使用方式

当前模型调用分成三类：

1. 梦境内容生成
   由 `AIService` 调用，用于诗歌、反思问题、世界名、图像生成。
   文件：
   [daydream/Core/Network/AIService.swift](/Users/sigufh/daydream/daydream/Core/Network/AIService.swift:4)

2. 专项解读
   例如塔罗解读、六爻解释等，分别在对应 service 中直接调用 `DashScopeClient`。
   文件示例：
   [daydream/Core/Network/TarotService.swift](/Users/sigufh/daydream/daydream/Core/Network/TarotService.swift:5)

3. Agent 最终回答合成
   Agent 不直接把用户问题扔给模型，而是先跑工具和 skills，再把结构化上下文交给模型做最后整合。
   文件：
   [daydream/Core/Agent/AgentOrchestrator.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentOrchestrator.swift:168)

### 2.3 模型层的设计原则

- 模型只负责生成，不负责应用状态编排。
- 检索、工具调用、问题分类优先在本地完成。
- 当模型不可用时，系统保留 fallback 路径。
- Agent 结构化问题场景下，本地先产出草稿，再让模型润色，防止模型漏掉关键段落。

---

## 3. Agent 编排层

### 3.1 核心对象

Agent 主入口是 `AgentOrchestrator`：
- [daydream/Core/Agent/AgentOrchestrator.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentOrchestrator.swift:25)

核心输出结构：
- `AgentResponse`
- `AgentReference`
- `AgentToolExecutionRecord`
- `SkillExecutionRecord`

其中 `AgentResponse` 包含：
- `content`：最终正文
- `consultedExperts`：命中的 skills 名称
- `references`：引用区素材
- `executionTrace`：skill 调用轨迹
- `toolTrace`：tool 调用轨迹

### 3.2 Agent 执行流程

`respond(userInput:dreams:divinations:)` 的逻辑可以概括为：

1. 初始化塔罗知识索引
2. 根据用户输入做问题分类
3. 根据问题分类决定 route
4. 根据问题分类决定 toolPlan
5. 先执行工具
6. 再执行检索类 skills
7. 基于前序结果执行解释类 skill
8. 再执行行动建议 skill
9. 汇总 references
10. 生成结构化草稿
11. 如有 API Key，则调用大模型做最终整合
12. 如果模型输出不满足模板约束，则回退到本地草稿

### 3.3 问题分类

问题分类由 `AgentTemplateRegistry.questionType(for:)` 完成：
- [daydream/Core/Agent/AgentResponseTemplate.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentResponseTemplate.swift:23)

当前类型：
- `explicitDreamReading`
- `tarotReflection`
- `contextualReflection`
- `generalGuidance`

附带一组辅助判断：
- `hasDreamReadingIntent`
- `hasTarotKnowledgeIntent`
- `hasContextualIntent`
- `requestsTarotDraw`
- `requiresFormalTarotDraw`

这使 agent 可以先在本地确定问题路径，而不是把分类任务交给大模型。

### 3.4 Route 与 Tool Plan

Agent 有两层决策：

1. `route(for:)`
   决定是否启用：
   - 梦境记忆 skill
   - 塔罗知识 skill
   - 行动建议 skill

2. `toolPlan(for:)`
   决定是否调用：
   - 梦境记忆查询
   - 塔罗规则查询
   - 时令节气上下文
   - 天气地点上下文
   - 抽牌工具

相关代码：
- [daydream/Core/Agent/AgentOrchestrator.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentOrchestrator.swift:229)
- [daydream/Core/Agent/AgentOrchestrator.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentOrchestrator.swift:357)

当前设计重点：
- 解梦问题默认携带梦境记忆、塔罗、天气地点、时令节气作为参考。
- 正式抽牌问题优先走应用现有塔罗流程，而不是简单后台预览。
- “天气 / 地点 / 时令”不只是显式问到才调用，在解梦场景里本身就是参考变量。

### 3.5 最终回答合成

Agent 最终回答不是单步生成，而是“两阶段合成”：

1. 本地生成结构化草稿
   调用 `composeFallback(...)` / `AgentTemplateRegistry.renderFallback(...)`

2. 模型润色
   如果命中结构化模板，则强制模型保留所有 section 标题。

3. 结果校验
   使用 `matchesRequiredSections` 检查模型输出。
   如果缺失必需 section，则直接退回本地草稿。

相关代码：
- [daydream/Core/Agent/AgentOrchestrator.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentOrchestrator.swift:144)
- [daydream/Core/Agent/AgentResponseTemplate.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentResponseTemplate.swift:236)

这套设计的目标不是追求“最自由的生成”，而是优先保证稳定性和可控性。

---

## 4. Skills 运行时

### 4.1 Skills 的定位

这里的 skill 不是单纯 prompt 标签，而是标准化的本地能力单元，具有：
- 定义
- 能力枚举
- 输入上下文
- 输出结果
- 可注册性
- 可选择性

核心结构位于：
- [daydream/Core/Skills/SkillRuntime.swift](/Users/sigufh/daydream/daydream/Core/Skills/SkillRuntime.swift:1)
- [daydream/Core/Skills/AgentSkills.swift](/Users/sigufh/daydream/daydream/Core/Skills/AgentSkills.swift:1)

### 4.2 核心协议与数据结构

#### SkillDefinition

定义一个 skill 的元数据：
- `id`
- `displayName`
- `description`
- `category`
- `capabilities`

#### SkillContext

skill 执行时的统一上下文：
- `userInput`
- `dreams`
- `divinations`
- `preferredStyleSkillID`
- `priorResults`

这里的 `priorResults` 很关键，它允许后续 skill 消费前面 skill 或 tool 的结果，形成链式执行。

#### AppSkill

最基础的 skill 协议：
- `var definition: SkillDefinition`
- `func execute(with context: SkillContext) async -> SkillResult`

#### AgentRunnableSkill

用于 agent 选择器的扩展 skill 协议：
- 在 `AppSkill` 基础上增加 `descriptor`

#### SkillDescriptor

定义一个可执行 skill 的额外信息：
- `inputSchema`
- `outputSchema`
- `keywords`

它主要服务于 agent 的本地选择器。

### 4.3 Skill 分类

当前 skill 分类：
- `styleProfile`
- `retrieval`
- `interpretation`
- `guidance`

当前 capability：
- `stylePrompting`
- `dreamRetrieval`
- `tarotRetrieval`
- `dreamInterpretation`
- `actionGuidance`

### 4.4 Style Skill

当前“艺术风格”已经被重构成 `StyleSkillProfile`，不再只是简单枚举。

结构：
- `definition`
- `payload`

其中 `payload` 包含：
- `legacyArtStyle`
- `icon`
- `poemStyleGuide`
- `imagePromptGuide`
- `agentInterpretationGuide`
- `negativePromptGuide`

这意味着同一个风格 skill 可以同时影响：
- 梦境诗歌生成
- 图像 prompt 生成
- agent 解读语气

对应代码：
- [daydream/Core/Skills/SkillRuntime.swift](/Users/sigufh/daydream/daydream/Core/Skills/SkillRuntime.swift:55)

### 4.5 Agent Skills

当前 agent 可运行 skill 包括：

1. `DreamRetrievalSkill`
   从本地梦境记忆中召回相近梦境。

2. `TarotRetrievalSkill`
   从本地塔罗规则库中召回牌义和牌阵规则。

3. `DreamInterpretationSkill`
   汇总当前梦、最近占卜、梦境检索结果、塔罗检索结果，生成解释摘要。

4. `ActionGuidanceSkill`
   把解释整理成可执行建议，并消费塔罗、时令、天气地点等上下文。

实现位置：
- [daydream/Core/Skills/AgentSkills.swift](/Users/sigufh/daydream/daydream/Core/Skills/AgentSkills.swift:52)

### 4.6 Skill 注册与选择

`SkillRegistry` 负责：
- 保存所有内置 style skills
- 保存所有已注册 skills
- 保存 agent 可执行 skills
- 按 capability 查询 definitions / skills

Agent 的 skill 选择逻辑在 `AgentOrchestrator.selectBestSkill(...)`：
- 基于 `descriptor.keywords`
- 同时参考原始输入和切词后的 intent keywords
- 按分数排序，选最优 skill

这是一个轻量本地选择器，不依赖模型完成 tool/skill routing。

---

## 5. Agent Tools

虽然你只要求写 agent、skills、知识库相关内容，但这里需要单独说明 tools，因为当前 agent 不是“只有 prompt 和 skill”，而是 skill + tool 混合编排。

核心文件：
- [daydream/Core/Agent/AgentTools.swift](/Users/sigufh/daydream/daydream/Core/Agent/AgentTools.swift:1)

### 5.1 Tool 的定位

tool 与 skill 的区别：

- skill 更偏“抽象能力单元”，输出的是面向后续 reasoning 的摘要结果。
- tool 更偏“直接访问某种数据源或环境能力”，例如查天气、查地点、查知识、读取正式抽牌结果。

### 5.2 当前工具

1. `DreamMemoryLookupTool`
   检索本地梦境记忆。

2. `TarotKnowledgeLookupTool`
   检索塔罗规则知识库。

3. `SeasonalContextTool`
   生成当前日期、节气、季节语境。

4. `EnvironmentContextTool`
   获取天气和地点。

5. `TarotDrawTool`
   优先复用正式塔罗记录。
   若当前没有正式塔罗结果，才退回到简化预览抽牌。

### 5.3 Tool 的输出标准

工具输出统一为 `AgentToolResult`：
- `toolID`
- `title`
- `content`
- `references`
- `metadata`

这使工具结果可以：
- 直接参与最终回答
- 被转写成 `SkillResult` 注入后续 skill 上下文
- 展示到调用轨迹和引用区

---

## 6. 本地知识库 / RAG 架构

### 6.1 设计目标

当前知识库不是外部向量数据库，也不是在线 embedding 服务，而是本地轻量 RAG：
- 离线可用
- 数据可落地
- 对移动端友好
- 足够支持梦境和塔罗两类检索增强

实现文件：
- [daydream/Core/RAG/KnowledgeStore.swift](/Users/sigufh/daydream/daydream/Core/RAG/KnowledgeStore.swift:1)

### 6.2 文档结构

知识库基本单元是 `KnowledgeDocument`：
- `id`
- `source`
- `title`
- `content`
- `metadata`
- `vector`
- `updatedAt`

数据源目前有两类：
- `dreamMemory`
- `tarotRule`

### 6.3 Embedding 实现

当前并没有使用远程 embedding API，而是本地 `HashedEmbeddingProvider`：
- 向量维度固定为 192
- 对文本做轻量 tokenization
- 对 token 做稳定哈希
- 用 hash bucket + sign 构造稀疏向量
- 最后做归一化

优点：
- 无需联网
- 无额外模型依赖
- 可在移动端快速运行

缺点：
- 精度不如真实语义 embedding
- 更偏词面近似和局部符号召回

这是一种工程取舍：先保证本地可用性和稳定性。

### 6.4 向量存储

本地存储由 `LocalVectorStore` 管理：
- 使用 JSON 编码写入磁盘
- 优先写 App Group 容器
- 否则退回 `Application Support/RAG/`

主要方法：
- `replaceDocuments`
- `loadDocuments`
- `search`

搜索逻辑：
- 将 query 向量化
- 逐文档计算余弦相似度
- 过滤低分结果
- 排序后返回 `topK`

### 6.5 梦境记忆索引

`DreamMemoryIndexer` 负责梦境 RAG：
- 输入源是本地 `Dream` 列表
- 检索前先同步最新 dreams
- 每条 dream 被转换成一个 `KnowledgeDocument`

文档内容会聚合：
- `transcript`
- `poem`
- `symbols`
- `worldName`
- `reflectionQuestion`
- `locationName`
- `weatherDescription`
- `diary`
- `emotion`

这说明梦境知识库不是只存转录文本，而是存“梦的复合语义表示”。

### 6.6 塔罗知识索引

`TarotKnowledgeIndexer` 负责塔罗规则库：
- 首次检索前调用 `ensureIndexed()`
- 如果本地已有索引则直接复用
- 否则从 `TarotService` 的静态牌组和牌阵定义构建文档

当前索引内容包含：
- 全部塔罗牌
- 全部牌阵

每个牌文档包含：
- 中英文牌名
- 牌组
- 正位含义
- 逆位含义
- 关键词

每个牌阵文档包含：
- 牌阵名
- 各位置含义
- 适用说明

---

## 7. 端到端数据流

下面以“解读今天的梦”为例说明端到端链路：

1. 用户在 Agent 页输入问题
2. 本地判断问题是否需要正式塔罗抽牌
3. 若需要，则先完成正式抽牌并生成新的 `Divination`
4. `AgentOrchestrator.respond(...)` 启动
5. 分类问题类型
6. 生成 route 和 toolPlan
7. 调用梦境记忆 / 塔罗规则 / 时令节气 / 天气地点 / 抽牌结果等工具
8. 调用 `DreamRetrievalSkill` / `TarotRetrievalSkill`
9. 用前序结果执行 `DreamInterpretationSkill`
10. 用前序结果和工具结果执行 `ActionGuidanceSkill`
11. 依据 `AgentResponseTemplate` 组装结构化草稿
12. 调用大模型润色
13. 校验段落结构是否完整
14. 返回 `AgentResponse`

这个流程的核心思想是：
- 先本地编排
- 再模型表达
- 本地对最终结构兜底

---

## 8. 当前架构特点与取舍

### 优点

- 本地可控，分类、技能选择、工具选择不依赖大模型。
- RAG 可离线工作，适合移动端。
- 艺术风格已标准化为 skill，而不是零散配置。
- Agent 输出可追踪，具备 skill trace 和 tool trace。
- 正式塔罗流程已经和 agent 打通，不再是两套割裂实现。

### 当前限制

- 本地 hashed embedding 精度有限，不等于真正语义向量。
- skill / tool 选择器目前仍是关键词打分，不是更强的策略路由器。
- 最终回答整合仍依赖单次 LLM 合成，复杂场景下表达稳定性受模型影响。
- tools 与 skills 目前是代码注册，不是声明式插件系统。

### 后续可演进方向

- 用更标准的声明式 skill / tool manifest 替代部分硬编码注册。
- 引入更强的本地或远程 embedding，提高检索质量。
- 将 route / template / toolPlan 进一步配置化。
- 给 agent 增加多步计划与中间状态机，而不只是单轮编排。

---

## 9. 结论

当前 Daydream 的智能架构不是“一个大模型直接回答所有问题”，而是：

- 大模型负责生成与表达
- agent 负责本地编排
- skills 负责标准化能力封装
- 本地知识库负责检索增强

这套设计更适合梦境解读类应用，因为它同时需要：
- 用户个人历史记忆
- 符号规则知识
- 现实环境上下文
- 风格化表达
- 受控的最终输出结构

从工程上看，当前架构已经具备一个轻量移动端 agent 应用的核心形态。
