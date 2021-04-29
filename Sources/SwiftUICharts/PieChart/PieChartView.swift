//
//  PieChartView.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct PieChartView : View {
    public var data: ChartData
    public var legend: String?
    public var style: ChartStyle
    public var formSize:CGSize
    public var valueSpecifier:String
    public var accentColors: [Color]?
    
    @State private var showValue = false
    @State private var currentIndex: Int = 0
    @State private var currentValue: Double = 0 {
        didSet{
            if(oldValue != self.currentValue && self.showValue) {
                HapticFeedback.playSelection()
            }
        }
    }
    
    public init(
        data: ChartData,
        legend: String? = nil,
        style: ChartStyle = Styles.pieChartStyleOne,
        form: CGSize? = ChartForm.medium,
        valueSpecifier: String? = "%.1f",
        accentColors: [Color]? = nil
    ) {
        self.data = data
        self.legend = legend
        self.style = style
        self.formSize = form!
        if self.formSize == ChartForm.large {
            self.formSize = ChartForm.extraLarge
        }
        self.valueSpecifier = valueSpecifier!
        self.accentColors = accentColors
        
        if let first = data.points.first {
            _currentValue = State(initialValue: first.1)
        }
    }
    
    public var body: some View {
        ZStack {
            VStack(alignment: .center) {
                HStack {
                    VStack {
                        Text(self.data.points[currentIndex].0)
                        Text("\(self.currentValue, specifier: self.valueSpecifier)")
                            .font(.headline)
                            .foregroundColor(self.style.textColor)
                    }
                }
                .padding()
                
                PieChartRow(
                    data: data.onlyPoints(),
                    backgroundColor: self.style.backgroundColor,
                    accentColor: self.style.accentColor,
                    accentColors: self.accentColors,
                    showValue: $showValue,
                    currentValue: $currentValue,
                    currentIndex: $currentIndex
                )
                    .foregroundColor(self.style.accentColor)
                    .padding(self.legend != nil ? 0 : 12)
                    .offset(y:self.legend != nil ? 0 : -10)
                
                if(self.legend != nil) {
                    Text(self.legend!)
                        .font(.headline)
                        .foregroundColor(self.style.legendTextColor)
                        .padding()
                }
                
            }
        }
        .frame(width: self.formSize.width, height: self.formSize.height)
    }
}

#if DEBUG
struct PieChartView_Previews : PreviewProvider {
    static var previews: some View {
        PieChartView(data: ChartData(points: [56.0,78.0,53.0,65.0,54.0]))
            .background(RoundedRectangle(cornerRadius: 10))
    }
}
#endif
