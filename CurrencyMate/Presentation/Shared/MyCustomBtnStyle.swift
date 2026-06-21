//
//  MyCustomBtnStyle.swift
//  CurrencyMate
//
//  Created by Uttam Bhattcharjee on 03/06/26.
//
import SwiftUI

struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .tint(.white)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(background(isPressed: configuration.isPressed))
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? 1 : 0.65)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
            .animation(.snappy(duration: 0.16), value: isEnabled)
    }

    private func background(isPressed: Bool) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(isEnabled ? Color.accentColor : Color.secondary)
            .brightness(isPressed ? -0.06 : 0)
    }
}

struct CurrencyIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(isEnabled ? Color.accentColor : Color.secondary)
            .frame(width: 44, height: 44)
            .background {
                Circle()
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.18 : 0.12))
            }
            .overlay {
                Circle()
                    .stroke(Color.accentColor.opacity(0.24), lineWidth: 1)
            }
            .contentShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(isEnabled ? 1 : 0.6)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryActionButtonStyle {
    static var primaryAction: PrimaryActionButtonStyle {
        PrimaryActionButtonStyle()
    }
}

extension ButtonStyle where Self == CurrencyIconButtonStyle {
    static var currencyIcon: CurrencyIconButtonStyle {
        CurrencyIconButtonStyle()
    }
}
