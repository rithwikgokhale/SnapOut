import Photos
import DomainModels

enum AuthorizationMapper {

    static func map(_ status: PHAuthorizationStatus) -> PhotosAuthorizationState {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized:
            return .fullAccess
        case .limited:
            return .limitedAccess
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
}
