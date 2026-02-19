import WidgetKit
import SwiftUI

@main
struct DaydreamWidgetBundle: WidgetBundle {
    var body: some Widget {
        DreamWidget()
        DreamLockScreenWidget()
    }
}
