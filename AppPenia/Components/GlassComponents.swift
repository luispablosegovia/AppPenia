//
//  GlassComponents.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//  Migrated to iOS 26 Liquid Glass APIs
//

import SwiftUI

// MARK: - Liquid Glass Background (iOS 26)

struct GlassBackground: View {
    var body: some View {
        ZStack {
            // Gradiente animado de fondo con colores del sistema
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.25),
                    Color.pink.opacity(0.2),
                    Color.blue.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Círculos decorativos con blur
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -100, y: -200)

            Circle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .offset(x: 150, y: 400)

            // Marca de agua con AppIcon centrada
            Image("AppIcon_1024x1024")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 400)
                .opacity(0.05)
        }
    }
}

// MARK: - Liquid Glass Card Modifier (iOS 26 Native)

extension View {
    /// Aplica el efecto liquid glass nativo de iOS 26 con interactividad
    func glassCard() -> some View {
        self
            .padding()
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    }
}

// MARK: - Glass Row (iOS 26)

struct GlassRow<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    }
}

// MARK: - Glass List Background (iOS 26)

struct GlassListBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            GlassBackground()

            content
                .scrollContentBackground(.hidden)
        }
    }
}

extension View {
    func glassListBackground() -> some View {
        modifier(GlassListBackground())
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 20) {
        Text("Liquid Glass Card")
            .glassCard()

        GlassRow {
            HStack {
                Image(systemName: "star.fill")
                Text("Glass Row Example")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.primary)
        }
    }
    .glassListBackground()
}
