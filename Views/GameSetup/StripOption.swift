import SwiftUI

struct StripOption: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TumbloxTypography.captionSemibold)
                .foregroundColor(isSelected
                    ? TumbloxColors.textPrimary(colorScheme)
                    : TumbloxColors.textSecondary(colorScheme))
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .overlay(alignment: .bottom) {
                    if isSelected {
                        Rectangle()
                            .fill(TumbloxColors.accentBar)
                            .frame(height: 2)
                            .offset(y: 1)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
