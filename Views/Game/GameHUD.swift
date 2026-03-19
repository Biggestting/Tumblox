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
            Divider().frame(height: 32).opacity(0.2)
            statCell(value: personalBest.formatted(), label: "BEST")
            Divider().frame(height: 32).opacity(0.2)
            statCell(value: timeDisplay, label: "TIME")

            if let next = nextPiece {
                Divider().frame(height: 32).opacity(0.2)
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
                .font(TumbloxTypography.hudScore)
                .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                .monospacedDigit()
            Text(label)
                .font(TumbloxTypography.hudLabel)
                .kerning(1.5)
                .foregroundColor(TumbloxColors.textSecondary(colorScheme))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
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
