import Photos
import DomainModels
import AppCore

public final class PhotoLibraryAuthorizer: PhotosLibraryAuthorizing, Sendable {

    public init() {}

    public func currentAuthorizationState() async -> PhotosAuthorizationState {
        // HANDOFF: Agent 3 — replace with PHPhotoLibrary.authorizationStatus(for:)
        return .notDetermined
    }

    public func requestFullAccess() async -> PhotosAuthorizationState {
        // HANDOFF: Agent 3 — replace with PHPhotoLibrary.requestAuthorization(for:)
        return .notDetermined
    }

    public func ensureMasterAlbum(named name: String) async throws -> PhotosAlbumReference {
        // HANDOFF: Agent 3 — implement album creation via PHAssetCollectionChangeRequest
        throw PhotosAccessError.notImplemented
    }
}

public enum PhotosAccessError: Error, Sendable {
    case notImplemented
    case albumCreationFailed
    case writeFailed(underlying: String)
}
