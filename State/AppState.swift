import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var userProgress: UserProgress
    @Published var pendingGameConfig: GameConfig?

    let progressService = UserProgressService()
    let entitlementManager: EntitlementManager
    let gameCenterService = GameCenterService()

    init() {
        let progress = UserProgressService().load()
        self.userProgress = progress
        self.entitlementManager = EntitlementManager()
        Task { await entitlementManager.refreshEntitlements() }
        gameCenterService.authenticate()
    }

    // MARK: - Navigation

    func navigate(to route: AppRoute) {
        navigationPath.append(route)
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }

    // MARK: - Progress helpers

    func isModeUnlocked(_ id: GameModeID) -> Bool {
        if GameMode.mode(for: id).requiresPurchase {
            return entitlementManager.isUnlocked
        }
        return true
    }

    func personalBest(for id: GameModeID) -> Int? {
        userProgress.personalBests[id]
    }

    func updatePersonalBest(_ score: Int, for id: GameModeID, elapsedSeconds: Int = 0) {
        let current = userProgress.personalBests[id] ?? 0
        let isNewBest = score > current
        if isNewBest {
            userProgress.personalBests[id] = score
            progressService.save(userProgress)
        }
        // Always submit — Game Center keeps its own best-score logic
        Task { await gameCenterService.submitScore(score, for: id, elapsedSeconds: elapsedSeconds) }
    }

    func markModeAsPlayed(_ id: GameModeID) {
        if userProgress.modesFirstPlayed[id] == nil {
            userProgress.modesFirstPlayed[id] = Date()
            progressService.save(userProgress)
        }
    }

    func hasSeenTutorial(for id: GameModeID) -> Bool {
        userProgress.modesFirstPlayed[id] != nil
    }

    // MARK: - Challenge

    func advanceChallengeLevel() {
        userProgress.challengeLevel = min(userProgress.challengeLevel + 1, ChallengeLevel.all.count)
        progressService.save(userProgress)
    }

    func markChallengeCompleted(_ levelNumber: Int) {
        userProgress.challengeCompleted.insert(levelNumber)
        advanceChallengeLevel()
    }
}
