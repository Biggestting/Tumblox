import SwiftUI

struct DeleteAccountSheet: View {
    let onDelete: () -> Void
    let onCancel: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(TumbloxColors.textMuted(colorScheme))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)

            VStack(alignment: .leading, spacing: 20) {
                // Icon + title
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(TumbloxColors.destructive)

                    Text("Delete Account")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                }

                // Warning box
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(TumbloxColors.destructive.opacity(0.15))
                        .frame(width: 3)
                        .clipShape(Capsule())
                    Text("All game history, personal bests, and challenge progress will be permanently lost and cannot be recovered.")
                        .font(TumbloxTypography.caption)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                }
                .padding(14)
                .background(TumbloxColors.destructive.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                // Actions
                VStack(spacing: 10) {
                    Button {
                        onDelete()
                    } label: {
                        Text("Delete My Account")
                            .font(TumbloxTypography.bodyBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(TumbloxColors.destructive)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .font(TumbloxTypography.body)
                            .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
            }
            .padding(.horizontal, TumbloxSpacing.screenHorizontal)

            Spacer()
        }
        .background(TumbloxColors.background(colorScheme))
    }
}
