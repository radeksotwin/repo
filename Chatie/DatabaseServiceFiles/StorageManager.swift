//
//  StorageManager.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//

import Foundation
import FirebaseStorage

final class AppManager {
    
    static let shared = AppManager()
    
    public var isProfilePictureLoaded = false
}

/// final keyword explained - no class object can conform to final class and inherit its properties - `final object`
/// Allows you to
final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     
     /images/
     
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to firebase storage and returns completion with url string to download
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let me = self else { return }
            guard error == nil else {
                // failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            me.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("")
                    completion(.failure(StorageErrors.failedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
//                print("Picture URL request returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let me = self else { return }
            guard error == nil else {
                // failed
                print("Failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            me.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("")
                    completion(.failure(StorageErrors.failedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
//                print("Picture URL request returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    // Upload video
    
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
            guard let me = self else { return }
            guard error == nil else {
                // failed
                print("Failed to upload video file")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            me.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("")
                    completion(.failure(StorageErrors.failedToDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
//                print("Picture URL request returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownloadURL
    }
    
    public func downloadUrl(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToDownloadURL))
                return
            }
            completion(.success(url))
        })
    }
    
}
