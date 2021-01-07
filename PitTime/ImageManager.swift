//
//  ImageManager.swift
//  PitTime
//
//  Created by 神村亮佑 on 2021/01/07.
//

import Foundation
import FirebaseStorage

let imageCache = NSCache<AnyObject, UIImage>()

class ImageManager {

    // MARK: PROPERTIES
    static let instance = ImageManager()

    private var REF_STOR = Storage.storage()

    // MARK: FUNCTIONS
    func uploadProfileImage(userID: String, image: UIImage) {
        // Get the path where we will save the image
        let path = getProfileImagePath(userID: userID)

        // Save image to path
        DispatchQueue.global(qos: .userInteractive).async {
            self.uploadImage(path: path, image: image) { _ in

            }
        }
    }

    func downloadProfileImage(userID: String, handler: @escaping(_ image: UIImage?) -> Void) {
        let path = getProfileImagePath(userID: userID)
        DispatchQueue.global(qos: .userInteractive).async {
            self.downloadImage(path: path) { returnedImage in
                DispatchQueue.main.async {
                    handler(returnedImage)
                }
            }
        }
    }

    // MARK: PRIVATE FUNCTIONS
    private func getProfileImagePath(userID: String) -> StorageReference {
        let userPath = "users/\(userID)/profile"
        let storagePath = REF_STOR.reference(withPath: userPath)
        return storagePath
    }

    private func uploadImage(path: StorageReference, image: UIImage, handler: @escaping (_ success: Bool) -> Void) {

        var compression: CGFloat = 1.0
        let maxFileSize: Int = 240 * 240
        let maxCompression: CGFloat = 0.05

        guard var originalData = image.jpegData(compressionQuality: compression) else {
            print("Error getting data from image")
            handler(false)
            return
        }

        // Check maximum file size
        while (originalData.count > maxFileSize) && (compression > maxCompression) {
            compression -= 0.05
            if let compressionData = image.jpegData(compressionQuality: compression) {
                originalData = compressionData
            }
            print(compression)
        }

        // Get Image Data
        guard let finalData = image.jpegData(compressionQuality: compression) else {
            print("ERROR GETTING DATA FROM IMAGE")
            handler(false)
            return
        }

        // Get photo matadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Save data to path
        path.putData(finalData, metadata: metadata) {_, error in
            if let error = error {
                // Error
                print("Error uploading image. \(error)")
                handler(false)
                return
            } else {
                // Success
                print("Success uploading image")
                handler(true)
                return
            }
        }

    }

    private func downloadImage(path: StorageReference, handler: @escaping(_ image: UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: path) {
            print("Image Found in cache")
            handler(cachedImage)
            return
        } else {
            path.getData(maxSize: 27 * 1024 * 1024) { returnedImageData, error in
                if let data = returnedImageData, let image = UIImage(data: data) {
                    // Success getting image data
                    imageCache.setObject(image, forKey: path)
                    handler(image)
                    return
                } else {
                    print("Error getting data from path for image: \(error)")
                    handler(nil)
                    return
                }
            }

        }
    }
}
