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
            // Eyebrow
            Text("CHALLENGE MODE")
                .font(TumbloxTypography.sectionEyebrow)
                .kerning(2.5)
                .foregroundColor(TumbloxColors.accentBar)

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
                    RoundedRectangle(cornerRadius: 2)
                        .fill(TumbloxColors.divider(colorScheme))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(TumbloxColors.goldProgress)
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)

            // Objective
            if let challenge = currentChallenge {
                Text(challenge.objective)
                    .font(TumbloxTypography.caption)
                    .foregroundColor(TumbloxColors.textSecondary(colorScheme))
            }
        }
        .padding(TumbloxSpacing.cardPadding)
        .background(TumbloxColors.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: TumbloxSpacing.heroRadius, style: .continuous))
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}
