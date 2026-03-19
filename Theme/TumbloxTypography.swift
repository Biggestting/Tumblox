import SwiftUI

enum TumbloxTypography {
    /// App wordmark — 34pt heavy
    static let wordmark = Font.system(size: 34, weight: .heavy, design: .rounded)

    /// Mode label chip — 12pt bold, uppercase
    static let modeName = Font.system(size: 12, weight: .bold, design: .rounded)

    /// Challenge hero numeral — 48pt heavy, monospaced digits
    static let heroNumeral = Font.system(size: 48, weight: .heavy, design: .rounded)
        .monospacedDigit()

    /// HUD score / best — 28pt heavy, monospaced digits
    static let hudScore = Font.system(size: 28, weight: .heavy, design: .rounded)
        .monospacedDigit()

    /// HUD label — 10pt semibold, uppercase
    static let hudLabel = Font.system(size: 10, weight: .semibold, design: .rounded)

    /// Section eyebrow label — 11pt bold, kerning 2.5
    static let sectionEyebrow = Font.system(size: 11, weight: .bold, design: .rounded)

    /// Mode row score — 20pt bold, monospaced
    static let modeScore = Font.system(size: 20, weight: .bold, design: .rounded)
        .monospacedDigit()

    /// Body regular — 15pt
    static let body = Font.system(size: 15, weight: .regular, design: .rounded)

    /// Body bold — 15pt
    static let bodyBold = Font.system(size: 15, weight: .bold, design: .rounded)

    /// Caption — 13pt regular
    static let caption = Font.system(size: 13, weight: .regular, design: .rounded)

    /// Caption semibold — 13pt
    static let captionSemibold = Font.system(size: 13, weight: .semibold, design: .rounded)

    /// Control bar icon size
    static let controlIcon: CGFloat = 22
}
