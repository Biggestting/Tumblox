import Foundation

// MARK: - UserSettings

struct UserSettings: Codable {
    enum AppTheme: Int, Codable, CaseIterable {
        case system = 0
        case light  = 1
        case dark   = 2

        var displayName: String {
            switch self {
            case .system: return "System"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }
    }

    var theme: AppTheme = .system
    var preferredAutoFallSpeed: GameConfig.AutoFallSpeed = .classic
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
}

// MARK: - UserProgress

struct UserProgress: Codable {
    var settings: UserSettings = UserSettings()
    var personalBests: [GameModeID: Int] = [:]
    var modesFirstPlayed: [GameModeID: Date] = [:]
    var challengeLevel: Int = 1
    var challengeCompleted: Set<Int> = []

    var challengeProgress: Double {
        Double(challengeLevel - 1) / Double(ChallengeLevel.all.count)
    }
}
