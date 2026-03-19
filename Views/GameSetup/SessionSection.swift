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
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}
