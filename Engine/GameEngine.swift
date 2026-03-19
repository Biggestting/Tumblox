import Foundation
import Combine

// MARK: - Grid Cell

enum GridCell: Codable {
    case empty
    case filled(TileColor)

    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
}

// MARK: - Game Phase

enum GamePhase {
    case playing
    case paused
    case gameOver
    case sessionComplete
}

// MARK: - Game Engine

@MainActor
final class GameEngine: ObservableObject {
    // Grid constants
    static let columns = 10
    static let rows    = 20

    // MARK: - Published state

    @Published private(set) var grid: [[GridCell]]
    @Published private(set) var activePiece: Tetromino?
    @Published private(set) var nextPiece: Tetromino
    @Published private(set) var ghostRows: [Int] = []
    @Published private(set) var score: Int = 0
    @Published private(set) var linesCleared: Int = 0
    @Published private(set) var phase: GamePhase = .playing
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var hintPlacement: HintPlacement? = nil
    @Published private(set) var challengeResult: ChallengeResult = .incomplete

    // MARK: - Private

    private let config: GameConfig
    private var fallTask: Task<Void, Never>?
    private var clockTask: Task<Void, Never>?
    private var undoStack: [[[GridCell]]] = []
    private var hintTask: Task<Void, Never>? = nil
    private let maxUndos = 5

    // Challenge tracking
    private var piecesPlaced: Int = 0
    private var maxHeightEver: Int = 0
    private var tetrisCount: Int = 0
    private var lastPieceShape: TetrominoShape? = nil
    private var lastClearCount: Int = 0
    private var centerColumnEverOccupied: Bool = false
    private var pyramidBuilt: Bool = false

    // MARK: - Init

    init(config: GameConfig) {
        self.config = config
        self.grid = Array(repeating: Array(repeating: .empty, count: Self.columns), count: Self.rows)
        self.nextPiece = Tetromino.random()
        self.activePiece = nil
    }

    // MARK: - Lifecycle

    func startGame() {
        HapticService.shared.prepare()
        spawnPiece()
        startClock()
        if config.pace == .autoFall {
            startFallTimer()
        }
    }

    func pause() {
        guard phase == .playing else { return }
        phase = .paused
        fallTask?.cancel()
        clockTask?.cancel()
    }

    func resume() {
        guard phase == .paused else { return }
        phase = .playing
        startClock()
        if config.pace == .autoFall {
            startFallTimer()
        }
    }

    // MARK: - Player Input

    func moveLeft() {
        guard phase == .playing, var piece = activePiece else { return }
        piece.col -= 1
        if isValid(piece) {
            activePiece = piece
            updateGhost()
        }
    }

    func moveRight() {
        guard phase == .playing, var piece = activePiece else { return }
        piece.col += 1
        if isValid(piece) {
            activePiece = piece
            updateGhost()
        }
    }

    func rotate(clockwise: Bool = true) {
        guard phase == .playing, var piece = activePiece else { return }
        piece.rotate(clockwise: clockwise)
        // Wall kicks: try offsets 0, ±1, ±2
        let kicks = [0, -1, 1, -2, 2]
        for kick in kicks {
            var kicked = piece
            kicked.col += kick
            if isValid(kicked) {
                activePiece = kicked
                updateGhost()
                return
            }
        }
    }

    func softDrop() {
        guard phase == .playing else { return }
        dropOneRow()
    }

    func hardDrop() {
        guard phase == .playing, var piece = activePiece else { return }
        while true {
            var dropped = piece
            dropped.row += 1
            if isValid(dropped) {
                piece = dropped
            } else {
                break
            }
        }
        activePiece = piece
        lockPiece()
    }

    /// Manual drop — used in manualDrop pace mode (tap to drop one row)
    func manualTap() {
        guard config.pace == .manualDrop else { return }
        dropOneRow()
    }

    func undo() {
        guard !undoStack.isEmpty, phase == .playing else { return }
        grid = undoStack.removeLast()
        score = max(0, score - 50)
        hintPlacement = nil
    }

