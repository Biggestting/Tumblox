import Foundation

enum AppRoute: Hashable {
    case gameSetup(GameModeID)
    case game
    case settings
    case paywall
}
