import GameKit
import SwiftUI

// MARK: - Leaderboard IDs

enum LeaderboardID: String {
    case zenStacking  = "com.tumblox.leaderboard.zen"
    case precision    = "com.tumblox.leaderboard.precision"
    case sprint       = "com.tumblox.leaderboard.sprint"       // time (lower = better)
    case timeAttack   = "com.tumblox.leaderboard.timeattack"
    case survival     = "com.tumblox.leaderboard.survival"
    case marathon     = "com.tumblox.leaderboard.marathon"
    case blitz        = "com.tumblox.leaderboard.blitz"

    static func id(for modeID: GameModeID) -> LeaderboardID? {
        switch modeID {
        case .zenStacking:  return .zenStacking
        case .precision:    return .precision
        case .sprint:       return .sprint
        case .timeAttack:   return .timeAttack
        case .survival:     return .survival
        case .marathon:     return .marathon
        case .blitz:        return .blitz
        case .challenge, .puzzle, .creative: return nil
        }
    }

    /// Sprint leaderboard is time-based (lower score = better)
    var isTimeBased: Bool { self == .sprint }
}

// MARK: - Game Center Service

@MainActor
final class GameCenterService: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published var showLeaderboard = false

    private var pendingLeaderboardID: String? = nil

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }
            if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
        }
    }

    // MARK: - Submit score

    func submitScore(_ score: Int, for modeID: GameModeID, elapsedSeconds: Int = 0) async {
        guard isAuthenticated,
              let leaderboard = LeaderboardID.id(for: modeID) else { return }

        // Sprint uses time in milliseconds (lower = better), others use raw score
        let value = leaderboard.isTimeBased
            ? elapsedSeconds * 1000
            : score

        do {
            try await GKLeaderboard.submitScore(
                value,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [leaderboard.rawValue]
            )
        } catch {
            // Non-fatal — score submission failure should not surface to user
        }
    }

    // MARK: - Show leaderboard

    func presentLeaderboard(for modeID: GameModeID) {
        guard let leaderboard = LeaderboardID.id(for: modeID) else { return }
        pendingLeaderboardID = leaderboard.rawValue
        showLeaderboard = true
    }
}

// MARK: - GameKit View Representable

struct GameCenterLeaderboardView: UIViewControllerRepresentable {
    let leaderboardID: String
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let vc = GKGameCenterViewController(
            leaderboardID: leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        vc.gameCenterDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, GKGameCenterControllerDelegate {
        let parent: GameCenterLeaderboardView
        init(_ parent: GameCenterLeaderboardView) { self.parent = parent }

        func gameCenterViewControllerDidFinish(_ controller: GKGameCenterViewController) {
            parent.isPresented = false
        }
    }
}
