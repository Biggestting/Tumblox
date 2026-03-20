import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    // Engine is created lazily once config is available
    @StateObject private var engineHolder = EngineHolder()
    @State private var showLeaderboard = false
    @State private var leaderboardID: String? = nil
    @State private var boardScale: CGFloat = 1.0
    @State private var tiltAngle: Angle = .zero

    private let zoomStep: CGFloat = 0.15
    private let minZoom: CGFloat = 0.6
    private let maxZoom: CGFloat = 1.5

    // MARK: - Body

    var body: some View {
        ZStack {
            TumbloxColors.background(colorScheme).ignoresSafeArea()

            if let engine = engineHolder.engine {
                gameContent(engine: engine)
            } else {
                ProgressView()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            guard let config = appState.pendingGameConfig else { return }
            engineHolder.start(config: config)
        }
    }

    // MARK: - Game content

    @ViewBuilder
    private func gameContent(engine: GameEngine) -> some View {
        let config = appState.pendingGameConfig ?? GameConfig(modeID: .zenStacking)
        let mode = GameMode.mode(for: config.modeID)

        ZStack {
            VStack(spacing: 0) {
                GameHUD(
                    score: engine.score,
                    personalBest: appState.personalBest(for: config.modeID) ?? 0,
                    elapsedSeconds: engine.elapsedSeconds,
                    sessionDuration: config.sessionDuration,
                    modeName: mode.name,
                    nextPiece: config.modifiers.showNextPiece ? engine.nextPiece : nil
                )

                GameCanvas(
                    grid: engine.grid,
                    activePiece: engine.activePiece,
                    ghostCells: ghostKeys(engine: engine, config: config),
                    hintCells: hintKeys(engine: engine),
                    nextPiece: config.modifiers.showNextPiece ? engine.nextPiece : nil,
                    showNextPiece: config.modifiers.showNextPiece
                )
                .scaleEffect(boardScale)
                .rotationEffect(tiltAngle, anchor: .bottom)
                .animation(.easeInOut(duration: 0.15), value: boardScale)
                .animation(.easeInOut(duration: 0.3), value: tiltAngle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Single unified gesture: DragGesture(minimumDistance:0) classifies
                // tap vs swipe by total travel distance, eliminating the conflict
                // between a separate DragGesture and onTapGesture competing for events.
                .gesture(boardGesture(engine: engine, config: config))
                .padding(.horizontal, 4)
                .padding(.vertical, 4)

                ControlBar(
                    onReturn:  { engine.undo() },
                    onHint:    { engine.showHint() },
                    onZoomOut: { boardScale = max(minZoom, boardScale - zoomStep) },
                    onZoomIn:  { boardScale = min(maxZoom, boardScale + zoomStep) },
                    onPause:   { engine.pause() }
                )
            }

            if engine.phase == .paused {
                PauseView(
                    modeName: mode.name,
                    score: engine.score,
                    onResume: { engine.resume() },
                    onQuit: {
                        appState.updatePersonalBest(engine.score, for: config.modeID)
                        appState.popToRoot()
                    }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }

            if engine.phase == .gameOver || engine.phase == .sessionComplete {
                let challengeSettled: Bool = {
                    if case .incomplete = engine.challengeResult { return false }
                    return true
                }()
                if config.modeID == .challenge && challengeSettled {
                    ChallengeSummaryView(
                        result: engine.challengeResult,
                        levelNumber: config.challengeLevel,
                        score: engine.score,
                        onNext: {
                            appState.markChallengeCompleted(config.challengeLevel)
                            var nextConfig = config
                            nextConfig.challengeLevel = appState.userProgress.challengeLevel
                            appState.pendingGameConfig = nextConfig
                            let newEngine = GameEngine(config: nextConfig)
                            engineHolder.engine = newEngine
                            newEngine.startGame()
                        },
                        onRetry: {
                            let newEngine = GameEngine(config: config)
                            engineHolder.engine = newEngine
                            newEngine.startGame()
                        },
                        onQuit: {
                            appState.updatePersonalBest(engine.score, for: config.modeID)
                            appState.popToRoot()
                        }
                    )
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))
                } else {
                    GameOverView(
                        score: engine.score,
                        personalBest: appState.personalBest(for: config.modeID) ?? 0,
                        modeName: mode.name,
                        isSessionEnd: engine.phase == .sessionComplete,
                        onRestart: {
                            let newEngine = GameEngine(config: config)
                            engineHolder.engine = newEngine
                            newEngine.startGame()
                        },
                        onQuit: {
                            appState.updatePersonalBest(engine.score, for: config.modeID, elapsedSeconds: engine.elapsedSeconds)
                            appState.popToRoot()
                        },
                        onLeaderboard: LeaderboardID.id(for: config.modeID) != nil ? {
                            leaderboardID = LeaderboardID.id(for: config.modeID)?.rawValue
                            showLeaderboard = true
                        } : nil
                    )
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))
                }
            }
        }
        .onChange(of: engine.phase) { phase in
            if phase == .gameOver || phase == .sessionComplete {
                appState.updatePersonalBest(engine.score, for: config.modeID, elapsedSeconds: engine.elapsedSeconds)
            }
        }
        .onChange(of: engine.tiltDirection) { direction in
            switch direction {
            case -1: tiltAngle = .degrees(-2.5)
            case  1: tiltAngle = .degrees(2.5)
            default: tiltAngle = .degrees(0)
            }
        }
        .sheet(isPresented: $showLeaderboard) {
            if let id = leaderboardID {
                GameCenterLeaderboardView(leaderboardID: id, isPresented: $showLeaderboard)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Helpers

    private func ghostKeys(engine: GameEngine, config: GameConfig) -> Set<String> {
        guard config.modifiers.ghostPieceEnabled, let piece = engine.activePiece else { return [] }
        var ghost = piece
        while true {
            var dropped = ghost
            dropped.row += 1
            let valid = dropped.cells.allSatisfy { c in
                c.col >= 0 && c.col < GameEngine.columns &&
                c.row < GameEngine.rows &&
                (c.row < 0 || engine.grid[c.row][c.col].isEmpty)
            }
            if valid { ghost = dropped } else { break }
        }
        return Set(ghost.cells.map { "\($0.col),\($0.row)" })
    }

    private func hintKeys(engine: GameEngine) -> Set<String> {
        guard let hint = engine.hintPlacement else { return [] }
        return Set(hint.cells.map { "\($0.col),\($0.row)" })
    }

    /// Unified board gesture — eliminates the SwiftUI conflict between a competing
    /// DragGesture and onTapGesture. A single DragGesture(minimumDistance:0) fires
    /// for both taps and swipes; we classify by total travel distance.
    private func boardGesture(engine: GameEngine, config: GameConfig) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded { value in
                let h = value.translation.width
                let v = value.translation.height
                let distance = sqrt(h * h + v * v)

                // Tap: distance < 12pt → rotate (or manual drop in manualDrop pace)
                if distance < 12 {
                    if config.pace == .manualDrop {
                        engine.manualTap()
                    } else {
                        engine.rotate(clockwise: true)
                        HapticService.shared.rotate()
                    }
                    return
                }

                // Swipe: classify by dominant axis
                if abs(h) > abs(v) {
                    // Horizontal swipe → move
                    if h > 0 { engine.moveRight() } else { engine.moveLeft() }
                } else if v > 0 {
                    // Swipe down → hard drop
                    engine.hardDrop()
                } else {
                    // Swipe up → rotate clockwise (standard Tetris UX)
                    engine.rotate(clockwise: true)
                    HapticService.shared.rotate()
                }
            }
    }
}

// MARK: - Engine Holder

/// Observable wrapper so engine can be created after onAppear (EnvironmentObject available).
/// Forwards the engine's objectWillChange so SwiftUI re-renders when the engine
/// publishes updates (e.g., auto-fall timer ticks, score changes).
@MainActor
final class EngineHolder: ObservableObject {
    @Published var engine: GameEngine? {
        didSet {
            engineSub?.cancel()
            if let engine {
                engineSub = engine.objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
            }
        }
    }
    private var engineSub: AnyCancellable?

    func start(config: GameConfig) {
        guard engine == nil else { return }
        let e = GameEngine(config: config)
        self.engine = e
        e.startGame()
    }
}
