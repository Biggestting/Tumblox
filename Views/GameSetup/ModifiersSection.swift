import SwiftUI

struct ModifiersSection: View {
    @Binding var modifiers: GameModifiers
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            ModifierRow(title: "Ghost Piece", subtitle: "Shows where your piece will land", isOn: $modifiers.ghostPieceEnabled)
            Divider().padding(.leading, TumbloxSpacing.screenHorizontal)
            ModifierRow(title: "Show Next Piece", subtitle: "Preview the upcoming tetromino", isOn: $modifiers.showNextPiece)
            Divider().padding(.leading, TumbloxSpacing.screenHorizontal)
            ModifierRow(title: "Haptic Feedback", subtitle: "Feel each piece placement", isOn: $modifiers.hapticFeedback)
        }
        .background(TumbloxColors.card(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: TumbloxSpacing.cardRadius, style: .continuous))
        .shadow(
            color: colorScheme == .light ? DS.shadowColor : .clear,
            radius: DS.shadowRadius,
            y: DS.shadowY
        )
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}

private struct ModifierRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TumbloxTypography.body)
                    .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                Text(subtitle)
                    .font(TumbloxTypography.caption)
                    .foregroundColor(TumbloxColors.textMuted(colorScheme))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .tint(TumbloxColors.toggleTint(colorScheme))
                .labelsHidden()
        }
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        .padding(.vertical, 12)
    }
}
