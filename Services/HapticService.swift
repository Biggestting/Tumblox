import UIKit

final class HapticService {
    static let shared = HapticService()
    private init() {}

    // MARK: - Generators (lazy, reused for performance)

    private lazy var lightImpact   = UIImpactFeedbackGenerator(style: .light)
    private lazy var mediumImpact  = UIImpactFeedbackGenerator(style: .medium)
    private lazy var heavyImpact   = UIImpactFeedbackGenerator(style: .heavy)
    private lazy var notification  = UINotificationFeedbackGenerator()
    private lazy var selection     = UISelectionFeedbackGenerator()

    // MARK: - Game events

    /// Piece locked onto the grid
    func pieceLock() {
        lightImpact.impactOccurred(intensity: 0.6)
    }

    /// One or more lines cleared
    func lineClear(count: Int) {
        switch count {
        case 1, 2:
            mediumImpact.impactOccurred()
        case 3:
            heavyImpact.impactOccurred()
        default:                    // Tetris (4+)
            heavyImpact.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.heavyImpact.impactOccurred(intensity: 0.7)
            }
        }
    }

    /// Challenge success / session complete
    func success() {
        notification.notificationOccurred(.success)
    }

    /// Game over / challenge failure
    func failure() {
        notification.notificationOccurred(.error)
    }

    /// UI selection (picker tap, toggle)
    func selectionChanged() {
        selection.selectionChanged()
    }

    /// Prepare generators ahead of a known event (reduces latency)
    func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }
}
