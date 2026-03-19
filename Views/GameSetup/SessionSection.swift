import SwiftUI

struct SessionSection: View {
    @Binding var duration: GameConfig.SessionDuration
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(GameConfig.SessionDuration.presets, id: \.displayName) { option in
                    StripOption(
                        title: option.displayName,
                        isSelected: duration == option
                    ) {
                        duration = option
                    }
                }
            }
            .padding(.horizontal, TumbloxSpacing.screenHorizontal)
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

// MARK: - Preview

#Preview("Session Section") {
    @Previewable @State var duration: GameConfig.SessionDuration = .minutes(5)
    return ZStack {
        Color.black.ignoresSafeArea()
        SessionSection(duration: $duration)
            .padding()
    }
    .preferredColorScheme(.dark)
}
