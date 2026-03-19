import SwiftUI

struct ChallengeHeroCard: View {
    let currentLevel: Int
    let totalLevels: Int
    let progress: Double

    @Environment(\.colorScheme) var colorScheme

    private var currentChallenge: ChallengeLevel? {
        ChallengeLevel.all.first { $0.number == currentLevel }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Eyebrow — gradient in light, gold in dark
            Text("CHALLENGE MODE")
                .font(TumbloxTypography.sectionEyebrow)
                .kerning(2.5)
                .foregroundStyle(
                    colorScheme == .light
                        ? TumbloxGradient.accent
                        : LinearGradient(colors: [TumbloxColors.accentBar], startPoint: .leading, endPoint: .trailing)
                )

            // Giant level numeral
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(currentLevel)")
                    .font(TumbloxTypography.heroNumeral)
                    .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                Text("/ \(totalLevels)")
                    .font(TumbloxTypography.body)
                    .foregroundColor(TumbloxColors.textSecondary(colorScheme))
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(TumbloxColors.divider(colorScheme))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(TumbloxGradient.primary)
                        .frame(width: geo.size.width * progress, height: 5)
                }
            }
            .frame(height: 5)

            // Objective
            if let challenge = currentChallenge {
                Text(challenge.objective)
                    .font(TumbloxTypography.caption)
                    .foregroundColor(TumbloxColors.textSecondary(colorScheme))
            }
        }
        .padding(20)
        .background(
            ZStack {
                TumbloxColors.card(colorScheme)
                if colorScheme == .light {
                    TumbloxGradient.primary.opacity(0.04)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: TumbloxSpacing.heroRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: TumbloxSpacing.heroRadius, style: .continuous)
                .strokeBorder(
                    TumbloxGradient.primary,
                    lineWidth: colorScheme == .light ? 1.5 : 0
                )
                .opacity(colorScheme == .light ? 0.18 : 0)
        )
        .shadow(
            color: colorScheme == .light ? Color.primaryGradientStart.opacity(0.08) : .clear,
            radius: 12,
            y: 4
        )
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}

// MARK: - Preview

#Preview("Challenge – Dark") {
    ZStack {
        Color.black.ignoresSafeArea()
        ChallengeHeroCard(currentLevel: 7, totalLevels: 31, progress: 0.22)
            .padding(.vertical, 24)
    }
    .preferredColorScheme(.dark)
}

#Preview("Challenge – Light") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        ChallengeHeroCard(currentLevel: 7, totalLevels: 31, progress: 0.22)
            .padding(.vertical, 24)
    }
    .preferredColorScheme(.light)
}
