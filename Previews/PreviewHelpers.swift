import SwiftUI

// MARK: - Mock AppState for canvas previews

extension AppState {
    /// Returns a fully populated AppState suitable for SwiftUI previews.
    static func preview(unlocked: Bool = false) -> AppState {
        let state = AppState()
        state.userProgress.personalBests[.zenStacking] = 18_420
        state.userProgress.personalBests[.blitz]      = 9_311
        state.userProgress.personalBests[.precision]  = 4_750
        state.userProgress.challengeLevel             = 7
        state.userProgress.challengeCompleted         = [1,2,3,4,5,6]
        return state
    }
}

// MARK: - Convenience wrapper

struct PreviewHost<Content: View>: View {
    @StateObject private var appState = AppState.preview()
    let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .environmentObject(appState)
    }
}
