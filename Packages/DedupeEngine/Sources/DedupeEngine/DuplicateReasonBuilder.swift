import Foundation
import DomainModels

/// Produces human-readable duplicate-reason strings for the review UI.
public final class DuplicateReasonBuilder: Sendable {

    public init() {}

    public func reasonDescription(for code: DuplicateReasonCode) -> String {
        switch code {
        case .exactHash:
            return "Files are byte-identical."
        case .strongMetadata:
            return "Metadata strongly suggests these are the same asset."
        case .perceptualMatch:
            return "Visual content appears identical."
        case .dimensionAndDateMatch:
            return "Same dimensions and creation date."
        case .durationAndDateMatch:
            return "Same duration and creation date."
        }
    }
}
