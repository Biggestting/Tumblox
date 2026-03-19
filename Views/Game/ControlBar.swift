import SwiftUI

struct ControlBar: View {
    let onUndo: () -> Void
    let onHint: () -> Void
    let onRotateLeft: () -> Void
    let onRotateRight: () -> Void
    let onPause: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            controlButton(icon: "arrow.uturn.backward", label: "Undo", action: onUndo)
            controlButton(icon: "lightbulb",            label: "Hint", action: onHint)
            controlButton(icon: "arrow.counterclockwise", label: "Rotate Left",  action: onRotateLeft)
            controlButton(icon: "arrow.clockwise",      label: "Rotate Right", action: onRotateRight)
            controlButton(icon: "pause.fill",           label: "Pause", action: onPause)
        }
        .frame(height: TumbloxSpacing.controlBarHeight)
        .background(TumbloxColors.controlBar(colorScheme))
        .accessibilityElement(children: .contain)
    }

    private func controlButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: TumbloxTypography.controlIcon, weight: .medium))
                .foregroundColor(TumbloxColors.controlIcon(colorScheme))
                .frame(width: TumbloxSpacing.controlIconSize, height: TumbloxSpacing.controlIconSize)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
