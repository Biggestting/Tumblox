import SwiftUI

struct PauseView: View {
    let modeName: String
    let score: Int
    let onResume: () -> Void
    let onQuit: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Blur overlay with branded tint
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            if colorScheme == .light {
                TumbloxGradient.vertical
                    .opacity(0.06)
                    .ignoresSafeArea()
            }

            VStack(spacing: 32) {
                // Mode info
                VStack(spacing: 6) {
                    Text("PAUSED")
                        .font(TumbloxTypography.sectionEyebrow)
                        .kerning(3)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                    Text(modeName)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                }

                // Score display
                VStack(spacing: 4) {
                    Text(score.formatted())
                        .font(TumbloxTypography.hudScore)
                        .foregroundColor(TumbloxColors.accentBar)
                        .monospacedDigit()
                    Text("CURRENT SCORE")
                        .font(TumbloxTypography.hudLabel)
                        .kerning(1.5)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                }

                // Actions
                VStack(spacing: 12) {
                    TumbloxPrimaryButton(title: "Resume", showArrow: false, action: onResume)
                        .frame(maxWidth: 280)

                    Button("Quit Game", action: onQuit)
                        .font(TumbloxTypography.body)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                }
            }
            .padding(TumbloxSpacing.cardPadding * 1.5)
        }
    }
}

// MARK: - Preview

#Preview("Pause View") {
    PreviewHost {
        PauseView(
            modeName: "Zen Stacking",
            score: 14_280,
            onResume: {},
            onQuit: {}
        )
    }
    .preferredColorScheme(.dark)
}
