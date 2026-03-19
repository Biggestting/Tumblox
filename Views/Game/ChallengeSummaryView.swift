import SwiftUI

struct ChallengeSummaryView: View {
    let result: ChallengeResult
    let levelNumber: Int
    let score: Int
    let onNext: () -> Void      // advance to next level
    let onRetry: () -> Void     // replay same level
    let onQuit: () -> Void      // back to menu

    @Environment(\.colorScheme) var colorScheme

    private var isSuccess: Bool {
        if case .success = result { return true }
        return false
    }

    private var failureReason: String? {
        if case .failure(let reason) = result { return reason }
        return nil
    }

    private var level: ChallengeLevel? {
        ChallengeLevel.all.first { $0.number == levelNumber }
    }

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

            VStack(spacing: 0) {
                Spacer()

                // Card
                VStack(spacing: 28) {
                    // Result indicator
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(isSuccess
                                    ? TumbloxColors.accent(colorScheme).opacity(0.15)
                                    : TumbloxColors.destructive.opacity(0.12))
                                .frame(width: 72, height: 72)
                            Image(systemName: isSuccess ? "checkmark" : "xmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(isSuccess ? TumbloxColors.accent(colorScheme) : TumbloxColors.destructive)
                        }

                        Text(isSuccess ? "LEVEL COMPLETE" : "LEVEL FAILED")
                            .font(TumbloxTypography.sectionEyebrow)
                            .kerning(3)
                            .foregroundColor(isSuccess
                                ? TumbloxColors.accent(colorScheme)
                                : TumbloxColors.destructive)
                    }

                    // Level info
                    VStack(spacing: 6) {
                        if let level = level {
                            Text("Level \(levelNumber) — \(level.title)")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                                .multilineTextAlignment(.center)

                            Text(level.objective)
                                .font(TumbloxTypography.caption)
                                .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                                .multilineTextAlignment(.center)
                        }

                        if let reason = failureReason {
                            Text(reason)
                                .font(TumbloxTypography.captionSemibold)
                                .foregroundColor(TumbloxColors.destructive)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 8)

                    // Score
                    VStack(spacing: 4) {
                        Text(score.formatted())
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                            .monospacedDigit()
                        Text("SCORE")
                            .font(TumbloxTypography.hudLabel)
                            .kerning(1.5)
                            .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                    }

                    // Actions
                    VStack(spacing: 10) {
                        if isSuccess {
                            TumbloxPrimaryButton(title: "Next Level", showArrow: true, action: onNext)
                        } else {
                            TumbloxPrimaryButton(title: "Try Again", showArrow: false, action: onRetry)
                        }

                        Button(isSuccess ? "Back to Menu" : "Quit", action: onQuit)
                            .font(TumbloxTypography.body)
                            .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                    }
                }
                .padding(TumbloxSpacing.cardPadding * 1.5)
                .background(TumbloxColors.card(colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
                .shadow(color: .black.opacity(0.2), radius: 24, y: 8)

                Spacer()
            }
        }
    }
}
