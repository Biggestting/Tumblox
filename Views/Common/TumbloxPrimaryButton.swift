import SwiftUI

struct TumbloxPrimaryButton: View {
    let title: String
    var showArrow: Bool = false
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(TumbloxTypography.bodyBold)
                if showArrow {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(TumbloxColors.primaryCTA(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
