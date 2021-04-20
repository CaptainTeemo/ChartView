//
//  LineView.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct LineView: View {
    @ObservedObject var data: ChartData
    public var title: String?
    public var showLegend: Bool
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String
    public var legendSpecifier: String
    
    let lineWidth: CGFloat
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var legendText: String = ""
    @State private var dragLocation: CGPoint = .zero
    @State private var indicatorLocation: CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var currentDataNumber: Double = 0 {
        didSet {
            self.legendText = String(format: "%.2f", self.currentDataNumber)
        }
    }
    @State private var hideHorizontalLines: Bool = false
    
    public init(data: [Double],
                title: String? = nil,
                showLegend: Bool = false,
                style: ChartStyle = Styles.lineChartStyleOne,
                lineWidth: CGFloat = 2,
                valueSpecifier: String? = "%.1f",
                legendSpecifier: String? = "%.2f") {
        
        self.data = ChartData(points: data)
        self.title = title
        self.showLegend = showLegend
        self.style = style
        self.lineWidth = lineWidth
        self.valueSpecifier = valueSpecifier!
        self.legendSpecifier = legendSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group{
                if (self.title != nil){
                    Text(self.title!)
                        .font(.title)
                        .bold()
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                }
                Text(self.legendText)
                    .font(.callout)
                    .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
            }
            GeometryReader { reader in
                ZStack {
                    Rectangle()
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                    if (showLegend) {
                        Legend(data: self.data,
                               frame: .constant(reader.frame(in: .local)), hideHorizontalLines: self.$hideHorizontalLines, specifier: legendSpecifier)
                            .transition(.opacity)
                            .animation(Animation.easeOut(duration: 1).delay(1))
                    }
                    Line(data: self.data,
                         frame: .constant(reader.frame(in: .local)),
                         touchLocation: self.$indicatorLocation,
                         showIndicator: self.$hideHorizontalLines,
                         minDataValue: .constant(nil),
                         maxDataValue: .constant(nil),
                         showBackground: false,
                         lineWidth: self.lineWidth,
                         gradient: self.style.gradientColor
                    )
                }
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            self.dragLocation = value.location
                            self.indicatorLocation = CGPoint(x: max(value.location.x, 0), y: 32)
                            self.closestPoint = getClosestDataPoint(toPoint: value.location, width: reader.frame(in: .local).width, height: reader.frame(in: .local).height)
                            self.opacity = 1
                            self.hideHorizontalLines = true
                        })
                        .onEnded({ value in
                            self.opacity = 0
                            self.hideHorizontalLines = false
                            self.legendText = ""
                        })
                )
            }
        }
    }
    
    func getClosestDataPoint(toPoint: CGPoint, width: CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth = width / CGFloat(points.count - 1)
        let stepHeight = height / CGFloat(points.max()! + points.min()!)
        
        let step = toPoint.x / stepWidth
        let tail = step - floor(step)
        let index = Int(tail >= 0.5 ? ceil(step) : floor(step))
        if (index >= 0 && index < points.count) {
            self.currentDataNumber = points[index]
            return CGPoint(x: CGFloat(index) * stepWidth, y: CGFloat(points[index]) * stepHeight)
        }
        return .zero
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineView(data: [8,23,54,32,12,37,7,23,43], title: "Full chart", style: Styles.lineChartStyleOne)
                .preferredColorScheme(.dark)
            
            LineView(data: [282.502, 284.495, 283.51, 285.019, 285.197, 286.118, 288.737, 288.455, 289.391, 287.691, 285.878, 286.46, 286.252, 284.652, 284.129, 284.188], title: "Full chart", style: Styles.lineChartStyleOne)
                .preferredColorScheme(.dark)
        }
    }
}
