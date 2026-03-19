import SwiftUI

// MARK: - 1. Mode Select (Home Screen)

#Preview("1 – Mode Select") {
    NavigationStack {
        PreviewHost {
            ModeSelectView()
        }
    }
    .preferredColorScheme(.light)
}

// MARK: - 2. Game Setup – Zen Stacking

#Preview("2 – Setup: Zen Stacking") {
    NavigationStack {
        PreviewHost {
            GameSetupView(modeID: .zenStacking)
        }
    }
    .preferredColorScheme(.light)
}

// MARK: - 3. Game Setup – Challenge

#Preview("3 – Setup: Challenge") {
    NavigationStack {
        PreviewHost {
            GameSetupView(modeID: .challenge)
        }
    }
    .preferredColorScheme(.light)
}

// MARK: - 4. Game Setup – Precision

#Preview("4 – Setup: Precision") {
    NavigationStack {
        PreviewHost {
            GameSetupView(modeID: .precision)
        }
    }
    .preferredColorScheme(.light)
}

// MARK: - 5. Game HUD

#Preview("5 – Game HUD") {
    GameHUD(
        score: 14_280,
        personalBest: 22_100,
        elapsedSeconds: 97,
        sessionDuration: .minutes(5),
        modeName: "Zen Stacking",
        nextPiece: Tetromino(shape: .t)
    )
    .preferredColorScheme(.light)
}

// MARK: - 6. Control Bar

#Preview("6 – Control Bar") {
    ControlBar(
        onUndo: {},
        onHint: {},
        onRotateLeft: {},
        onRotateRight: {},
        onPause: {}
    )
    .preferredColorScheme(.light)
}

// MARK: - 7. Pause Overlay

#Preview("7 – Pause") {
    PreviewHost {
        PauseView(
            modeName: "Zen Stacking",
            score: 14_280,
            onResume: {},
            onQuit: {}
        )
    }
    .preferredColorScheme(.light)
}

// MARK: - 8. Game Over

#Preview("8 – Game Over") {
    PreviewHost {
        GameOverView(
            score: 18_420,
            personalBest: 22_100,
            modeName: "Zen Stacking",
            isSessionEnd: false,
            onRestart: {},
            onQuit: {},
            onLeaderboard: {}
        )
    }
    .preferredColorScheme(.light)
}

// MARK: - 9. Game Over – New Best

#Preview("9 – Game Over New Best") {
    PreviewHost {
        GameOverView(
            score: 25_000,
            personalBest: 22_100,
            modeName: "Blitz",
            isSessionEnd: false,
            onRestart: {},
            onQuit: {},
            onLeaderboard: {}
        )
    }
    .preferredColorScheme(.light)
}

// MARK: - 10. Session Complete

#Preview("10 – Session Complete") {
    PreviewHost {
        GameOverView(
            score: 9_400,
            personalBest: 22_100,
            modeName: "Time Attack",
            isSessionEnd: true,
            onRestart: {},
            onQuit: {}
        )
    }
    .preferredColorScheme(.light)
}

// MARK: - 11. Challenge Summary – Success

#Preview("11 – Challenge Success") {
    PreviewHost {
        ChallengeSummaryView(
            result: .success,
            levelNumber: 7,
            score: 3_200,
            onNext: {},
            onRetry: {},
            onQuit: {}
        )
    }
    .preferredColorScheme(.light)
}

// MARK: - 12. Challenge Summary – Failure

#Preview("12 – Challenge Failure") {
    PreviewHost {
        ChallengeSummaryView(
            result: .failure(reason: "Stack exceeded 12 rows"),
            levelNumber: 7,
            score: 1_800,
            onNext: {},
            onRetry: {},
            onQuit: {}
        )
    }
    .preferredColorScheme(.light)
}

// MARK: - 13. Tutorial Sheet

#Preview("13 – Tutorial") {
    PreviewHost {
        TutorialSheet(modeID: .zenStacking, onDismiss: {})
    }
    .preferredColorScheme(.light)
}

// MARK: - 14. Paywall

#Preview("14 – Paywall") {
    PreviewHost {
        PaywallView()
    }
    .preferredColorScheme(.light)
}

// MARK: - 15. Settings

#Preview("15 – Settings") {
    NavigationStack {
        PreviewHost {
            SettingsView()
        }
    }
    .preferredColorScheme(.light)
}

// MARK: - 16. Delete Account Sheet

#Preview("16 – Delete Account") {
    DeleteAccountSheet(
        onDelete: {},
        onCancel: {}
    )
    .preferredColorScheme(.light)
}

// MARK: - 17. Pace Section

private struct PaceLightPreview: View {
    @State private var pace: GameConfig.Pace = .autoFall
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 8) {
                PreGameSectionLabel(text: "PACE")
                PaceSection(pace: $pace)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview("17 – Pace Section") {
    PaceLightPreview()
}

// MARK: - 18. Speed Section

private struct SpeedLightPreview: View {
    @State private var speed: GameConfig.AutoFallSpeed = .classic
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 8) {
                PreGameSectionLabel(text: "SPEED")
                SpeedSection(speed: $speed)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview("18 – Speed Section") {
    SpeedLightPreview()
}

// MARK: - 19. Session Section

private struct SessionLightPreview: View {
    @State private var duration: GameConfig.SessionDuration = .unlimited
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 8) {
                PreGameSectionLabel(text: "SESSION")
                SessionSection(duration: $duration)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview("19 – Session Section") {
    SessionLightPreview()
}

// MARK: - 20. Primary Button

#Preview("20 – Primary Button") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        VStack(spacing: 16) {
            TumbloxPrimaryButton(title: "Play", showArrow: true, action: {})
            TumbloxPrimaryButton(title: "Resume", showArrow: false, action: {})
        }
        .padding(.horizontal, 16)
    }
    .preferredColorScheme(.light)
}

// MARK: - 21. Challenge Hero Card

#Preview("21 – Challenge Hero Card") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        PreviewHost {
            ChallengeHeroCard(
                currentLevel: 7,
                totalLevels: 100,
                progress: 0.06
            )
            .padding(.horizontal, 16)
        }
    }
    .preferredColorScheme(.light)
}

// MARK: - 22. Mode Row

#Preview("22 – Mode Rows") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        PreviewHost {
            VStack(spacing: 1) {
                ModeRow(mode: GameMode.mode(for: .zenStacking), isActive: true, isLocked: false, personalBest: 18_420, onTap: {})
                ModeRow(mode: GameMode.mode(for: .precision), isActive: false, isLocked: false, personalBest: 4_750, onTap: {})
                ModeRow(mode: GameMode.mode(for: .sprint), isActive: false, isLocked: true, personalBest: nil, onTap: {})
            }
            .padding(.horizontal, 16)
        }
    }
    .preferredColorScheme(.light)
}
