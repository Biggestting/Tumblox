import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var showDeleteConfirm = false
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: TumbloxSpacing.sectionGap) {
                // MARK: Appearance
                settingsSection(title: "APPEARANCE") {
                    VStack(spacing: 0) {
                        themeRow
                    }
                }

                // MARK: Audio & Haptics
                settingsSection(title: "AUDIO & HAPTICS") {
                    VStack(spacing: 0) {
                        toggleRow(
                            title: "Sound",
                            isOn: Binding(
                                get: { appState.userProgress.settings.soundEnabled },
                                set: { appState.userProgress.settings.soundEnabled = $0; saveSettings() }
                            )
                        )
                        Divider().padding(.leading, TumbloxSpacing.screenHorizontal)
                        toggleRow(
                            title: "Haptics",
                            isOn: Binding(
                                get: { appState.userProgress.settings.hapticsEnabled },
                                set: { appState.userProgress.settings.hapticsEnabled = $0; saveSettings() }
                            )
                        )
                    }
                }

                // MARK: Full Game
                if !appState.entitlementManager.isUnlocked {
                    settingsSection(title: "FULL GAME") {
                        VStack(spacing: 0) {
                            unlockRow
                        }
                    }
                }

                // MARK: Account
                settingsSection(title: "ACCOUNT") {
                    VStack(spacing: 0) {
                        restoreRow
                        Divider().padding(.leading, TumbloxSpacing.screenHorizontal)
                        deleteAccountRow
                    }
                }

                // MARK: About
                settingsSection(title: "ABOUT") {
                    VStack(spacing: 0) {
                        infoRow(label: "Version", value: appVersion)
                        Divider().padding(.leading, TumbloxSpacing.screenHorizontal)
                        linkRow(label: "Privacy Policy")
                        Divider().padding(.leading, TumbloxSpacing.screenHorizontal)
                        linkRow(label: "Terms of Use")
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .background(TumbloxColors.background(colorScheme).ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(TumbloxTypography.body)
                    }
                    .foregroundColor(TumbloxColors.accent(colorScheme))
                }
            }
        }
        .sheet(isPresented: $showDeleteConfirm) {
            DeleteAccountSheet(
                onDelete: { deleteAccount() },
                onCancel: { showDeleteConfirm = false }
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Section builder

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(TumbloxTypography.sectionEyebrow)
                .kerning(2.5)
                .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)

            content()
                .background(TumbloxColors.card(colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: TumbloxSpacing.cardRadius, style: .continuous))
                .shadow(
                    color: colorScheme == .light ? DS.shadowColor : .clear,
                    radius: DS.shadowRadius,
                    y: DS.shadowY
                )
                .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        }
    }

    // MARK: - Row types

    private var themeRow: some View {
        HStack {
            Text("Theme")
                .font(TumbloxTypography.body)
                .foregroundColor(TumbloxColors.textPrimary(colorScheme))
            Spacer()
            Picker("", selection: Binding(
                get: { appState.userProgress.settings.theme },
                set: { appState.userProgress.settings.theme = $0; saveSettings() }
            )) {
                ForEach(UserSettings.AppTheme.allCases, id: \.self) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
        }
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        .padding(.vertical, 14)
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(TumbloxTypography.body)
                .foregroundColor(TumbloxColors.textPrimary(colorScheme))
            Spacer()
            Toggle("", isOn: isOn)
                .tint(TumbloxColors.toggleTint(colorScheme))
                .labelsHidden()
        }
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        .padding(.vertical, 14)
    }

    private var unlockRow: some View {
        Button {
            Task { await purchaseFullGame() }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Unlock Full Game")
                        .font(TumbloxTypography.bodyBold)
                        .foregroundStyle(
                            colorScheme == .light
                                ? TumbloxGradient.accent
                                : LinearGradient(colors: [TumbloxColors.accentBar], startPoint: .leading, endPoint: .trailing)
                        )
                    Text("Unlock all 10 game modes")
                        .font(TumbloxTypography.caption)
                        .foregroundColor(TumbloxColors.textSecondary(colorScheme))
                }
                Spacer()
                if isPurchasing {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(TumbloxColors.textMuted(colorScheme))
                }
            }
            .padding(.horizontal, TumbloxSpacing.screenHorizontal)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var restoreRow: some View {
        Button {
            Task { await restorePurchases() }
        } label: {
            HStack {
                Text("Restore Purchases")
                    .font(TumbloxTypography.body)
                    .foregroundColor(TumbloxColors.textPrimary(colorScheme))
                Spacer()
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(TumbloxColors.textMuted(colorScheme))
            }
            .padding(.horizontal, TumbloxSpacing.screenHorizontal)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var deleteAccountRow: some View {
        Button {
            showDeleteConfirm = true
        } label: {
            HStack {
                Text("Delete Account")
                    .font(TumbloxTypography.body)
                    .foregroundColor(TumbloxColors.destructive)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(TumbloxColors.textMuted(colorScheme))
            }
            .padding(.horizontal, TumbloxSpacing.screenHorizontal)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(TumbloxTypography.body)
                .foregroundColor(TumbloxColors.textPrimary(colorScheme))
            Spacer()
            Text(value)
                .font(TumbloxTypography.body)
                .foregroundColor(TumbloxColors.textSecondary(colorScheme))
        }
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        .padding(.vertical, 14)
    }

    private func linkRow(label: String) -> some View {
        HStack {
            Text(label)
                .font(TumbloxTypography.body)
                .foregroundColor(TumbloxColors.textPrimary(colorScheme))
            Spacer()
            Image(systemName: "arrow.up.right.square")
                .font(.system(size: 14))
                .foregroundColor(TumbloxColors.textMuted(colorScheme))
        }
        .padding(.horizontal, TumbloxSpacing.screenHorizontal)
        .padding(.vertical, 14)
    }

    // MARK: - Actions

    private func saveSettings() {
        appState.progressService.save(appState.userProgress)
    }

    private func purchaseFullGame() async {
        isPurchasing = true
        do {
            try await appState.entitlementManager.purchase()
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    private func restorePurchases() async {
        do {
            try await appState.entitlementManager.restore()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func deleteAccount() {
        appState.progressService.reset()
        appState.userProgress = UserProgress()
        showDeleteConfirm = false
        appState.popToRoot()
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - Preview

#Preview("Settings – Dark") {
    NavigationStack {
        PreviewHost {
            SettingsView()
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Settings – Light") {
    NavigationStack {
        PreviewHost {
            SettingsView()
        }
    }
    .preferredColorScheme(.light)
}
