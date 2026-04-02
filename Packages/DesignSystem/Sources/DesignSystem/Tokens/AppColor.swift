import SwiftUI

public enum AppColor {

    // MARK: - Accent

    public static let accent = Color(.systemIndigo)

    // MARK: - Semantic

    public static let success = Color(.systemGreen)
    public static let warning = Color(.systemOrange)
    public static let error = Color(.systemRed)

    // MARK: - Backgrounds

    public static let backgroundPrimary = Color(.systemBackground)
    public static let backgroundSecondary = Color(.secondarySystemBackground)

    // MARK: - Surfaces

    public static let surfacePrimary = Color(.tertiarySystemBackground)
    public static let surfaceSecondary = Color(.quaternarySystemFill)

    // MARK: - Text

    public static let textPrimary = Color(.label)
    public static let textSecondary = Color(.secondaryLabel)
    public static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Borders

    public static let borderSubtle = Color(.separator)
    public static let borderStrong = Color(.opaqueSeparator)
}
