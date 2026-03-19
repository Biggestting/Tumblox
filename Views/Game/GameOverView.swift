import SwiftUI

struct GameOverView: View {
    let score: Int
    let personalBest: Int
    let modeName: String
    let isSessionEnd: Bool
    let onRestart: () -> Void
    let onQuit: () -> Void
    var onLeaderboard: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    private var isNewBest: Bool { score > personalBest }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            if colorScheme == .light {
                TumbloxGradient.vertical
                    .opacity(0.06)
                    .ignoresSafeArea()
            }

            VStack(spacing: 32) {
                // Title
                VStack(spacing: 6) {
                    Text(isSessionEnd ? "SESSION COMPLETE" : "GAME OVER")
                        .font(TumbloxTypography.sectionEyebrow)
                        .kerning(3)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                    Text(modeName)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                }

                // Score
                VStack(spacing: 8) {
                    if isNewBest {
                        Text("NEW BEST")
                            .font(TumbloxTypography.sectionEyebrow)
                            .kerning(2)
                            .foregroundColor(TumbloxColors.accentBar)
                    }
                    Text(score.formatted())
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                        .monospacedDigit()
                    if !isNewBest {
                        HStack(spacing: 4) {
                            Text("BEST")
                                .font(TumbloxTypography.hudLabel)
                                .kerning(1.5)
                            Text(personalBest.formatted())
                                .font(TumbloxTypography.captionSemibold)
                                .monospacedDigit()
                        }
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                    }
                }

                // Actions
                VStack(spacing: 12) {
                    TumbloxPrimaryButton(title: "Play Again", showArrow: false, action: onRestart)
                        .frame(maxWidth: 280)
                        .accessibilityLabel("Play Again")

                    if let leaderboard = onLeaderboard {
                        Button(action: leaderboard) {
                            HStack(spacing: 6) {
                                Image(systemName: "trophy")
                                    .font(.system(size: 14))
                                Text("Leaderboard")
                                    .font(TumbloxTypography.body)
                            }
                            .foregroundColor(TumbloxColors.accentBar)
                        }
                        .accessibilityLabel("View Leaderboard")
                    }

                    Button("Back to Menu", action: onQuit)
                        .font(TumbloxTypography.body)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                        .accessibilityLabel("Back to Main Menu")
                }

                // Score group for VoiceOver
                .accessibilityElement(children: .contain)
            }
            .padding(TumbloxSpacing.cardPadding * 1.5)
        }
    }
}
