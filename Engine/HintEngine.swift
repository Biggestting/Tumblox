import Foundation

// MARK: - Hint Result

struct HintPlacement: Equatable {
    let col: Int
    let rotation: Int
    let cells: [(col: Int, row: Int)]
}

// MARK: - Hint Engine

/// Computes the best placement for the active piece using a weighted heuristic.
/// Weights derived from Dellacherie's algorithm.
struct HintEngine {

    // MARK: - Weights

    private static let weightLinesCleared:  Double = 3.4
    private static let weightHoles:         Double = -3.0
    private static let weightAggHeight:     Double = -0.5
    private static let weightBumpiness:     Double = -0.2

    // MARK: - Public API

    static func bestPlacement(
        piece: Tetromino,
        grid: [[GridCell]]
    ) -> HintPlacement? {
        var bestScore = Double(-Int.max)
        var bestPlacement: HintPlacement? = nil

        let rotationCount = piece.shape.rotationStates.count

        for rotation in 0..<rotationCount {
            var rotated = piece
            rotated.rotation = rotation

            for col in -2..<(GameEngine.columns + 2) {
                rotated.col = col

                // Skip invalid horizontal positions
                guard isHorizontallyValid(rotated) else { continue }

                // Drop to lowest valid row
                guard let dropped = drop(rotated, into: grid) else { continue }

                // Score this placement
                let score = evaluate(piece: dropped, grid: grid)
                if score > bestScore {
                    bestScore = score
                    bestPlacement = HintPlacement(
                        col: dropped.col,
                        rotation: rotation,
                        cells: dropped.cells
                    )
                }
            }
        }

        return bestPlacement
    }

    // MARK: - Drop simulation

    private static func drop(_ piece: Tetromino, into grid: [[GridCell]]) -> Tetromino? {
        var current = piece
        while true {
            var next = current
            next.row += 1
            if isValid(next, in: grid) {
                current = next
            } else {
                break
            }
        }
        // Ensure at least one cell is on the board
        guard current.cells.contains(where: { $0.row >= 0 }) else { return nil }
        return current
    }

    // MARK: - Heuristic evaluation

    private static func evaluate(piece: Tetromino, grid: [[GridCell]]) -> Double {
        var testGrid = grid

        // Place piece into test grid
        for cell in piece.cells {
            guard cell.row >= 0, cell.row < GameEngine.rows,
                  cell.col >= 0, cell.col < GameEngine.columns else { continue }
            testGrid[cell.row][cell.col] = .filled(.cyan)   // color irrelevant
        }

        let cleared = countClearedLines(in: testGrid)
        let holes   = countHoles(in: testGrid)
        let heights = columnHeights(in: testGrid)
        let aggH    = heights.reduce(0, +)
        let bump    = bumpiness(heights: heights)

        return weightLinesCleared  * Double(cleared)
             + weightHoles         * Double(holes)
             + weightAggHeight     * Double(aggH)
             + weightBumpiness     * Double(bump)
    }

    // MARK: - Grid metrics

    private static func countClearedLines(in grid: [[GridCell]]) -> Int {
        grid.filter { row in row.allSatisfy { !$0.isEmpty } }.count
    }

    private static func countHoles(in grid: [[GridCell]]) -> Int {
        var holes = 0
        for col in 0..<GameEngine.columns {
            var foundFilled = false
            for row in 0..<GameEngine.rows {
                if case .filled = grid[row][col] {
                    foundFilled = true
                } else if foundFilled {
                    holes += 1
                }
            }
        }
        return holes
    }

    private static func columnHeights(in grid: [[GridCell]]) -> [Int] {
        (0..<GameEngine.columns).map { col in
            for row in 0..<GameEngine.rows {
                if case .filled = grid[row][col] {
                    return GameEngine.rows - row
                }
            }
            return 0
        }
    }

    private static func bumpiness(heights: [Int]) -> Int {
        guard heights.count > 1 else { return 0 }
        return zip(heights, heights.dropFirst()).reduce(0) { acc, pair in
            acc + abs(pair.0 - pair.1)
        }
    }

    // MARK: - Validation

    private static func isHorizontallyValid(_ piece: Tetromino) -> Bool {
        piece.cells.allSatisfy { $0.col >= 0 && $0.col < GameEngine.columns }
    }

    private static func isValid(_ piece: Tetromino, in grid: [[GridCell]]) -> Bool {
        for cell in piece.cells {
            if cell.col < 0 || cell.col >= GameEngine.columns { return false }
            if cell.row >= GameEngine.rows { return false }
            if cell.row >= 0 && !grid[cell.row][cell.col].isEmpty { return false }
        }
        return true
    }
}
