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
        .shadow(
            color: colorScheme == .light ? DS.shadowColor : .clear,
            radius: DS.shadowRadius,
            y: DS.shadowY
        )
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}

// MARK: - Preview

#Preview("Speed Section") {
    @Previewable @State var speed: GameConfig.AutoFallSpeed = .classic
    return ZStack {
        Color.black.ignoresSafeArea()
        SpeedSection(speed: $speed)
            .padding()
    }
    .preferredColorScheme(.dark)
}
