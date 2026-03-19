import StoreKit
import Foundation

enum EntitlementError: LocalizedError {
    case purchaseFailed
    case notEligible
    case networkError

    var errorDescription: String? {
        switch self {
        case .purchaseFailed:  return "Purchase could not be completed."
        case .notEligible:     return "This purchase is not available."
        case .networkError:    return "Network error. Please try again."
        }
    }
}

@MainActor
final class EntitlementManager: ObservableObject {
    @Published var isUnlocked = false

    private let productID = "com.tumblox.fullgame"
    private let tokenKey  = "com.tumblox.appAccountToken"

    // MARK: - Public

    func purchase() async throws {
        guard let product = try await Product.products(for: [productID]).first else {
            throw EntitlementError.notEligible
        }
        let result = try await product.purchase(options: [
            .appAccountToken(appAccountToken())
        ])
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            isUnlocked = true
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }

    func restore() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.productID == productID {
                isUnlocked = true
                return
            }
        }
    }

    func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                if case .verified(let tx) = result, tx.productID == productID {
                    await tx.finish()
                    isUnlocked = true
                }
            }
        }
    }

    // MARK: - Private

    private func appAccountToken() -> UUID {
        if let saved = UserDefaults.standard.string(forKey: tokenKey),
           let uuid = UUID(uuidString: saved) {
            return uuid
        }
        let newToken = UUID()
        UserDefaults.standard.set(newToken.uuidString, forKey: tokenKey)
        return newToken
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw EntitlementError.purchaseFailed
        case .verified(let value): return value
        }
    }
}
