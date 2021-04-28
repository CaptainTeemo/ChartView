//
//  LineView.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct LineView<TitleContent: View>: View {
    @ObservedObject var data: ChartData
    public var titleContent: (Double, String) -> TitleContent
    public var showLegend: Bool
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String
    public var legendSpecifier: String
    var backgroundColor: Color
    var backgroundRadius: CGFloat
    
    let lineWidth: CGFloat
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showTitleContent = false
    @State private var dragLocation: CGPoint = .zero
    @State private var indicatorLocation: CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var hideHorizontalLines: Bool = false
        
    @State private var currentDataNumber: Double = 0
    @State private var currentDataText: String = ""

    public init(data: ChartData,
                @ViewBuilder titleContent: @escaping (Double, String) -> TitleContent,
                showLegend: Bool = true,
                style: ChartStyle = Styles.lineChartStyleOne,
                lineWidth: CGFloat = 2,
                valueSpecifier: String? = "%.1f",
                legendSpecifier: String? = "%.2f",
                backgroundColor: Color = .clear,
                backgroundRadius: CGFloat = 0) {
        
        self.data = data
        self.titleContent = titleContent
        self.showLegend = showLegend
        self.style = style
        self.lineWidth = lineWidth
        self.valueSpecifier = valueSpecifier!
        self.legendSpecifier = legendSpecifier!
        self.backgroundColor = backgroundColor
        self.backgroundRadius = backgroundRadius
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
    }
    
    public var body: some View {
        VStack(spacing: 15) {
            if showTitleContent {
                titleContent(self.currentDataNumber, self.currentDataText)
                    .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                    .frame(minHeight: 30)
            } else {
                Spacer().frame(minHeight: 30)
            }
            
            GeometryReader { reader in
            ZStack {
                Rectangle()
                    .foregroundColor(self.backgroundColor)
                
                if (showLegend) {
                    Legend(data: self.data,
                           frame: .constant(reader.frame(in: .local)),
                           hideHorizontalLines: self.$hideHorizontalLines,
                           specifier: legendSpecifier)
                }

                Line(data: self.data,
                        frame: .constant(reader.frame(in: .local)),
                        touchLocation: self.$indicatorLocation,
                        showIndicator: $hideHorizontalLines,
                        minDataValue: .constant(nil),
                        maxDataValue: .constant(nil),
                        showBackground: false,
                        backgroundColor: backgroundColor,
                        backgroundRadius: backgroundRadius,
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
                        self.showTitleContent = true
                    })
                    .onEnded({ value in
                        self.opacity = 0
                        self.hideHorizontalLines = false
                        self.showTitleContent = false
                    })
            )
        }
        }
    }
    
    func getClosestDataPoint(toPoint: CGPoint, width: CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.points
        let stepWidth = width / CGFloat(points.count - 1)
        let stepHeight = height / CGFloat(points.max { $0.1 > $1.1 }!.1 + points.min { $0.1 < $1.1 }!.1)
        
        let step = toPoint.x / stepWidth
        let tail = step - floor(step)
        let index = Int(tail >= 0.5 ? ceil(step) : floor(step))
        if (index >= 0 && index < points.count) {
            let point = points[index]
            self.currentDataNumber = point.1
            self.currentDataText = point.0
            return CGPoint(x: CGFloat(index) * stepWidth, y: CGFloat(point.1) * stepHeight)
        }
        return .zero
    }
}

public extension LineView where TitleContent == EmptyView {
    init(data: ChartData,
         showLegend: Bool = true,
         style: ChartStyle = Styles.lineChartStyleOne,
         lineWidth: CGFloat = 2,
         valueSpecifier: String? = "%.1f",
         legendSpecifier: String? = "%.2f",
         backgroundColor: Color = .clear,
         backgroundRadius: CGFloat = 0) {
        self.init(data: data, titleContent: { _, _ in EmptyView() }, showLegend: showLegend, style: style, lineWidth: lineWidth, valueSpecifier: valueSpecifier, legendSpecifier: legendSpecifier, backgroundColor: backgroundColor, backgroundRadius: backgroundRadius)
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineView(data: ChartData(
                        values: [("8", 8), ("23", 23), ("54", 54), ("32", 32), ("12", 12), ("37", 37), ("7", 7), ("23", 23), ("43", 43)])
            )
                .preferredColorScheme(.dark)
            
            LineView(data: ChartData(points: [282.502, 284.495, 283.51, 285.019, 285.197, 286.118, 288.737, 288.455, 289.391, 287.691, 285.878, 286.46, 286.252, 284.652, 284.129, 284.188]), style: Styles.lineChartStyleOne)
                .preferredColorScheme(.dark)
        }
    }
}
