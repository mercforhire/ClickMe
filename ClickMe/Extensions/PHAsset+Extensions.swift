//
//  PHAsset+Extensions.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-25.
//

import Foundation
import PhotosUI

extension PHAsset {
    static func getURL(asset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: options, resultHandler: { (avAsset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
            DispatchQueue.main.async {
                if let vidURL = avAsset as? AVURLAsset {
                    completionHandler(vidURL.url)
                } else {
                    completionHandler(nil)
                }
            }
        })
    }
    
    func getAssetThumbnail() -> UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail: UIImage?
        option.isSynchronous = true
        manager.requestImage(for: self, targetSize: CGSize(width: 200, height: 150), contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in
            thumbnail = result
        })
        return thumbnail
    }
}
