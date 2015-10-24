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
    
    private var max = 0
    private var min = 0
    private var graphYScale: CGFloat!
    private var graphHeight: CGFloat!
    private var sectionLength: CGFloat!
    private let progressLine = UIBezierPath()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib() {
        NSBundle.mainBundle().loadNibNamed("ChartView", owner: self, options: nil)
        bounds = view.bounds
        addSubview(view)
    }
    
    func setupDaynameLabels() {
        if dayNameLabels.count > 0 {
            var sortedLabels = dayNameLabels.sort { $0.tag < $1.tag }
            for var i = 0; i < sortedLabels.count; i++ {
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
        
        progressLine.moveToPoint(firstPoint)
        progressLine.lineWidth = 2.0
        progressLine.lineCapStyle = CGLineCap.Round
        progressLine.lineJoinStyle = CGLineJoin.Round
        
        buildProgressLineFromPoint(firstPoint)
        animateChartLine(progressLine.CGPath)
    }
    
    func findFirstPoint() -> CGPoint {
        let xPosition: CGFloat = sectionLength / 2
        let yPosition = graphHeight - (graphHeight * (CGFloat(values[0]) / graphYScale))
        return CGPointMake(xPosition, yPosition)
    }
    
    func buildProgressLineFromPoint(startPoint: CGPoint) {
        for var i = 1; i < values.count; i++ {
            let nextX = startPoint.x + (sectionLength * CGFloat(i))
            let nextY = graphHeight - (graphHeight * (CGFloat(values[i]) / graphYScale))
            let nextPoint = CGPointMake(nextX, nextY)
            progressLine.addLineToPoint(nextPoint)
            progressLine.moveToPoint(nextPoint)
            addPoint(nextPoint)
        }
    }
    
    func defineMinMaxValues() {
        //TODO: do we need min and max?
        max = Int(values[0])
        min = Int(values[0])
        for var i = 0; i < values.count; i++ {
            let num = Int(values[i])
            if max <= num { max = num }
            if min >= num { min = num }
        }
    }
    
    func defineGraphScale() {
        graphYScale = (CGFloat(max) > 100) ? CGFloat(max) : 100
        graphHeight = CGRectGetHeight(chartView.frame)
        sectionLength = (chartView.frame.width) / 7
    }
    
    func addPoint(point: CGPoint) {
        let pointView = UIView(frame: CGRectMake(5, 5, 8, 8))
        pointView.center = point
        pointView.layer.masksToBounds = true
        pointView.layer.cornerRadius = 4
        pointView.layer.backgroundColor = UIColor.whiteColor().CGColor
        chartView.addSubview(pointView)
    }
    
    func animateChartLine(path: CGPathRef) {
        let chartLine: CAShapeLayer = newChartLine()
        chartView.layer.addSublayer(chartLine)
        chartLine.path = path
        chartLine.strokeColor = UIColor.whiteColor().CGColor
        chartLine.addAnimation(newPathAnimation(), forKey: "strokeEndAnimation")
        chartLine.strokeEnd = 1.0
    }
    
    
    
    func newChartLine() -> CAShapeLayer {
        let chartLine = CAShapeLayer()
        chartLine.lineCap = kCALineCapRound
        chartLine.lineJoin = kCALineJoinBevel
        chartLine.fillColor = UIColor.whiteColor().CGColor
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
