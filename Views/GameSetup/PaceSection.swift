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
        .shadow(
            color: colorScheme == .light ? DS.shadowColor : .clear,
            radius: DS.shadowRadius,
            y: DS.shadowY
        )
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}

// MARK: - Preview

private struct PaceSectionPreview: View {
    @State private var pace: GameConfig.Pace = .manualDrop
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 8) {
                Text("PACE")
                    .font(.system(size: 11, weight: .semibold))
                    .kerning(2)
                    .foregroundColor(.gray)
                    .padding(.leading, 16)
                PaceSection(pace: $pace)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("Pace Section") {
    PaceSectionPreview()
}
