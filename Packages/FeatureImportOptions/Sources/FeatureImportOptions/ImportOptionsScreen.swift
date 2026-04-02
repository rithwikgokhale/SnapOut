import SwiftUI
import DesignSystem
import DomainModels

public struct ImportOptionsScreen: View {

    @State private var importMode: ImportMode = .importAll
    @State private var skipDuplicates: Bool = true

    private let totalRecords: Int
    private let estimatedDuplicates: Int
    private let onStartImport: (ImportMode, Bool) -> Void
    private let onBack: () -> Void

    public init(
        totalRecords: Int = 0,
        estimatedDuplicates: Int = 0,
        onStartImport: @escaping (ImportMode, Bool) -> Void = { _, _ in },
        onBack: @escaping () -> Void = {}
    ) {
        self.totalRecords = totalRecords
        self.estimatedDuplicates = estimatedDuplicates
        self.onStartImport = onStartImport
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    ScreenHeader(
                        title: "Import Options",
                        subtitle: "Choose how to import your memories"
                    )

                    SectionCard(title: "Import Mode") {
                        VStack(spacing: AppSpacing.md) {
                            modeRow(
                                mode: .importAll,
                                label: "Import All",
                                description: "Import every record from the export",
                                icon: "square.and.arrow.down.on.square"
                            )
                            Divider()
                            modeRow(
                                mode: .importNew,
                                label: "Import New Only",
                                description: "Skip records that likely already exist in your library",
                                icon: "sparkles"
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    SectionCard(title: "Duplicate Handling") {
                        VStack(spacing: AppSpacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Skip detected duplicates")
                                        .font(AppText.body)
                                        .foregroundStyle(AppColor.textPrimary)
                                    Text("Duplicates are never auto-deleted. You can review them later.")
                                        .font(AppText.footnote)
                                        .foregroundStyle(AppColor.textSecondary)
                                }
                                Spacer()
                                Toggle("", isOn: $skipDuplicates)
                                    .labelsHidden()
                            }

                            if estimatedDuplicates > 0 {
                                InfoRow(
                                    label: "Estimated duplicates",
                                    value: "\(estimatedDuplicates)",
                                    icon: "doc.on.doc"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    SectionCard(title: "Summary") {
                        VStack(spacing: AppSpacing.sm) {
                            InfoRow(label: "Total records", value: "\(totalRecords)", icon: "doc.text")
                            InfoRow(label: "Mode", value: importMode == .importAll ? "All" : "New only", icon: "arrow.right.circle")
                            InfoRow(label: "Skip duplicates", value: skipDuplicates ? "Yes" : "No", icon: "doc.on.doc")
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.bottom, AppSpacing.xxxl)
            }

            BottomActionBar(label: "Start Import", icon: "arrow.right") {
                onStartImport(importMode, skipDuplicates)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") { onBack() }
            }
        }
    }

    private func modeRow(mode: ImportMode, label: String, description: String, icon: String) -> some View {
        Button {
            importMode = mode
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(AppColor.accent)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(label)
                        .font(AppText.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(description)
                        .font(AppText.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                Image(systemName: importMode == mode ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(importMode == mode ? AppColor.accent : AppColor.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ImportOptionsScreen(totalRecords: 1234, estimatedDuplicates: 56)
    }
}
