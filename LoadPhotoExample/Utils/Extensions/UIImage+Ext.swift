//
//  UIImage+Ext.swift
//  LoadPhotoExample
//
//  Created by Bui Tuan on 3/4/25.
//

import Foundation
import UIKit

extension UIImage {
    func compressImage(compressionQuality: CGFloat) -> Data? {
        return self.jpegData(compressionQuality: compressionQuality)
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
