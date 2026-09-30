// Components/SolxceLogoView.swift
import SwiftUI

/// Solxce kinetic apex prism mark - custom non-letter 3D faceted geometry in pure white & platinum relief
public struct SolxceLogoView: View {
    public var size: CGFloat = 80
    public var showGlow: Bool = true
    public var showAppIconContainer: Bool = false

    public init(size: CGFloat = 80, showGlow: Bool = true, showAppIconContainer: Bool = false) {
        self.size = size
        self.showGlow = showGlow
        self.showAppIconContainer = showAppIconContainer
    }

    public var body: some View {
        if showAppIconContainer {
            ZStack {
                // App Icon Background Plate
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.08, green: 0.08, blue: 0.09),
                                Color(red: 0.02, green: 0.02, blue: 0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.05),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: max(1, size * 0.015)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.8), radius: size * 0.15, x: 0, y: size * 0.08)

                logoMark
                    .frame(width: size * 0.58, height: size * 0.58)
            }
            .frame(width: size, height: size)
        } else {
            logoMark
                .frame(width: size, height: size)
        }
    }

    private var logoMark: some View {
        ZStack {
            if showGlow {
                // Specular Core Radiance
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color(white: 0.8).opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.45
                        )
                    )
                    .blur(radius: size * 0.08)
            }

            // Faceted Prism Canvas
            Canvas { context, sz in
                let w = sz.width
                let h = sz.height
                
                // Key geometry anchor points
                let topApex = CGPoint(x: w * 0.50, y: h * 0.05)
                let bottomApex = CGPoint(x: w * 0.50, y: h * 0.95)
                let leftOuter = CGPoint(x: w * 0.08, y: h * 0.48)
                let rightOuter = CGPoint(x: w * 0.92, y: h * 0.48)
                let centerPivot = CGPoint(x: w * 0.50, y: h * 0.46)
                let leftInnerShoulder = CGPoint(x: w * 0.28, y: h * 0.32)
                let rightInnerShoulder = CGPoint(x: w * 0.72, y: h * 0.32)
                let leftLowerFlank = CGPoint(x: w * 0.26, y: h * 0.68)
                let rightLowerFlank = CGPoint(x: w * 0.74, y: h * 0.68)

                // 1. Top-Left Primary Facet (Pure Specular White)
                var path1 = Path()
                path1.move(to: topApex)
                path1.addLine(to: centerPivot)
                path1.addLine(to: leftInnerShoulder)
                path1.closeSubpath()
                context.fill(path1, with: .linearGradient(
                    Gradient(colors: [Color.white, Color(white: 0.94)]),
                    startPoint: topApex,
                    endPoint: centerPivot
                ))

                // 2. Top-Right High-Light Facet (Crisp Silver White)
                var path2 = Path()
                path2.move(to: topApex)
                path2.addLine(to: rightInnerShoulder)
                path2.addLine(to: centerPivot)
                path2.closeSubpath()
                context.fill(path2, with: .linearGradient(
                    Gradient(colors: [Color.white.opacity(0.96), Color(white: 0.82)]),
                    startPoint: topApex,
                    endPoint: rightInnerShoulder
                ))

                // 3. Left Outer Wing Facet (Chiseled Porcelain Shard)
                var path3 = Path()
                path3.move(to: topApex)
                path3.addLine(to: leftOuter)
                path3.addLine(to: leftInnerShoulder)
                path3.closeSubpath()
                context.fill(path3, with: .linearGradient(
                    Gradient(colors: [Color(white: 0.95), Color(white: 0.70)]),
                    startPoint: topApex,
                    endPoint: leftOuter
                ))

                // 4. Right Outer Wing Facet (Reflective Metallic Shard)
                var path4 = Path()
                path4.move(to: topApex)
                path4.addLine(to: rightInnerShoulder)
                path4.addLine(to: rightOuter)
                path4.closeSubpath()
                context.fill(path4, with: .linearGradient(
                    Gradient(colors: [Color(white: 0.80), Color(white: 0.52)]),
                    startPoint: topApex,
                    endPoint: rightOuter
                ))

                // 5. Center-Left Lower Diamond (Chiseled Shadow Plate)
                var path5 = Path()
                path5.move(to: centerPivot)
                path5.addLine(to: bottomApex)
                path5.addLine(to: leftLowerFlank)
                path5.closeSubpath()
                context.fill(path5, with: .linearGradient(
                    Gradient(colors: [Color(white: 0.88), Color(white: 0.45)]),
                    startPoint: centerPivot,
                    endPoint: bottomApex
                ))

                // 6. Center-Right Lower Diamond (Deep Chiseled Slate)
                var path6 = Path()
                path6.move(to: centerPivot)
                path6.addLine(to: rightLowerFlank)
                path6.addLine(to: bottomApex)
                path6.closeSubpath()
                context.fill(path6, with: .linearGradient(
                    Gradient(colors: [Color(white: 0.65), Color(white: 0.28)]),
                    startPoint: centerPivot,
                    endPoint: bottomApex
                ))

                // 7. Left Flank Connector
                var path7 = Path()
                path7.move(to: leftOuter)
                path7.addLine(to: leftLowerFlank)
                path7.addLine(to: centerPivot)
                path7.closeSubpath()
                context.fill(path7, with: .linearGradient(
                    Gradient(colors: [Color(white: 0.75), Color(white: 0.40)]),
                    startPoint: leftOuter,
                    endPoint: centerPivot
                ))

                // 8. Right Flank Connector (Deep Ambient Drop)
                var path8 = Path()
                path8.move(to: rightOuter)
                path8.addLine(to: centerPivot)
                path8.addLine(to: rightLowerFlank)
                path8.closeSubpath()
                context.fill(path8, with: .linearGradient(
                    Gradient(colors: [Color(white: 0.50), Color(white: 0.20)]),
                    startPoint: rightOuter,
                    endPoint: rightLowerFlank
                ))

                // 9. Precision Outer Bevel Hairline Stroke
                var outlinePath = Path()
                outlinePath.move(to: topApex)
                outlinePath.addLine(to: rightOuter)
                outlinePath.addLine(to: bottomApex)
                outlinePath.addLine(to: leftOuter)
                outlinePath.closeSubpath()
                context.stroke(
                    outlinePath,
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.8),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.6)
                        ]),
                        startPoint: topApex,
                        endPoint: bottomApex
                    ),
                    lineWidth: max(1, w * 0.018)
                )

                // 10. Central Dynamic Split Hairline (Negative space fissure)
                var centerRidge = Path()
                centerRidge.move(to: topApex)
                centerRidge.addLine(to: centerPivot)
                centerRidge.addLine(to: bottomApex)
                context.stroke(
                    centerRidge,
                    with: .color(Color.white.opacity(0.95)),
                    lineWidth: max(1.2, w * 0.02)
                )
            }
        }
    }
}
