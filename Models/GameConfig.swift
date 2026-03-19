import Foundation

struct GameConfig {
    var modeID: GameModeID
    var pace: Pace
    var autoFallSpeed: AutoFallSpeed
    var sessionDuration: SessionDuration
    var modifiers: GameModifiers
    var challengeLevel: Int         // 1–100; only used when modeID == .challenge

    init(modeID: GameModeID, challengeLevel: Int = 1) {
        self.modeID = modeID
        self.pace = .autoFall
        self.autoFallSpeed = .classic
        self.sessionDuration = .unlimited
        self.modifiers = GameModifiers()
        self.challengeLevel = challengeLevel
    }

    // MARK: - Pace

    enum Pace: String, CaseIterable, Codable {
        case manualDrop
        case autoFall

        var displayName: String {
            switch self {
            case .manualDrop: return "Manual Drop"
            case .autoFall:   return "Auto Fall"
            }
        }

        var description: String {
            switch self {
            case .manualDrop: return "Pieces only fall when you tap"
            case .autoFall:   return "Pieces fall at a set speed"
            }
        }
    }

    // MARK: - Auto Fall Speed

    enum AutoFallSpeed: String, CaseIterable, Codable {
        case gentle
        case classic
        case swift
        case rapid

        var displayName: String {
            switch self {
            case .gentle:  return "Gentle"
            case .classic: return "Classic"
            case .swift:   return "Swift"
            case .rapid:   return "Rapid"
            }
        }

        /// Seconds per row drop
        var interval: TimeInterval {
            switch self {
            case .gentle:  return 1.2
            case .classic: return 0.8
            case .swift:   return 0.5
            case .rapid:   return 0.3
            }
        }
    }

    // MARK: - Session Duration

    enum SessionDuration: Equatable, Codable {
        case unlimited
        case minutes(Int)

        static var presets: [SessionDuration] {
            [.unlimited, .minutes(5), .minutes(10), .minutes(20)]
        }

        var displayName: String {
            switch self {
            case .unlimited:     return "∞"
            case .minutes(let m): return "\(m)m"
            }
        }

        var seconds: TimeInterval? {
            switch self {
            case .unlimited:     return nil
            case .minutes(let m): return TimeInterval(m * 60)
            }
        }
    }
}

// MARK: - Modifiers

struct GameModifiers: Codable {
    var ghostPieceEnabled: Bool = true
    var showNextPiece: Bool = true
    var hapticFeedback: Bool = true
}
