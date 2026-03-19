import SwiftUI

struct ModeSelectView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: TumbloxSpacing.sectionGap) {
                header
                challengeSection
                freeModesSection
                if !GameMode.paidModes.isEmpty {
                    lockedModesSection
                }
            }
            .padding(.bottom, 32)
        }
        .background(TumbloxColors.background(colorScheme).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Tumblox")
                .font(TumbloxTypography.wordmark)
                .foregroundColor(TumbloxColors.textPrimary(colorScheme))
            Spacer()
            Button {
                appState.navigate(to: .settings)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(TumbloxColors.textSecondary(colorScheme))
            }
        }
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        .padding(.top, 12)
    }

    // MARK: - Challenge Section

    private var challengeSection: some View {
        Button {
            appState.navigate(to: .gameSetup(.challenge))
        } label: {
            ChallengeHeroCard(
                currentLevel: appState.userProgress.challengeLevel,
                totalLevels: ChallengeLevel.all.count,
                progress: appState.userProgress.challengeProgress
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Free Modes

    private var freeModesSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(GameMode.freeRowModes.enumerated()), id: \.element.id) { index, mode in
                ModeRow(
                    mode: mode,
                    isActive: false,
                    isLocked: false,
                    personalBest: appState.personalBest(for: mode.id)
                ) {
                    appState.navigate(to: .gameSetup(mode.id))
                }
                if index < GameMode.freeRowModes.count - 1 {
                    Divider()
                        .padding(.leading, TumbloxSpacing.screenHorizontal + TumbloxSpacing.accentBarWidth)
                        .foregroundColor(TumbloxColors.divider(colorScheme))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: TumbloxSpacing.cardRadius, style: .continuous))
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }

    // MARK: - Locked Modes

    private var lockedModesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FULL GAME")
                .font(TumbloxTypography.sectionEyebrow)
                .kerning(2.5)
                .foregroundColor(TumbloxColors.textMuted(colorScheme))
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)

            VStack(spacing: 0) {
                ForEach(Array(GameMode.paidModes.enumerated()), id: \.element.id) { index, mode in
                    let unlocked = appState.isModeUnlocked(mode.id)
                    ModeRow(
                        mode: mode,
                        isActive: false,
                        isLocked: !unlocked,
                        personalBest: unlocked ? appState.personalBest(for: mode.id) : nil
                    ) {
                        if unlocked {
                            appState.navigate(to: .gameSetup(mode.id))
                        } else {
                            appState.navigate(to: .paywall)
                        }
                    }
                    if index < GameMode.paidModes.count - 1 {
                        Divider()
                            .padding(.leading, TumbloxSpacing.screenHorizontal + TumbloxSpacing.accentBarWidth)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: TumbloxSpacing.cardRadius, style: .continuous))
            .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        }
    }
}
