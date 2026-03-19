import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var product: Product? = nil
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String? = nil

    private let productID = "com.tumblox.fullgame"

    private let includedModes = GameMode.paidModes

    // MARK: - Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(TumbloxColors.textMuted(colorScheme))
                    }
                }
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // Hero
                VStack(spacing: 12) {
                    Text("Tumblox")
                        .font(TumbloxTypography.wordmark)
                        .foregroundColor(TumbloxColors.textPrimary(colorScheme))

                    Text("Full Game")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundColor(TumbloxColors.accentBar)

                    Text("Unlock every mode with one purchase.\nNo subscriptions. No ads. Ever.")
                        .font(TumbloxTypography.body)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.vertical, 32)

                // Mode list
                VStack(spacing: 0) {
                    ForEach(Array(includedModes.enumerated()), id: \.element.id) { index, mode in
                        modeIncludedRow(mode: mode)
                        if index < includedModes.count - 1 {
                            Divider()
                                .padding(.leading, TumbloxSpacing.screenHorizontal + 36)
                        }
                    }
                }
                .background(TumbloxColors.card(colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: TumbloxSpacing.cardRadius, style: .continuous))
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(TumbloxTypography.caption)
                        .foregroundColor(TumbloxColors.destructive)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
                        .padding(.top, 16)
                }

                // CTA
                VStack(spacing: 12) {
                    purchaseButton
                    restoreButton
                    legalNote
                }
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
                .padding(.top, 28)
                .padding(.bottom, 40)
            }
        }
        .background(TumbloxColors.background(colorScheme).ignoresSafeArea())
        .task { await loadProduct() }
    }

    // MARK: - Mode row

    private func modeIncludedRow(mode: GameMode) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(TumbloxColors.accentBar)
            VStack(alignment: .leading, spacing: 2) {
                Text(mode.name)
                    .font(TumbloxTypography.bodyBold)
                    .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                Text(mode.description)
                    .font(TumbloxTypography.caption)
                    .foregroundColor(TumbloxColors.textSecondary(colorScheme))
            }
        }
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        .padding(.vertical, 12)
    }

    // MARK: - Purchase button

    private var purchaseButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: 8) {
                        if let product = product {
                            Text("Unlock for \(product.displayPrice)")
                        } else {
                            Text("Unlock Full Game")
                        }
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .font(TumbloxTypography.bodyBold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(TumbloxColors.accentBar)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(isPurchasing || isRestoring)
    }

    // MARK: - Restore button

    private var restoreButton: some View {
        Button {
            Task { await restore() }
        } label: {
            Group {
                if isRestoring {
                    ProgressView()
                } else {
                    Text("Restore Purchases")
                        .font(TumbloxTypography.body)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                }
            }
        }
        .disabled(isPurchasing || isRestoring)
    }

    // MARK: - Legal

    private var legalNote: some View {
        Text("One-time purchase · No subscriptions · Purchases are non-refundable")
            .font(.system(size: 11, weight: .regular, design: .rounded))
            .foregroundColor(TumbloxColors.textMuted(colorScheme))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }

    // MARK: - StoreKit actions

    private func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            // Product load failure is non-fatal — price simply won't show
        }
    }

    private func purchase() async {
        isPurchasing = true
        errorMessage = nil
        do {
            try await appState.entitlementManager.purchase()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    private func restore() async {
        isRestoring = true
        errorMessage = nil
        do {
            try await appState.entitlementManager.restore()
            if appState.entitlementManager.isUnlocked {
                dismiss()
            } else {
                errorMessage = "No previous purchase found."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isRestoring = false
    }
}