    func showHint() {
        guard phase == .playing, let piece = activePiece else { return }
        let capturedGrid = grid
        hintTask?.cancel()
        hintTask = Task.detached(priority: .userInitiated) {
            let result = HintEngine.bestPlacement(piece: piece, grid: capturedGrid)
            await MainActor.run {
                self.hintPlacement = result
                // Auto-clear after 2.5 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                    self.hintPlacement = nil
                }
            }
        }
    }

    func clearHint() {
        hintPlacement = nil
        hintTask?.cancel()
    }

    // MARK: - Fall timer

    private func startFallTimer() {
        let interval = config.autoFallSpeed.interval
        fallTask?.cancel()
        fallTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                guard !Task.isCancelled, let self else { break }
                self.dropOneRow()
            }
        }
    }

    private func startClock() {
        clockTask?.cancel()
        clockTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled, let self else { break }
                self.elapsedSeconds += 1
                if let limit = self.config.sessionDuration.seconds,
                   Double(self.elapsedSeconds) >= limit {
                    self.endSession()
                }
            }
        }
    }

    // MARK: - Core logic

    private func dropOneRow() {
        guard var piece = activePiece else { return }
        piece.row += 1
        if isValid(piece) {
            activePiece = piece
        } else {
            lockPiece()
        }
    }

    private func lockPiece() {
        guard let piece = activePiece else { return }

        // Save undo state
        undoStack.append(grid)
        if undoStack.count > maxUndos { undoStack.removeFirst() }

        // Write cells to grid
        for cell in piece.cells {
            guard cell.row >= 0, cell.row < Self.rows,
                  cell.col >= 0, cell.col < Self.columns else { continue }
            grid[cell.row][cell.col] = .filled(piece.shape.color)
        }

        HapticService.shared.pieceLock()

        // Check game over (piece locked above row 0)
        if piece.cells.allSatisfy({ $0.row < 0 }) {
            triggerGameOver()
            return
        }

        // Update challenge tracking stats
        piecesPlaced += 1
        lastPieceShape = piece.shape
        let h = stackHeight
        if h > maxHeightEver { maxHeightEver = h }
        let centerCols = [4, 5]
        if piece.cells.contains(where: { centerCols.contains($0.col) }) {
            centerColumnEverOccupied = true
        }

        activePiece = nil
        hintPlacement = nil
        hintTask?.cancel()
        clearLines()

        // Pyramid check (post-clear)
        if ChallengeEvaluator.detectPyramid(in: grid) { pyramidBuilt = true }

        evaluateChallenge()
        spawnPiece()
    }

    private func clearLines() {
        var cleared = 0
        var newGrid: [[GridCell]] = []
        for row in grid {
            if row.allSatisfy({ !$0.isEmpty }) {
                cleared += 1
            } else {
                newGrid.append(row)
            }
        }
        lastClearCount = cleared
        if cleared > 0 {
            let emptyRows = Array(
                repeating: Array(repeating: GridCell.empty, count: Self.columns),
                count: cleared
            )
            grid = emptyRows + newGrid
            linesCleared += cleared
            score += scoreForClear(cleared)
            if cleared == 4 { tetrisCount += 1 }
            HapticService.shared.lineClear(count: cleared)
        }
    }

    private func scoreForClear(_ count: Int) -> Int {
        switch count {
        case 1: return 100
        case 2: return 300
        case 3: return 500
        case 4: return 800  // Tetris
        default: return 800 + (count - 4) * 200
        }
    }

    private func spawnPiece() {
        var piece = nextPiece
        piece.col = (Self.columns - 4) / 2
        piece.row = 0
        nextPiece = Tetromino.random()

        if !isValid(piece) {
            triggerGameOver()
            return
        }
        activePiece = piece
        updateGhost()
    }

    private func updateGhost() {
        guard config.modifiers.ghostPieceEnabled, var piece = activePiece else {
            ghostRows = []
            return
        }
        while true {
            var dropped = piece
            dropped.row += 1
            if isValid(dropped) { piece = dropped } else { break }
        }
        ghostRows = piece.cells.map { $0.row }
    }

    private func isValid(_ piece: Tetromino) -> Bool {
        for cell in piece.cells {
            if cell.col < 0 || cell.col >= Self.columns { return false }
            if cell.row >= Self.rows { return false }
            if cell.row >= 0 && !grid[cell.row][cell.col].isEmpty { return false }
        }
        return true
    }

    private func evaluateChallenge() {
        guard config.modeID == .challenge else { return }
        guard let level = ChallengeLevel.all.first(where: { $0.number == challengeLevelNumber }) else { return }

        let snapshot = makeSnapshot()
        let result = ChallengeEvaluator.evaluate(
            condition: level.condition,
            snapshot: snapshot,
            phase: phase
        )
        if case .incomplete = result { return }
        challengeResult = result
        if case .success = result {
            fallTask?.cancel()
            clockTask?.cancel()
            phase = .sessionComplete
            HapticService.shared.success()
        } else if case .failure = result {
            triggerGameOver()
            HapticService.shared.failure()
        }
    }

    private func makeSnapshot() -> GameSnapshot {
        GameSnapshot(
            score: score,
            linesCleared: linesCleared,
            elapsedSeconds: elapsedSeconds,
            piecesPlaced: piecesPlaced,
            stackHeight: stackHeight,
            maxHeightEver: maxHeightEver,
            grid: grid,
            lastPieceShape: lastPieceShape,
            lastClearCount: lastClearCount,
            tetrisCount: tetrisCount,
            centerColumnEverOccupied: centerColumnEverOccupied,
            pyramidBuilt: pyramidBuilt
        )
    }

    /// The challenge level number to evaluate (from config or default 1)
    private var challengeLevelNumber: Int {
        // Passed through GameConfig — stored as a modifier or derived from AppState.
        // For now we store it in a computed way: the level is embedded in the game config
        // via a custom GameConfig extension.
        config.challengeLevel
    }

    private func triggerGameOver() {
        phase = .gameOver
        fallTask?.cancel()
        clockTask?.cancel()
        evaluateChallenge()
        HapticService.shared.failure()
    }

    private func endSession() {
        phase = .sessionComplete
        fallTask?.cancel()
        clockTask?.cancel()
        evaluateChallenge()
    }

    // MARK: - Computed helpers

    var stackHeight: Int {
        for (rowIdx, row) in grid.enumerated() {
            if row.contains(where: { !$0.isEmpty }) {
                return Self.rows - rowIdx
            }
        }
        return 0
    }
}
