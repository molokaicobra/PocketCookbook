//
//  imageRenderPipeline.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/12/23.
//

import Foundation
import UIKit


/**
 extesnion of UIImageView that allows for direct interactions of the singleton NSCache `ImageCache`
 */
extension UIImageView{
    
    /**
     loads and image from the provided URL object using the singleton ImageCache created in `ImageCache`
     Of the cachedImage is returned as nil or fails then the method returns nothing and nothing is displayed on
     to the self.UIImageView. If the image is not in the cache then it is loaded into it.
     
     - parameter url: a URL object that directs to the image that you wish to load and cache.
     
     - Note: returns void but modifies the self.image
     */
    func loadImage(from url: URL) {
        ImageCache.sharedCache.getImage(for: url) { [weak self] cachedImage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.image = cachedImage
            }
        }
    }
    
}


