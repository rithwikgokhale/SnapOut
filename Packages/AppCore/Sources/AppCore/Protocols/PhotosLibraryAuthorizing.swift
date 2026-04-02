import Foundation
import DomainModels

public protocol PhotosLibraryAuthorizing: Sendable {
    func currentAuthorizationState() async -> PhotosAuthorizationState
    func requestFullAccess() async -> PhotosAuthorizationState
    func ensureMasterAlbum(named name: String) async throws -> PhotosAlbumReference
}
