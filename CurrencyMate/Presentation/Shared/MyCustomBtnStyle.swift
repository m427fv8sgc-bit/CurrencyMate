//
//  MyCustomBtnStyle.swift
//  CurrencyMate
//
//  Created by Uttam Bhattcharjee on 03/06/26.
//
import SwiftUI

struct MyCustomBtnStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(<#T##font: Font?##Font?#>)
            .padding(10)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
