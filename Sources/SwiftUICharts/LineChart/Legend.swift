//
//  Legend.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

struct Legend: View {
    @ObservedObject var data: ChartData
    @Binding var frame: CGRect
    @Binding var hideHorizontalLines: Bool
    @Binding var startPoint: CGFloat
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var specifier: String = "%.2f"
    let padding: CGFloat = 0

    var stepWidth: CGFloat {
        if data.points.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.points.count - 1)
    }
    var stepHeight: CGFloat {
        let points = self.data.onlyPoints()
        if let min = points.min(), let max = points.max(), min != max {
            if (min < 0) {
                return (frame.size.height - padding) / CGFloat(max - min)
            }else{
                return (frame.size.height - padding) / CGFloat(max - min)
            }
        }
        return 0
    }
    
    var min: CGFloat {
        let points = self.data.onlyPoints()
        return CGFloat(points.min() ?? 0)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topLeading) {
                ForEach((0...4), id: \.self) { height in
                    self.line(atHeight: self.getYLegendSafe(height: height), width: self.frame.width)
                        .stroke(self.colorScheme == .dark ? Colors.LegendDarkColor : Colors.LegendColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [5, height == 0 ? 0 : 10]))
                        .opacity(1)
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeOut(duration: 0.2))
                        .clipped()
                }
            }
            
            ZStack(alignment: .topLeading) {
                ForEach((0...4), id: \.self) { height in
                    Text("\(self.getYLegendSafe(height: height), specifier: specifier)")
                        .offset(x: 0, y: self.getYposition(height: height))
                        .foregroundColor(Colors.LegendText)
                        .font(.caption)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    func getYLegendSafe(height: Int) -> CGFloat {
        if let legend = getYLegend() {
            return CGFloat(legend[height])
        }
        return 0
    }
    
    func getYposition(height: Int) -> CGFloat {
        if let legend = getYLegend() {
            return ((self.frame.height) / 2) - ((CGFloat(legend[height]) - min) * self.stepHeight)
        }
        return 0
    }
    
    func line(atHeight: CGFloat, width: CGFloat) -> Path {
        var hLine = Path()
        hLine.move(to: CGPoint(x: 5, y: (atHeight - min) * stepHeight))
        hLine.addLine(to: CGPoint(x: width, y: (atHeight - min) * stepHeight))
        return hLine
    }
    
    func getYLegend() -> [Double]? {
        let points = self.data.onlyPoints()
        guard let max = points.max() else { return nil }
        guard let min = points.min() else { return nil }
        let step = Double(max - min) / 4
        return [min + step * 0, min + step * 1, min + step * 2, min + step * 3, min + step * 4]
    }
}

private struct ViewWidthKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct Legend_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            Legend(data: ChartData(values: [("1", 0.2), ("2", 0.4), ("3", 1.4), ("4", 4.5), ("5", 24.5)]), frame: .constant(geometry.frame(in: .local)), hideHorizontalLines: .constant(false), startPoint: .constant(0))
        }
        .frame(width: 320, height: 320)
    }
}
