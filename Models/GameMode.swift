import Foundation

enum GameModeID: String, Codable, CaseIterable, Hashable {
    case challenge
    case zenStacking
    case precision
    case sprint
    case timeAttack
    case survival
    case marathon
    case blitz
    case puzzle
    case creative
}

struct GameMode: Identifiable {
    let id: GameModeID
    let name: String
    let description: String
    let requiresPurchase: Bool
    let supportsAutoFall: Bool

    static let all: [GameMode] = [
        GameMode(id: .challenge,    name: "Challenge",     description: "Progress through 100 curated levels",       requiresPurchase: false, supportsAutoFall: true),
        GameMode(id: .zenStacking,  name: "Zen Stacking",  description: "Freeform stacking, no pressure",            requiresPurchase: false, supportsAutoFall: true),
        GameMode(id: .precision,    name: "Precision",     description: "Earn points for center-column placements",   requiresPurchase: false, supportsAutoFall: true),
        GameMode(id: .sprint,       name: "Sprint",        description: "Clear 40 lines as fast as possible",        requiresPurchase: true,  supportsAutoFall: true),
        GameMode(id: .timeAttack,   name: "Time Attack",   description: "Max score before the clock runs out",       requiresPurchase: true,  supportsAutoFall: true),
        GameMode(id: .survival,     name: "Survival",      description: "Speed increases every 30 seconds",          requiresPurchase: true,  supportsAutoFall: true),
        GameMode(id: .marathon,     name: "Marathon",      description: "Endurance run — no time limit",             requiresPurchase: true,  supportsAutoFall: true),
        GameMode(id: .blitz,        name: "Blitz",         description: "2-minute all-out scoring frenzy",           requiresPurchase: true,  supportsAutoFall: true),
        GameMode(id: .puzzle,       name: "Puzzle",        description: "Place pieces to match the target pattern",  requiresPurchase: true,  supportsAutoFall: false),
        GameMode(id: .creative,     name: "Creative",      description: "Unlimited undo — build anything you want",  requiresPurchase: true,  supportsAutoFall: false),
    ]

    static var freeRowModes: [GameMode] {
        all.filter { !$0.requiresPurchase && $0.id != .challenge }
    }

    static var paidModes: [GameMode] {
        all.filter { $0.requiresPurchase }
    }

    static func mode(for id: GameModeID) -> GameMode {
        all.first { $0.id == id }!
    }
}
