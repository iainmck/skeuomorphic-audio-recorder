//
//  ViewModifiers.swift
//  skeuomorphic-audio-recorder
//
//  Created by Iain McKenzie on 2025-01-12.
//

import SwiftUI

extension View {
    func withNoise(opacity: CGFloat=0.1) -> some View {
        self.overlay(
            NoiseOverlay(opacity: opacity)
        )
    }
    
    func innerShadow(
        radius: CGFloat,
        spread: CGFloat = 5,
        opacity: Double = 1.0,
        isCircle: Bool = false
    ) -> some View {
        return modifier(InsetShadow(
            radius: radius,
            spread: spread,
            opacity: opacity,
            isCircle: isCircle
        ))
    }
    
    func glow(color: Color, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
    
    func pressAnimation(scale: CGFloat, action: @escaping () -> Void) -> some View {
        modifier(PressAnimation(pressScale: scale, action: action))
    }
}

struct NoiseOverlay: View {
    let opacity: CGFloat
    
    var body: some View {
        Image("noise-texture") // Add your noise texture image to your assets
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blendMode(.overlay)
            .opacity(opacity)
            .allowsHitTesting(false)
    }
}

// overlays are doubled to increase opacity of shadow
struct InsetShadow: ViewModifier {
    var radius: CGFloat
    var spread: CGFloat
    var opacity: CGFloat
    var isCircle: Bool = false
    
    func body(content: Content) -> some View {
        let shadow = spread/5
        let offset = spread/6
        
        let adjustedSpread = isCircle ? 1.0 : spread
        let circleFactor: CGFloat = isCircle ? 0.0 : 1.0
        
        let lineWidth: CGFloat = 1
        
        content
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.black.opacity(1), lineWidth: lineWidth)
                    // light top-left shadow
                    .shadow(
                        color: .white.opacity(opacity),
                        radius: shadow,
                        x: offset + adjustedSpread,
                        y: (offset + adjustedSpread) * circleFactor
                    )
                    .padding(-adjustedSpread)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.black.opacity(1), lineWidth: lineWidth)
                    // light top-left shadow
                    .shadow(
                        color: .white.opacity(opacity),
                        radius: shadow,
                        x: offset + adjustedSpread,
                        y: (offset + adjustedSpread) * circleFactor
                    )
                    .padding(-adjustedSpread)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.black.opacity(1), lineWidth: lineWidth)
                    // dark bottom-right shadow
                    .shadow(
                        color: .black.opacity(opacity),
                        radius: shadow,
                        x: -(offset + adjustedSpread - lineWidth), // *2 bc apparently we need to undo the previous offset
                        y: -(offset + adjustedSpread - lineWidth) * circleFactor
                    )
                    .padding(-adjustedSpread)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(.black.opacity(1), lineWidth: lineWidth)
                    // dark bottom-right shadow
                    .shadow(
                        color: .black.opacity(opacity),
                        radius: shadow,
                        x: -(offset + adjustedSpread - lineWidth), // *2 bc apparently we need to undo the previous offset
                        y: -(offset + adjustedSpread - lineWidth) * circleFactor
                    )
                    .padding(-adjustedSpread)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                    .allowsHitTesting(false)
            }
    }
}

struct PressAnimation: ViewModifier {
    let pressScale: CGFloat
    let action: () -> Void
    @State private var scale = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(scale)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard scale == 1.0 else { return }
                        
                        withAnimation(.easeIn(duration: 0.1)) {
                            scale = pressScale
                        }
                        
                        withAnimation(.easeIn(duration: 0.1).delay(0.2)) {
                            scale = 1.0
                        }
                    }
                    .onEnded { _ in
                        action()
                    }
            )
    }
}


extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}


extension Font {
    static func digital(_ size: CGFloat) -> Font {
        // This special handling only needed in App Playground
        guard let url = Bundle.main.url(forResource: "ARCADE_R", withExtension: "TTF") else { return Font(.init(.system, size: size)) }
        
        CTFontManagerRegisterFontsForURL(url as CFURL, CTFontManagerScope.process, nil)

        let uiFont = UIFont(name: "ArcadeRounded", size: size)

        return Font(uiFont ?? UIFont())
    }
}
