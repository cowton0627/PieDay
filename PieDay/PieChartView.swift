import UIKit

final class PieChartView: UIView {
    var slices: [ChartSlice] = [] {
        didSet { rebuildLayers() }
    }

    /// 扇形圓在 view 內的半徑比例（留外圍給 leader line + label）
    private let pieRadiusRatio: CGFloat = 0.62
    /// Leader 從圓外延伸的徑向長度
    private let leaderRadialLength: CGFloat = 10
    /// Leader 水平段長度
    private let leaderHorizontalLength: CGFloat = 14

    private let chartLayer = CALayer()
    private var labelViews: [UILabel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        clipsToBounds = false
        layer.addSublayer(chartLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        chartLayer.frame = bounds
        rebuildLayers()
    }

    private func rebuildLayers() {
        chartLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        labelViews.forEach { $0.removeFromSuperview() }
        labelViews.removeAll()
        guard !slices.isEmpty else { return }

        let total = slices.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let viewRadius = min(bounds.width, bounds.height) / 2
        let pieRadius = viewRadius * pieRadiusRatio
        let radian = CGFloat.pi / 180

        let leaderPath = UIBezierPath()

        var startDegree: CGFloat = 270
        for slice in slices {
            let sweep = 360 * (slice.value / total)
            let endDegree = startDegree + sweep
            let midDegree = startDegree + sweep / 2

            // 1. 扇形
            let slicePath = UIBezierPath()
            slicePath.move(to: center)
            slicePath.addArc(withCenter: center,
                             radius: pieRadius,
                             startAngle: startDegree * radian,
                             endAngle: endDegree * radian,
                             clockwise: true)
            slicePath.close()
            let sliceLayer = CAShapeLayer()
            sliceLayer.path = slicePath.cgPath
            sliceLayer.fillColor = slice.color.cgColor
            chartLayer.addSublayer(sliceLayer)

            // 2. Leader line：圓邊 → 短斜線 → 水平段
            let midRadian = midDegree * radian
            let cosM = cos(midRadian)
            let sinM = sin(midRadian)
            let lineStart = CGPoint(
                x: center.x + cosM * pieRadius,
                y: center.y + sinM * pieRadius
            )
            let lineKnee = CGPoint(
                x: center.x + cosM * (pieRadius + leaderRadialLength),
                y: center.y + sinM * (pieRadius + leaderRadialLength)
            )
            let isRight = cosM >= 0
            let dir: CGFloat = isRight ? 1 : -1
            let lineEnd = CGPoint(
                x: lineKnee.x + dir * leaderHorizontalLength,
                y: lineKnee.y
            )
            leaderPath.move(to: lineStart)
            leaderPath.addLine(to: lineKnee)
            leaderPath.addLine(to: lineEnd)

            // 3. Label：分類名 + 百分比，顏色用 slice 色
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.textColor = slice.color
            let percent = Double(slice.value / total * 100)
            let title = slice.label ?? ""
            label.text = title.isEmpty
                ? String(format: "%.0f%%", percent)
                : String(format: "%@ %.0f%%", title, percent)
            label.sizeToFit()
            let labelWidth = label.bounds.width
            let labelHeight = label.bounds.height
            label.frame = CGRect(
                x: isRight ? lineEnd.x + 3 : lineEnd.x - labelWidth - 3,
                y: lineEnd.y - labelHeight / 2,
                width: labelWidth,
                height: labelHeight
            )
            addSubview(label)
            labelViews.append(label)

            startDegree = endDegree
        }

        let leaderLayer = CAShapeLayer()
        leaderLayer.path = leaderPath.cgPath
        leaderLayer.strokeColor = UIColor.separator.cgColor
        leaderLayer.fillColor = UIColor.clear.cgColor
        leaderLayer.lineWidth = 1
        chartLayer.addSublayer(leaderLayer)
    }
}
