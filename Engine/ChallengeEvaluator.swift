import Foundation

// MARK: - Challenge Result

enum ChallengeResult {
    case incomplete
    case success
    case failure(reason: String)
}

// MARK: - Challenge Snapshot

/// Point-in-time game state snapshot fed to the evaluator.
struct GameSnapshot {
    let score: Int
    let linesCleared: Int
    let elapsedSeconds: Int
    let piecesPlaced: Int
    let stackHeight: Int
    let maxHeightEver: Int          // highest the stack reached during the session
    let grid: [[GridCell]]
    let lastPieceShape: TetrominoShape?
    let lastClearCount: Int         // lines cleared on the most recent lock (0 if no clear)
    let tetrisCount: Int            // cumulative 4-line clears
    let centerColumnEverOccupied: Bool
    let pyramidBuilt: Bool
}

// MARK: - Evaluator

struct ChallengeEvaluator {

    /// Call after every piece lock. Returns `.incomplete` until the condition is definitively met or broken.
    static func evaluate(
        condition: ChallengeCondition,
        snapshot: GameSnapshot,
        phase: GamePhase
    ) -> ChallengeResult {
        switch condition {

        // Stack must never exceed maxHeight during the session
        case .stackHeight(let max):
            if snapshot.maxHeightEver > max {
                return .failure(reason: "Stack exceeded \(max) rows")
            }
            if phase == .gameOver || phase == .sessionComplete {
                return .success
            }
            return .incomplete

        // Clear N lines total
        case .clearLines(let count):
            if snapshot.linesCleared >= count { return .success }
            if phase == .gameOver { return .failure(reason: "Not enough lines cleared") }
            return .incomplete

        // Place N pieces within T seconds
        case .placeWithinTime(let pieces, let seconds):
            if snapshot.piecesPlaced >= pieces && snapshot.elapsedSeconds <= seconds {
                return .success
            }
            if snapshot.elapsedSeconds > seconds {
                return .failure(reason: "Time ran out")
            }
            return .incomplete

        // Reach target score
        case .scoreAtLeast(let target):
            if snapshot.score >= target { return .success }
            if phase == .gameOver { return .failure(reason: "Score too low") }
            return .incomplete

        // Place pieces without clearing any lines
        case .noLineClears:
            if snapshot.linesCleared > 0 {
                return .failure(reason: "A line was cleared")
            }
            if phase == .gameOver || phase == .sessionComplete {
                return .success
            }
            return .incomplete

        // Fill specific columns to the top of any row
        case .fillColumns(let columns):
            if allColumnsFilled(columns, grid: snapshot.grid) { return .success }
            if phase == .gameOver { return .failure(reason: "Columns not fully filled") }
            return .incomplete

        // Survive for N seconds
        case .surviveSeconds(let seconds):
            if snapshot.elapsedSeconds >= seconds && phase == .playing { return .success }
            if phase == .gameOver { return .failure(reason: "Game ended before time") }
            return .incomplete

        // Only one shape allowed (checked via last placed piece shape)
        case .useOnlyShape(let shape):
            if let last = snapshot.lastPieceShape, last != shape {
                return .failure(reason: "Wrong piece used")
            }
            if phase == .gameOver || phase == .sessionComplete {
                return .success
            }
            return .incomplete

        // Center column (index 4 or 5) must never be occupied
        case .keepCenterClear:
            if snapshot.centerColumnEverOccupied {
                return .failure(reason: "Center column was occupied")
            }
            if phase == .gameOver || phase == .sessionComplete {
                return .success
            }
            return .incomplete

        // Max height must never exceed N rows
        case .maxHeight(let rows):
            if snapshot.maxHeightEver > rows {
                return .failure(reason: "Stack too tall")
            }
            if phase == .gameOver || phase == .sessionComplete {
                return .success
            }
            return .incomplete

        // Achieve N 4-line clears
        case .clearWithTetris(let count):
            if snapshot.tetrisCount >= count { return .success }
            if phase == .gameOver { return .failure(reason: "Not enough Tetrises") }
            return .incomplete

        // Pyramid shape detected
        case .buildPyramid:
            if snapshot.pyramidBuilt { return .success }
            if phase == .gameOver { return .failure(reason: "Pyramid not built") }
            return .incomplete
        }
    }

    // MARK: - Grid helpers

    private static func allColumnsFilled(_ columns: [Int], grid: [[GridCell]]) -> Bool {
        columns.allSatisfy { col in
            guard col < GameEngine.columns else { return false }
            return grid.contains { row in
                if case .filled = row[col] { return true }
                return false
            }
        }
    }
}

// MARK: - Pyramid detector

extension ChallengeEvaluator {
    /// Checks for a pyramid: each row above the base must be strictly narrower and centered.
    static func detectPyramid(in grid: [[GridCell]]) -> Bool {
        var rowWidths: [Int] = []
        var lastFilledRow = -1

        for (rowIdx, row) in grid.enumerated().reversed() {
            let filled = row.enumerated().compactMap { $0.element.isEmpty ? nil : $0.offset }
            if filled.isEmpty { continue }
            let width = (filled.last! - filled.first!) + 1
            rowWidths.append(width)
            lastFilledRow = rowIdx
        }

        guard rowWidths.count >= 3 else { return false }
        // Each successive row must be strictly narrower
        for i in 1..<rowWidths.count {
            if rowWidths[i] >= rowWidths[i - 1] { return false }
        }
        return true
    }
}
