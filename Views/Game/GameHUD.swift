import SwiftUI

struct GameHUD: View {
    let score: Int
    let personalBest: Int
    let elapsedSeconds: Int
    let sessionDuration: GameConfig.SessionDuration
    let modeName: String
    let nextPiece: Tetromino?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            statCell(value: score.formatted(), label: "SCORE")
            Divider()
                .frame(height: 32)
                .opacity(colorScheme == .dark ? 0.15 : 0.12)
            statCell(value: personalBest.formatted(), label: "BEST")
            Divider()
                .frame(height: 32)
                .opacity(colorScheme == .dark ? 0.15 : 0.12)
            statCell(value: timeDisplay, label: "TIME")

            if let next = nextPiece {
                Divider()
                    .frame(height: 32)
                    .opacity(colorScheme == .dark ? 0.15 : 0.12)
                NextPieceView(piece: next)
                    .padding(.horizontal, 12)
            }
        }
        .frame(height: TumbloxSpacing.hudHeight)
        .background(TumbloxColors.hudBackground(colorScheme))
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundColor(hudValueColor)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .kerning(1.5)
                .foregroundColor(hudLabelColor)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }

    /// HUD value color — teal in dark mode, dark text in light mode
    private var hudValueColor: Color {
        colorScheme == .dark
            ? Color(hex: "#2DD4BF")
            : TumbloxColors.textPrimary(colorScheme)
    }

    /// HUD label color — teal dimmed in dark mode, secondary text in light mode
    private var hudLabelColor: Color {
        colorScheme == .dark
            ? Color(hex: "#2DD4BF").opacity(0.7)
            : TumbloxColors.textSecondary(colorScheme)
    }

    private var timeDisplay: String {
        switch sessionDuration {
        case .unlimited:
            return formatTime(elapsedSeconds)
        case .minutes(let m):
            let remaining = max(0, m * 60 - elapsedSeconds)
            return formatTime(remaining)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Preview

#Preview("HUD – Dark") {
    GameHUD(
        score: 14_280,
        personalBest: 22_100,
        elapsedSeconds: 97,
        sessionDuration: .minutes(5),
        modeName: "Zen Stacking",
        nextPiece: nil
    )
    .preferredColorScheme(.dark)
}

#Preview("HUD – Light") {
    GameHUD(
        score: 9_400,
        personalBest: 22_100,
        elapsedSeconds: 45,
        sessionDuration: .unlimited,
        modeName: "Blitz",
        nextPiece: nil
    )
    .preferredColorScheme(.light)
}
