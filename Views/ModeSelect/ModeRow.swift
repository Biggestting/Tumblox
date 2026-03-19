import SwiftUI

struct ModeRow: View {
    let mode: GameMode
    let isActive: Bool
    let isLocked: Bool
    let personalBest: Int?
    let onTap: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Left accent bar (active indicator)
                Rectangle()
                    .fill(isActive ? TumbloxColors.accentBar : Color.clear)
                    .frame(width: TumbloxSpacing.accentBarWidth)

                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(mode.name.uppercased())
                            .font(TumbloxTypography.modeName)
                            .kerning(1.5)
                            .foregroundColor(isActive
                                ? TumbloxColors.textPrimary(colorScheme)
                                : TumbloxColors.textSecondary(colorScheme))
                        Text(mode.description)
                            .font(TumbloxTypography.caption)
                            .foregroundColor(TumbloxColors.textMuted(colorScheme))
                            .lineLimit(1)
                    }

                    Spacer()

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(TumbloxColors.textMuted(colorScheme))
                    } else if let best = personalBest {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(best.formatted())
                                .font(TumbloxTypography.modeScore)
                                .foregroundColor(TumbloxColors.accentBar)
                            Text("BEST")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .kerning(1)
                                .foregroundColor(TumbloxColors.textMuted(colorScheme))
                        }
                    }
                }
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
                .padding(.vertical, 16)
            }
            .background(TumbloxColors.card(colorScheme))
            .opacity(isLocked ? 0.45 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint(isLocked ? "Locked. Double tap to unlock." : "Double tap to set up and play.")
        .accessibilityAddTraits(isLocked ? .isButton : .isButton)
    }

    private var accessibilityDescription: String {
        var parts = [mode.name]
        if isLocked { parts.append("Locked") }
        if let best = personalBest { parts.append("Best score: \(best)") }
        return parts.joined(separator: ". ")
    }
}
