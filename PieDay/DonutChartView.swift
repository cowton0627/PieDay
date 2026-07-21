import UIKit

final class DonutChartView: UIView {
    var slices: [ChartSlice] = [] {
        didSet { rebuildLayers() }
    }

    let centerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()

    /// 環的厚度佔半徑的比例。0.32 ≈ 半徑的 1/3，讓中空圈有空間放文字。
    private let lineWidthRatio: CGFloat = 0.32
    /// 外圈半徑占 view 半徑的比例（留邊距讓視覺更精緻）
    private let outerRadiusRatio: CGFloat = 0.78
    private let chartLayer = CALayer()

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
        layer.addSublayer(chartLayer)
        addSubview(centerLabel)
        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.55),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        chartLayer.frame = bounds
        let fontSize = max(10, min(bounds.width, bounds.height) * 0.11)
        centerLabel.font = .systemFont(ofSize: fontSize, weight: .medium)
        rebuildLayers()
    }

    private func rebuildLayers() {
        chartLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) / 2 * outerRadiusRatio
        let lineWidth = outerRadius * lineWidthRatio
        let radius = outerRadius - lineWidth / 2
        guard radius > 0 else { return }

        let radian = CGFloat.pi / 180

        let backgroundPath = UIBezierPath(arcCenter: center,
                                          radius: radius,
                                          startAngle: 0,
                                          endAngle: 360 * radian,
                                          clockwise: true)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.strokeColor = UIColor.systemGray5.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = lineWidth
        chartLayer.addSublayer(backgroundLayer)

        let total = slices.reduce(0) { $0 + $1.value }
        guard total > 0 else { return }

        var startDegree: CGFloat = 270
        for slice in slices {
            let sweep = 360 * (slice.value / total)
            let endDegree = startDegree + sweep

            let path = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: startDegree * radian,
                                    endAngle: endDegree * radian,
                                    clockwise: true)
            let arcLayer = CAShapeLayer()
            arcLayer.path = path.cgPath
            arcLayer.strokeColor = slice.color.cgColor
            arcLayer.fillColor = UIColor.clear.cgColor
            arcLayer.lineWidth = lineWidth
            arcLayer.lineCap = .butt
            chartLayer.addSublayer(arcLayer)

            startDegree = endDegree
        }
    }
}
