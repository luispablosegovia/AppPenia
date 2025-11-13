//
//  GlassComponents.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI

// MARK: - Glass Background

struct GlassBackground: View {
    var body: some View {
        ZStack {
            // Gradiente animado de fondo
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

            // Marca de agua con AppIcon justo debajo del título
            VStack {
                Image("AppIcon_1024x1024")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .opacity(0.05)
                    .padding(.top, 160)
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .brightness(isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}

// MARK: - Glass Section Background

struct GlassSectionBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Glass Button Style

struct GlassButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .opacity(isEnabled ? 1.0 : 0.5)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Glass List Background

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

// MARK: - Animated Glass Card

struct AnimatedGlassCard<Content: View>: View {
    let content: Content
    @State private var isVisible = false

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Glass Form Modifier

struct GlassFormModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.plain)
    }
}

extension View {
    func glassForm() -> some View {
        modifier(GlassFormModifier())
    }
}
