import UIKit

struct ChartSlice {
    let value: CGFloat
    let color: UIColor
    let label: String?

    init(value: CGFloat, color: UIColor, label: String? = nil) {
        self.value = value
        self.color = color
        self.label = label
    }
}
