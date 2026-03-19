import SwiftUI

struct SpeedSection: View {
    @Binding var speed: GameConfig.AutoFallSpeed
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(GameConfig.AutoFallSpeed.allCases, id: \.self) { option in
                    StripOption(
                        title: option.displayName,
                        isSelected: speed == option
                    ) {
                        speed = option
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
