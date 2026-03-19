import Foundation

// MARK: - Challenge Condition

enum ChallengeCondition: Codable, Equatable {
    case stackHeight(max: Int)
    case clearLines(count: Int)
    case placeWithinTime(pieces: Int, seconds: Int)
    case scoreAtLeast(Int)
    case noLineClears
    case fillColumns(columns: [Int])
    case surviveSeconds(Int)
    case useOnlyShape(TetrominoShape)
    case keepCenterClear
    case maxHeight(rows: Int)
    case clearWithTetris(count: Int)
    case buildPyramid
}

// MARK: - Challenge Tier

enum ChallengeTier: String, Codable {
    case introduction   // 1–10
    case fundamentals   // 11–20
    case precision      // 21–30
    case endurance      // 31–40
    case master         // 41–50
    case expert         // 51–60
    case elite          // 61–70
    case grandmaster    // 71–80
    case zenith         // 81–100

    static func tier(for level: Int) -> ChallengeTier {
        switch level {
        case 1...10:  return .introduction
        case 11...20: return .fundamentals
        case 21...30: return .precision
        case 31...40: return .endurance
        case 41...50: return .master
        case 51...60: return .expert
        case 61...70: return .elite
        case 71...80: return .grandmaster
        default:      return .zenith
        }
    }

    var displayName: String { rawValue.capitalized }
}

// MARK: - Challenge Level

struct ChallengeLevel: Identifiable, Codable {
    let number: Int
    let tier: ChallengeTier
    let title: String
    let objective: String
    let condition: ChallengeCondition
    let starThreshold: Int?  // score needed for 3 stars (nil = completion only)

    var id: Int { number }

    static let all: [ChallengeLevel] = catalogue
}

// MARK: - Catalogue (1–31 implemented, 32–100 stubs)

