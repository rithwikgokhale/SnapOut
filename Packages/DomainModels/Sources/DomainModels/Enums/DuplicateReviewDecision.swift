import Foundation

public enum DuplicateReviewDecision: String, Codable, Sendable {
    case skipImport = "skip_import"
    case keepBoth = "keep_both"
    case deleteLibraryAsset = "delete_library_asset"
    case decideLater = "decide_later"
}
