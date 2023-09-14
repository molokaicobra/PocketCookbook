//
//  ImageCache.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/12/23.
//

import Foundation
import UIKit

/**
 A singleton class used to manage caching of UIImage objects. Creates a shard singleton
 ImageCache that is an NSCache that stores an image's URL (As String) and the UIImage.
 This cache also compresses the UIImage for when it's stored
 */
class ImageCache {
    
    // Singleton instance of ImageCache for shared use.
    static let sharedCache = ImageCache()
    
    
    private let cache = NSCache<NSString, UIImage>()
    
    /**
     Attempts to get an image from the shared ImageCache. If the image is in the cache we use completion handling to return the Image.
     If the image is not in the cache (first time we are downloading the image or it has been dropped from the cache) the method
     then calls `downloadImage()`. downloadImage then attempts to download and compress the image. If that returns successfully
     it then the image is assigned to the cache where it is saved for quick access in the future.
     
     The key for the items stored in the cache are the images URL as a string.
     
     - Parameter url:the URL data type that directs to the image. Will be converted to a string for the
     */
    func getImage(for url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        } else {
            //Image not found in Cache. Cache and then return the
            downloadImage(from: url) { downloadedImage in
                if let downloadedImage = downloadedImage {
                    self.cache.setObject(downloadedImage, forKey: url.absoluteString as NSString)
                }
                completion(downloadedImage)
            }
        }
    }
    
    /**
     If an image is not found in the cache it is directed to this method. This method will then load the image from the URL and compress it to save on memory.
     This method returns using a completion as we do not want it blocking the main thread. If the image fails to compress or to be returned from the URL then
     the completion() returns nil. It then returns the downloaded and compressed image to `getImage()` where it is given back to the caller.
     
     - parameter url: a URL data type that directs to the image's thumbnail
     - parameter compressionQuality:a CGFloat that determines the image's compression amount. Defaults to .4. Range 1.0 (Max Quality) to 0.0 (Lowest Quality)
     - parameter completion: Handles the return of the data. Returns the downloaded or compressed image.
     */
    private func downloadImage(from url: URL, compressionQuality: CGFloat = 0.4, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, var image = UIImage(data: data) else {
                completion(nil)
                return
            }
            // Compress the image
            if let compressedData = image.jpegData(compressionQuality: compressionQuality) {
                image = UIImage(data: compressedData) ?? image
            }
            
            completion(image)

        }.resume()
    }
    
    
}