private let catalogue: [ChallengeLevel] = [
    ChallengeLevel(number: 1,  tier: .introduction, title: "First Stack",       objective: "Stack pieces to a height of 8",         condition: .stackHeight(max: 8),            starThreshold: nil),
    ChallengeLevel(number: 2,  tier: .introduction, title: "Line Up",           objective: "Clear 3 lines",                         condition: .clearLines(count: 3),           starThreshold: 500),
    ChallengeLevel(number: 3,  tier: .introduction, title: "Speed Drill",       objective: "Place 10 pieces within 30 seconds",     condition: .placeWithinTime(pieces: 10, seconds: 30), starThreshold: nil),
    ChallengeLevel(number: 4,  tier: .introduction, title: "Score Rush",        objective: "Score at least 800 points",             condition: .scoreAtLeast(800),              starThreshold: 1200),
    ChallengeLevel(number: 5,  tier: .introduction, title: "Hold the Line",     objective: "Survive for 60 seconds",                condition: .surviveSeconds(60),             starThreshold: nil),
    ChallengeLevel(number: 6,  tier: .introduction, title: "Column Filler",     objective: "Fill columns 1, 5, and 9",              condition: .fillColumns(columns: [1,5,9]),  starThreshold: nil),
    ChallengeLevel(number: 7,  tier: .introduction, title: "Clean Slate",       objective: "Clear 5 lines",                         condition: .clearLines(count: 5),           starThreshold: 800),
    ChallengeLevel(number: 8,  tier: .introduction, title: "Low Profile",       objective: "Keep max height under 6 for 90 seconds", condition: .maxHeight(rows: 6),            starThreshold: nil),
    ChallengeLevel(number: 9,  tier: .introduction, title: "Tetromino Test",    objective: "Score 1,200 points",                    condition: .scoreAtLeast(1200),             starThreshold: 1800),
    ChallengeLevel(number: 10, tier: .introduction, title: "Graduate",          objective: "Clear 10 lines",                        condition: .clearLines(count: 10),          starThreshold: 1500),
    ChallengeLevel(number: 11, tier: .fundamentals, title: "Precision Placer",  objective: "Place 20 pieces within 45 seconds",     condition: .placeWithinTime(pieces: 20, seconds: 45), starThreshold: nil),
    ChallengeLevel(number: 12, tier: .fundamentals, title: "Stack Master",      objective: "Keep height under 8, score 1,000",      condition: .scoreAtLeast(1000),             starThreshold: 1500),
    ChallengeLevel(number: 13, tier: .fundamentals, title: "Tetris Time",       objective: "Clear 1 Tetris (4 lines at once)",      condition: .clearWithTetris(count: 1),      starThreshold: nil),
    ChallengeLevel(number: 14, tier: .fundamentals, title: "No Clear Zone",     objective: "Place 15 pieces without clearing",      condition: .noLineClears,                   starThreshold: nil),
    ChallengeLevel(number: 15, tier: .fundamentals, title: "Endure",            objective: "Survive 2 minutes",                     condition: .surviveSeconds(120),            starThreshold: nil),
    ChallengeLevel(number: 16, tier: .fundamentals, title: "Column Work",       objective: "Fill columns 3, 5, and 7",              condition: .fillColumns(columns: [3,5,7]),  starThreshold: nil),
    ChallengeLevel(number: 17, tier: .fundamentals, title: "Score Surge",       objective: "Score 2,000 points",                    condition: .scoreAtLeast(2000),             starThreshold: 3000),
    ChallengeLevel(number: 18, tier: .fundamentals, title: "Line Burst",        objective: "Clear 15 lines",                        condition: .clearLines(count: 15),          starThreshold: 2500),
    ChallengeLevel(number: 19, tier: .fundamentals, title: "S Specialist",      objective: "Place 10 S-pieces perfectly",           condition: .useOnlyShape(.s),               starThreshold: nil),
    ChallengeLevel(number: 20, tier: .fundamentals, title: "Fundamentals",      objective: "Score 3,000 points",                    condition: .scoreAtLeast(3000),             starThreshold: 4500),
    ChallengeLevel(number: 21, tier: .precision,    title: "Center Stage",      objective: "Keep the center column clear",          condition: .keepCenterClear,                starThreshold: nil),
    ChallengeLevel(number: 22, tier: .precision,    title: "Double Tetris",     objective: "Clear 2 Tetrises",                      condition: .clearWithTetris(count: 2),      starThreshold: nil),
    ChallengeLevel(number: 23, tier: .precision,    title: "Speed Run",         objective: "Place 30 pieces within 60 seconds",     condition: .placeWithinTime(pieces: 30, seconds: 60), starThreshold: nil),
    ChallengeLevel(number: 24, tier: .precision,    title: "Pyramid",           objective: "Build a perfect pyramid shape",         condition: .buildPyramid,                   starThreshold: nil),
    ChallengeLevel(number: 25, tier: .precision,    title: "High Score",        objective: "Score 5,000 points",                    condition: .scoreAtLeast(5000),             starThreshold: 7500),
    ChallengeLevel(number: 26, tier: .precision,    title: "Low Rider",         objective: "Stay under height 5 for 3 minutes",     condition: .maxHeight(rows: 5),             starThreshold: nil),
    ChallengeLevel(number: 27, tier: .precision,    title: "Clean Sweep",       objective: "Clear 20 lines",                        condition: .clearLines(count: 20),          starThreshold: 4000),
    ChallengeLevel(number: 28, tier: .precision,    title: "I-Beam Only",       objective: "Use only I-pieces for 30 placements",   condition: .useOnlyShape(.i),               starThreshold: nil),
    ChallengeLevel(number: 29, tier: .precision,    title: "Survive 4 Min",     objective: "Survive 4 minutes",                     condition: .surviveSeconds(240),            starThreshold: nil),
    ChallengeLevel(number: 30, tier: .precision,    title: "Precision Master",  objective: "Score 7,000 points",                    condition: .scoreAtLeast(7000),             starThreshold: 10000),
    ChallengeLevel(number: 31, tier: .endurance,    title: "Marathon Start",    objective: "Clear 30 lines",                        condition: .clearLines(count: 30),          starThreshold: 6000),
] + (32...100).map { n in
    ChallengeLevel(
        number: n,
        tier: ChallengeTier.tier(for: n),
        title: "Level \(n)",
        objective: "Complete level \(n)",
        condition: .scoreAtLeast(n * 500),
        starThreshold: n * 750
    )
}
