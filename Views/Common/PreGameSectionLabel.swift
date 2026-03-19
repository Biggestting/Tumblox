import SwiftUI

struct PreGameSectionLabel: View {
    let text: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(text)
            .font(TumbloxTypography.sectionEyebrow)
            .kerning(2.5)
            .foregroundColor(.primaryGradientMid)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}
