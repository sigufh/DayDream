import Photos
import UIKit
import MobileCoreServices

@MainActor
final class PhotoAlbumManager {

    static let albumName = "浮光梦境"

    enum SaveResult {
        case success
        case noPermission
        case failure
    }

    /// 原 saveImage 方法修改为使用 HEIC 数据保存，保持高清
    static func saveImage(_ image: UIImage) async -> SaveResult {

        let authorized = await requestAccess()
        guard authorized else {
            return .noPermission
        }

        guard let album = await getOrCreateAlbum() else {
            return .failure
        }

        // 转 HEIC 数据
        guard let imageData = image.heicData(compressionQuality: 1.0) else {
            return .failure
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {

                // 使用 PHAssetCreationRequest 添加资源（HEIC）
                let creationRequest = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.uniformTypeIdentifier = "public.heic"

                creationRequest.addResource(with: .photo, data: imageData, options: options)

                // 添加到自定义相册
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                   let placeholder = creationRequest.placeholderForCreatedAsset {
                    albumChangeRequest.addAssets([placeholder] as NSFastEnumeration)
                }
            }

            return .success

        } catch {
            print("Photo save error: \(error)")
            return .failure
        }
    }

    private static func requestAccess() async -> Bool {

        let currentStatus =
            PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch currentStatus {

        case .authorized, .limited:
            return true

        case .notDetermined:
            let newStatus =
                await PHPhotoLibrary.requestAuthorization(for: .readWrite)

            return newStatus == .authorized ||
                   newStatus == .limited

        case .denied, .restricted:
            return false

        @unknown default:
            return false
        }
    }

    private static func getOrCreateAlbum() async -> PHAssetCollection? {

        if let existing = fetchAlbum() {
            return existing
        }

        var placeholder: PHObjectPlaceholder?

        do {
            try await PHPhotoLibrary.shared().performChanges {

                let request =
                    PHAssetCollectionChangeRequest
                        .creationRequestForAssetCollection(
                            withTitle: albumName
                        )

                placeholder =
                    request.placeholderForCreatedAssetCollection
            }

            guard let id = placeholder?.localIdentifier else {
                return nil
            }

            let result =
                PHAssetCollection.fetchAssetCollections(
                    withLocalIdentifiers: [id],
                    options: nil
                )

            return result.firstObject

        } catch {
            print("Album creation error: \(error)")
            return nil
        }
    }

    private static func fetchAlbum() -> PHAssetCollection? {

        let options = PHFetchOptions()
        options.predicate =
            NSPredicate(format: "title = %@", albumName)

        let result =
            PHAssetCollection.fetchAssetCollections(
                with: .album,
                subtype: .any,
                options: options
            )

        return result.firstObject
    }
}

// MARK: - UIImage HEIC 转数据扩展
extension UIImage {
    func heicData(compressionQuality: CGFloat = 1.0) -> Data? {
        guard let cgImage = self.cgImage else { return nil }

        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(mutableData, AVFileType.heic as CFString, 1, nil) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]

        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }

        return mutableData as Data
    }
}
