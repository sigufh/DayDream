import Photos
import UIKit

final class PhotoAlbumManager {
    static let albumName = "浮光梦境"

    static func saveImage(_ image: UIImage) async -> Bool {
        let authorized = await requestAccess()
        guard authorized else { return false }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                let album = fetchOrCreateAlbum()
                let imageRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                if let album, let placeholder = imageRequest.placeholderForCreatedAsset {
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    albumChangeRequest?.addAssets([placeholder] as NSFastEnumeration)
                }
            }
            return true
        } catch {
            print("Photo save error: \(error)")
            return false
        }
    }

    private static func requestAccess() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized || status == .limited { return true }

        let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return newStatus == .authorized || newStatus == .limited
    }

    private static func fetchOrCreateAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let existing = collection.firstObject {
            return existing
        }

        // Create new album
        do {
            var placeholder: PHObjectPlaceholder?
            try PHPhotoLibrary.shared().performChangesAndWait {
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                placeholder = request.placeholderForCreatedAssetCollection
            }
            if let placeholder {
                let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                return result.firstObject
            }
        } catch {
            print("Album creation error: \(error)")
        }
        return nil
    }
}
