//
//  CustomSlider.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.01.2024.
//

import SwiftUI

struct CustomSlider: View {
    
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    @State private var isEditing: Bool = false
    private let sliderSize: CGFloat = 12
    private let lineHeight: CGFloat = 4
    
    init(value: Binding<Double>, in range: ClosedRange<Double> = 0...1) {
        self._value = value
        self.range = range
    }
    
    var body: some View {
        GeometryReader { geometry in
            let deltaRange = range.upperBound - range.lowerBound
            let stepX: CGFloat = geometry.size.width / (deltaRange == .zero ? 0.1 : deltaRange)
            let middleY: CGFloat = geometry.size.height / 2
            let valueX: CGFloat = min((value - range.lowerBound) * stepX, geometry.size.width)
            
            ZStack {
                RoundedRectangle(cornerRadius: lineHeight / 2)
                    .fill(Color.deep)
                    .frame(height: lineHeight)
                    .overlay {
                        Rectangle()
                            .fill(Color.bevel)
                            .frame(height: 1)
                            .padding(.horizontal, lineHeight / 4)
                            .offset(y: lineHeight / 2)
                    }
                    .onTapGesture(coordinateSpace: .local) { location in
                        let locationX = min(max(0, location.x), geometry.size.width)
                        let newValue = min(range.lowerBound + locationX / stepX, range.upperBound)
                        self.value = newValue
                    }
                
                Circle()
                    .fill(Color.control)
                    .overlay(content: {
                        if isEditing {
                            Circle()
                                .fill(Color.deep.opacity(0.5))
                                .frame(width: sliderSize / 2)
                        }
                    })
                    .frame(width: sliderSize)
                    .shadow(color: .black.opacity(0.25), radius: 3)
                    .position(x: valueX, y: middleY)
                    .gesture(
                        DragGesture()
                            .onChanged({ dragValue in
                                isEditing = true
                                let locationX = min(max(0, dragValue.location.x), geometry.size.width)
                                let newValue = min(range.lowerBound + locationX / stepX, range.upperBound)
                                self.value = newValue
                            })
                            .onEnded({ _ in
                                isEditing = false
                            })
                    )
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var value: Double = 3
        let range: ClosedRange<Double> = 1...10
        
        var body: some View {
            CustomSlider(value: $value, in: range)
                .frame(width: 200, height: 100)
                .padding()
        }
    }
    
    return PreviewWrapper()
}
