import SwiftUI

struct SolarTerm: Identifiable {
    let id: String
    let chineseName: String
    let englishName: String
    let month: Int
    let day: Int
    let season: Season
    let poem: String
    let colors: [Color]

    var date: String {
        "\(month)/\(day)"
    }

    static let allTerms: [SolarTerm] = [
        SolarTerm(id: "lichun", chineseName: "立春", englishName: "Start of Spring", month: 2, day: 4, season: .spring,
                  poem: "东风解冻，蛰虫始振", colors: [Color(hex: "C8E6C9"), Color(hex: "81C784")]),
        SolarTerm(id: "yushui", chineseName: "雨水", englishName: "Rain Water", month: 2, day: 19, season: .spring,
                  poem: "好雨知时节，润物细无声", colors: [Color(hex: "B2DFDB"), Color(hex: "80CBC4")]),
        SolarTerm(id: "jingzhe", chineseName: "惊蛰", englishName: "Awakening of Insects", month: 3, day: 6, season: .spring,
                  poem: "春雷惊百虫，万物始更新", colors: [Color(hex: "A5D6A7"), Color(hex: "66BB6A")]),
        SolarTerm(id: "chunfen", chineseName: "春分", englishName: "Spring Equinox", month: 3, day: 21, season: .spring,
                  poem: "日夜均分，花开满径", colors: [Color(hex: "F8BBD0"), Color(hex: "F48FB1")]),
        SolarTerm(id: "qingming", chineseName: "清明", englishName: "Clear and Bright", month: 4, day: 5, season: .spring,
                  poem: "清明时节雨纷纷，路上行人欲断魂", colors: [Color(hex: "C5E1A5"), Color(hex: "AED581")]),
        SolarTerm(id: "guyu", chineseName: "谷雨", englishName: "Grain Rain", month: 4, day: 20, season: .spring,
                  poem: "谷雨催百谷，春深花事浓", colors: [Color(hex: "DCEDC8"), Color(hex: "C5E1A5")]),

        SolarTerm(id: "lixia", chineseName: "立夏", englishName: "Start of Summer", month: 5, day: 6, season: .summer,
                  poem: "绿树阴浓夏日长", colors: [Color(hex: "B9F6CA"), Color(hex: "69F0AE")]),
        SolarTerm(id: "xiaoman", chineseName: "小满", englishName: "Grain Buds", month: 5, day: 21, season: .summer,
                  poem: "小满麦渐黄，夏意初上场", colors: [Color(hex: "FFF9C4"), Color(hex: "FFF176")]),
        SolarTerm(id: "mangzhong", chineseName: "芒种", englishName: "Grain in Ear", month: 6, day: 6, season: .summer,
                  poem: "芒种忙忙割，农家乐未央", colors: [Color(hex: "FFE082"), Color(hex: "FFD54F")]),
        SolarTerm(id: "xiazhi", chineseName: "夏至", englishName: "Summer Solstice", month: 6, day: 21, season: .summer,
                  poem: "日长之至，蝉鸣初起", colors: [Color(hex: "FFCC80"), Color(hex: "FFB74D")]),
        SolarTerm(id: "xiaoshu", chineseName: "小暑", englishName: "Minor Heat", month: 7, day: 7, season: .summer,
                  poem: "倏忽温风至，因循小暑来", colors: [Color(hex: "FFAB91"), Color(hex: "FF8A65")]),
        SolarTerm(id: "dashu", chineseName: "大暑", englishName: "Major Heat", month: 7, day: 23, season: .summer,
                  poem: "赤日几时过，清风无处寻", colors: [Color(hex: "FF8A80"), Color(hex: "FF5252")]),

        SolarTerm(id: "liqiu", chineseName: "立秋", englishName: "Start of Autumn", month: 8, day: 7, season: .autumn,
                  poem: "秋风起兮白云飞", colors: [Color(hex: "FFE0B2"), Color(hex: "FFCC80")]),
        SolarTerm(id: "chushu", chineseName: "处暑", englishName: "End of Heat", month: 8, day: 23, season: .autumn,
                  poem: "离离暑云散，袅袅凉风起", colors: [Color(hex: "FFCCBC"), Color(hex: "FFAB91")]),
        SolarTerm(id: "bailu", chineseName: "白露", englishName: "White Dew", month: 9, day: 8, season: .autumn,
                  poem: "蒹葭苍苍，白露为霜", colors: [Color(hex: "D7CCC8"), Color(hex: "BCAAA4")]),
        SolarTerm(id: "qiufen", chineseName: "秋分", englishName: "Autumn Equinox", month: 9, day: 23, season: .autumn,
                  poem: "金风玉露一相逢", colors: [Color(hex: "FFE082"), Color(hex: "FFC107")]),
        SolarTerm(id: "hanlu", chineseName: "寒露", englishName: "Cold Dew", month: 10, day: 8, season: .autumn,
                  poem: "袅袅凉风动，凄凄寒露零", colors: [Color(hex: "D7CCC8"), Color(hex: "A1887F")]),
        SolarTerm(id: "shuangjian", chineseName: "霜降", englishName: "Frost's Descent", month: 10, day: 23, season: .autumn,
                  poem: "霜降水返壑，风落木归山", colors: [Color(hex: "EFEBE9"), Color(hex: "D7CCC8")]),

        SolarTerm(id: "lidong", chineseName: "立冬", englishName: "Start of Winter", month: 11, day: 7, season: .winter,
                  poem: "北风潜入悄无声", colors: [Color(hex: "CFD8DC"), Color(hex: "B0BEC5")]),
        SolarTerm(id: "xiaoxue", chineseName: "小雪", englishName: "Minor Snow", month: 11, day: 22, season: .winter,
                  poem: "小雪初晴应节气", colors: [Color(hex: "E0E0E0"), Color(hex: "BDBDBD")]),
        SolarTerm(id: "daxue", chineseName: "大雪", englishName: "Major Snow", month: 12, day: 7, season: .winter,
                  poem: "千山鸟飞绝，万径人踪灭", colors: [Color(hex: "ECEFF1"), Color(hex: "CFD8DC")]),
        SolarTerm(id: "dongzhi", chineseName: "冬至", englishName: "Winter Solstice", month: 12, day: 22, season: .winter,
                  poem: "冬至阳生春又来", colors: [Color(hex: "C5CAE9"), Color(hex: "9FA8DA")]),
        SolarTerm(id: "xiaohan", chineseName: "小寒", englishName: "Minor Cold", month: 1, day: 6, season: .winter,
                  poem: "小寒连大吕，欢鹊垒新巢", colors: [Color(hex: "BBDEFB"), Color(hex: "90CAF9")]),
        SolarTerm(id: "dahan", chineseName: "大寒", englishName: "Major Cold", month: 1, day: 20, season: .winter,
                  poem: "大寒须守火，无事不寒天", colors: [Color(hex: "B3E5FC"), Color(hex: "81D4FA")]),
    ]

    static func currentTerm(for date: Date = Date()) -> SolarTerm {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Find the most recent solar term
        let sortedTerms = allTerms.sorted { a, b in
            if a.month == b.month { return a.day < b.day }
            return a.month < b.month
        }

        var result = sortedTerms.last!
        for term in sortedTerms {
            if term.month < month || (term.month == month && term.day <= day) {
                result = term
            }
        }
        return result
    }
}
