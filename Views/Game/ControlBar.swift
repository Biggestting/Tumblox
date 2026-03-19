import SwiftUI

struct ControlBar: View {
    let onReturn: () -> Void
    let onHint: () -> Void
    let onZoomOut: () -> Void
    let onZoomIn: () -> Void
    let onPause: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            controlButton(icon: "arrow.uturn.backward", label: "Return",   action: onReturn)
            controlButton(icon: "lightbulb",            label: "Hint",     action: onHint)
            controlButton(icon: "minus.magnifyingglass", label: "Zoom Out", action: onZoomOut)
            controlButton(icon: "plus.magnifyingglass",  label: "Zoom In",  action: onZoomIn)
            controlButton(icon: "pause.fill",           label: "Pause",    action: onPause)
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
