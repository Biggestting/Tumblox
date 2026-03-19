import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ModeSelectView()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .gameSetup(let modeID):
                        GameSetupView(modeID: modeID)
                    case .game:
                        GameView()
                    case .settings:
                        SettingsView()
                    case .paywall:
                        PaywallView()
                    }
                }
        }
        .tint(TumbloxColors.accentBar)
    }
}
