import SwiftUI

struct GameSetupView: View {
    let modeID: GameModeID
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    @State private var config: GameConfig
    @State private var showTutorial = false

    init(modeID: GameModeID) {
        self.modeID = modeID
        _config = State(initialValue: GameConfig(modeID: modeID))
    }

    private var mode: GameMode { GameMode.mode(for: modeID) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: TumbloxSpacing.sectionGap) {
                // Mode title
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.name)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                    Text(mode.description)
                        .font(TumbloxTypography.caption)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                }
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
                .padding(.top, 8)

                // Pace
                VStack(alignment: .leading, spacing: 8) {
                    PreGameSectionLabel(text: "PACE")
                    PaceSection(pace: $config.pace)
                }

                // Speed (only when auto fall)
                if config.pace == .autoFall && mode.supportsAutoFall {
                    VStack(alignment: .leading, spacing: 8) {
                        PreGameSectionLabel(text: "SPEED")
                        SpeedSection(speed: $config.autoFallSpeed)
                    }
                }

                // Session
                VStack(alignment: .leading, spacing: 8) {
                    PreGameSectionLabel(text: "SESSION")
                    SessionSection(duration: $config.sessionDuration)
                }

                // Modifiers
                VStack(alignment: .leading, spacing: 8) {
                    PreGameSectionLabel(text: "OPTIONS")
                    ModifiersSection(modifiers: $config.modifiers)
                }

                // Play button
                TumbloxPrimaryButton(title: "Play", showArrow: true) {
                    var finalConfig = config
                    if modeID == .challenge {
                        finalConfig.challengeLevel = appState.userProgress.challengeLevel
                    }
                    appState.pendingGameConfig = finalConfig
                    if appState.hasSeenTutorial(for: modeID) {
                        appState.markModeAsPlayed(modeID)
                        appState.navigate(to: .game)
                    } else {
                        showTutorial = true
                    }
                }
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .background(TumbloxColors.background(colorScheme).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showTutorial) {
            TutorialSheet(modeID: modeID) {
                showTutorial = false
                appState.markModeAsPlayed(modeID)
                appState.navigate(to: .game)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

private struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(TumbloxTypography.body)
            }
            .foregroundColor(TumbloxColors.accent(colorScheme))
        }
    }
}

// MARK: - Preview

#Preview("Zen Stacking – Dark") {
    NavigationStack {
        PreviewHost {
            GameSetupView(modeID: .zenStacking)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Challenge – Dark") {
    NavigationStack {
        PreviewHost {
            GameSetupView(modeID: .challenge)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Zen Stacking – Light") {
    NavigationStack {
        PreviewHost {
            GameSetupView(modeID: .zenStacking)
        }
    }
    .preferredColorScheme(.light)
}
