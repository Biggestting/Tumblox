import SwiftUI

// MARK: - Tutorial Page Model

private struct TutorialPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let body: String
}

// MARK: - Tutorial Sheet

struct TutorialSheet: View {
    let modeID: GameModeID
    let onDismiss: () -> Void

    @State private var pageIndex = 0
    @Environment(\.colorScheme) var colorScheme

    private var pages: [TutorialPage] {
        let shared: [TutorialPage] = [
            TutorialPage(
                icon: "hand.draw",
                title: "Swipe to Move",
                body: "Swipe left or right to move your piece across the board."
            ),
            TutorialPage(
                icon: "arrow.down.to.line.compact",
                title: "Swipe Down to Drop",
                body: "Swipe down hard to instantly drop your piece to the lowest position."
            ),
            TutorialPage(
                icon: "hand.tap",
                title: "Tap to Rotate",
                body: "Tap anywhere on the board to rotate your piece clockwise."
            ),
            TutorialPage(
                icon: "lightbulb",
                title: "Use Hints",
                body: "Stuck? Tap the lightbulb in the control bar to see the best placement highlighted in gold."
            ),
        ]
        return shared + modeSpecificPages
    }

    private var modeSpecificPages: [TutorialPage] {
        switch modeID {
        case .challenge:
            return [TutorialPage(
                icon: "flag.checkered",
                title: "Complete the Objective",
                body: "Each challenge level has a unique goal. Read it in the HUD and complete it to advance."
            )]
        case .zenStacking:
            return [TutorialPage(
                icon: "leaf",
                title: "No Pressure",
                body: "Zen Stacking is freeform — no timers, no fail state. Stack as long as you like."
            )]
        case .precision:
            return [TutorialPage(
                icon: "scope",
                title: "Aim for the Center",
                body: "Pieces placed in the center columns earn bonus points. Build toward the middle."
            )]
        case .sprint:
            return [TutorialPage(
                icon: "timer",
                title: "Clear 40 Lines",
                body: "Race to clear 40 lines as fast as possible. Your time is your score."
            )]
        case .timeAttack:
            return [TutorialPage(
                icon: "clock.badge.exclamationmark",
                title: "Score Before Time's Up",
                body: "The clock is ticking. Clear lines as fast as possible to maximize your score."
            )]
        case .survival:
            return [TutorialPage(
                icon: "bolt",
                title: "Speed Increases",
                body: "Every 30 seconds, pieces fall faster. Stay alive as long as possible."
            )]
        case .marathon:
            return [TutorialPage(
                icon: "figure.run",
                title: "Endurance Run",
                body: "No time limit — keep stacking until the board fills up. Pace yourself."
            )]
        case .blitz:
            return [TutorialPage(
                icon: "flame",
                title: "2 Minutes, Max Score",
                body: "The clock stops at 2 minutes. Stack as fast as you can — every second counts."
            )]
        case .puzzle:
            return [TutorialPage(
                icon: "puzzlepiece",
                title: "Match the Pattern",
                body: "Each puzzle shows a target shape. Place pieces to recreate it exactly."
            )]
        case .creative:
            return [TutorialPage(
                icon: "paintbrush",
                title: "Unlimited Undo",
                body: "Undo as many times as you like — build freely with no consequences."
            )]
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(TumbloxColors.textMuted(colorScheme))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 32)

            // Page content
            TabView(selection: $pageIndex) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 260)

            // Dots
            HStack(spacing: 6) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Circle()
                        .fill(i == pageIndex ? TumbloxColors.accentBar : TumbloxColors.textMuted(colorScheme))
                        .frame(width: i == pageIndex ? 8 : 6, height: i == pageIndex ? 8 : 6)
                        .animation(.spring(response: 0.3), value: pageIndex)
                }
            }
            .padding(.bottom, 24)

            // Button
            if pageIndex < pages.count - 1 {
                TumbloxPrimaryButton(title: "Next", showArrow: true) {
                    withAnimation { pageIndex += 1 }
                }
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
            } else {
                TumbloxPrimaryButton(title: "Let's Play", showArrow: true, action: onDismiss)
                    .padding(.horizontal, TumbloxSpacing.screenHorizontal)
            }

            Spacer(minLength: 32)
        }
        .background(TumbloxColors.background(colorScheme))
    }

    // MARK: - Page view

    private func pageView(_ page: TutorialPage) -> some View {
        VStack(spacing: 20) {
            Image(systemName: page.icon)
                .font(.system(size: 44, weight: .light))
                .foregroundColor(TumbloxColors.accentBar)
                .frame(height: 56)

            VStack(spacing: 8) {
                Text(page.title)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                    .multilineTextAlignment(.center)

                Text(page.body)
                    .font(TumbloxTypography.body)
                    .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
    }
}
