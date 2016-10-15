//
//  ChartView.swift
//  TimeSlower2
//
//  Created by Oleksandr Shcherbakov on 8/2/15.
//  Copyright (c) 2015 1lastDay. All rights reserved.
//

import UIKit

class ChartView: UIView {

    @IBOutlet var dayNameLabels: [UILabel]!
    @IBOutlet var view: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var chartWidth: NSLayoutConstraint!
    
    var lastWeekDaynames = [String]()
    var values = [Double]()
    
    fileprivate var max = 0
    fileprivate var min = 0
    fileprivate var graphYScale: CGFloat!
    fileprivate var graphHeight: CGFloat!
    fileprivate var sectionLength: CGFloat!
    fileprivate let progressLine = UIBezierPath()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib() {
        Bundle.main.loadNibNamed("ChartView", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    func setupDaynameLabels() {
        if dayNameLabels.count > 0 {
            var sortedLabels = dayNameLabels.sorted { $0.tag < $1.tag }
            for i in 0 ..< sortedLabels.count {
                sortedLabels[i].text = lastWeekDaynames[i]
            }
            dayNameLabels = sortedLabels
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        defineGraphScale()
    }
    
    func strokeChart() {
        setupDaynameLabels()
        defineMinMaxValues()
        defineGraphScale()
        
        let firstPoint = findFirstPoint()
        addPoint(firstPoint)
        
        progressLine.move(to: firstPoint)
        progressLine.lineWidth = 2.0
        progressLine.lineCapStyle = CGLineCap.round
        progressLine.lineJoinStyle = CGLineJoin.round
        
        buildProgressLineFromPoint(firstPoint)
        animateChartLine(progressLine.cgPath)
    }
    
    func findFirstPoint() -> CGPoint {
        let xPosition: CGFloat = sectionLength / 2
        let yPosition = graphHeight - (graphHeight * (CGFloat(values[0]) / graphYScale))
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    func buildProgressLineFromPoint(_ startPoint: CGPoint) {
        for i in 1 ..< values.count {
            let nextX = startPoint.x + (sectionLength * CGFloat(i))
            let nextY = graphHeight - (graphHeight * (CGFloat(values[i]) / graphYScale))
            let nextPoint = CGPoint(x: nextX, y: nextY)
            progressLine.addLine(to: nextPoint)
            progressLine.move(to: nextPoint)
            addPoint(nextPoint)
        }
    }
    
    func defineMinMaxValues() {
        //TODO: do we need min and max?
        max = Int(values[0])
        min = Int(values[0])
        for i in 0 ..< values.count {
            let num = Int(values[i])
            if max <= num { max = num }
            if min >= num { min = num }
        }
    }
    
    func defineGraphScale() {
        graphYScale = (CGFloat(max) > 100) ? CGFloat(max) : 100
        graphHeight = chartView.frame.height
        sectionLength = (chartView.frame.width) / 7
    }
    
    func addPoint(_ point: CGPoint) {
        let pointView = UIView(frame: CGRect(x: 5, y: 5, width: 8, height: 8))
        pointView.center = point
        pointView.layer.masksToBounds = true
        pointView.layer.cornerRadius = 4
        pointView.layer.backgroundColor = UIColor.white.cgColor
        chartView.addSubview(pointView)
    }
    
    func animateChartLine(_ path: CGPath) {
        let chartLine: CAShapeLayer = newChartLine()
        chartView.layer.addSublayer(chartLine)
        chartLine.path = path
        chartLine.strokeColor = UIColor.white.cgColor
        chartLine.add(newPathAnimation(), forKey: "strokeEndAnimation")
        chartLine.strokeEnd = 1.0
    }
    
    
    
    func newChartLine() -> CAShapeLayer {
        let chartLine = CAShapeLayer()
        chartLine.lineCap = kCALineCapRound
        chartLine.lineJoin = kCALineJoinBevel
        chartLine.fillColor = UIColor.white.cgColor
        chartLine.lineWidth = 2.0
        chartLine.strokeEnd = 0.0
        return chartLine
    }
    
    func newPathAnimation() -> CABasicAnimation {
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = CFTimeInterval(values.count) * 0.4
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        pathAnimation.autoreverses = false
        return pathAnimation
    }

}
