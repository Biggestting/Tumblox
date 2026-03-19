import SwiftUI

struct PaceSection: View {
    @Binding var pace: GameConfig.Pace
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            ForEach(GameConfig.Pace.allCases, id: \.self) { option in
                let selected = pace == option
                Button {
                    pace = option
                } label: {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(selected ? TumbloxColors.accentBar : Color.clear)
                            .frame(width: TumbloxSpacing.accentBarWidth, height: TumbloxSpacing.accentBarHeight)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.displayName)
                                .font(selected ? TumbloxTypography.bodyBold : TumbloxTypography.body)
                                .foregroundColor(selected
                                    ? TumbloxColors.textPrimary(colorScheme)
                                    : TumbloxColors.textSecondary(colorScheme))
                            Text(option.description)
                                .font(TumbloxTypography.caption)
                                .foregroundColor(TumbloxColors.textMuted(colorScheme))
                        }
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 56)
                    .background(TumbloxColors.card(colorScheme))
                }
                .buttonStyle(.plain)

                if option != GameConfig.Pace.allCases.last {
                    Divider()
                        .padding(.leading, TumbloxSpacing.accentBarWidth + 14)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: TumbloxSpacing.cardRadius, style: .continuous))
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}
