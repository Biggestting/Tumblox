import SwiftUI

struct GameView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    // Engine is created lazily once config is available
    @StateObject private var engineHolder = EngineHolder()
    @State private var showLeaderboard = false
    @State private var leaderboardID: String? = nil

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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(swipeGesture(engine: engine))
                .onTapGesture {
                    if config.pace == .manualDrop {
                        engine.manualTap()
                    } else {
                        engine.rotate(clockwise: true)
                    }
                }
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
                .padding(.vertical, 8)

                ControlBar(
                    onUndo:        { engine.undo() },
                    onHint:        { engine.showHint() },
                    onRotateLeft:  { engine.rotate(clockwise: false) },
                    onRotateRight: { engine.rotate(clockwise: true) },
                    onPause:       { engine.pause() }
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

    private func swipeGesture(engine: GameEngine) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                let h = value.translation.width
                let v = value.translation.height
                if abs(h) > abs(v) {
                    if h > 0 { engine.moveRight() } else { engine.moveLeft() }
                } else if v > 0 {
                    engine.hardDrop()
                }
            }
    }
}

// MARK: - Engine Holder

/// Observable wrapper so engine can be created after onAppear (EnvironmentObject available)
@MainActor
final class EngineHolder: ObservableObject {
    @Published var engine: GameEngine?

    func start(config: GameConfig) {
        guard engine == nil else { return }
        let e = GameEngine(config: config)
        self.engine = e
        e.startGame()
    }
}
