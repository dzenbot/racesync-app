//
//  UIImage+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-20.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

/// Instance Methods
extension UIImage {

    func image(withColor color: UIColor) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!

        let rect = CGRect(origin: CGPoint.zero, size: size)

        color.setFill()
        self.draw(in: rect)
        context.setBlendMode(.sourceIn)
        context.fill(rect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func blurred(radius: CGFloat) -> UIImage {
        let ciContext = CIContext(options: nil)
        guard let cgImage = cgImage else { return self }
        let inputImage = CIImage(cgImage: cgImage)
        guard let ciFilter = CIFilter(name: "CIGaussianBlur") else { return self }
        ciFilter.setValue(inputImage, forKey: kCIInputImageKey)
        ciFilter.setValue(radius, forKey: "inputRadius")
        guard let resultImage = ciFilter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let cgImage2 = ciContext.createCGImage(resultImage, from: inputImage.extent) else { return self }
        return UIImage(cgImage: cgImage2)
    }

    func cropImage(to rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, self.scale)
        draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        let cropImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return cropImage
    }

    func rounded() -> UIImage? {
//        var returnImage: UIImage? // Image, to return
//        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
////        let maskingColors: [CGFloat] = [100, 255, 100, 255, 100, 255] // We should replace white color.
////        let maskImage = cgImage! //
//
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//
//        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
//        draw(in: rect)
//
//        returnImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
////        let noAlphaImage = UIGraphicsGetImageFromCurrentImageContext() // new image, without transparent elements.
////        UIGraphicsEndImageContext()
////
////        let noAlphaCGRef = noAlphaImage?.cgImage // get CGImage.
////
////        if let imgRefCopy = noAlphaCGRef?.copy(maskingColorComponents: maskingColors) { // Magic.
////            UIGraphicsBeginImageContextWithOptions(size, false, 0)
////            let context = UIGraphicsGetCurrentContext()!
////            context.clip(to: rect, mask: maskImage) // Remove background from image with mask.
////            context.setFillColor(UIColor.clear.cgColor) // set new color. We remove white color, and set red.
////            context.fill(rect)
////            context.draw(imgRefCopy, in: rect) // draw new image
////            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
////            returnImage = finalImage! // YEAH!
////            UIGraphicsEndImageContext()
////        }
//
//        return returnImage



//        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//
//        let layer = CALayer()
//        layer.frame = rect
//        layer.contents = cgImage
//        layer.masksToBounds = true
//        layer.backgroundColor = UIColor.clear.cgColor
//
//        layer.cornerRadius = size.width/2
//
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        let context = UIGraphicsGetCurrentContext()
//        context?.setFillColor(UIColor.clear.cgColor)
//
//        layer.render(in: context!)
//        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return roundedImage


        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        UIBezierPath(ovalIn: rect).addClip()
        UIImage(cgImage: cgImage!, scale: scale, orientation: imageOrientation).draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

/// Static Methods
extension UIImage {

    static func image(withColor color: UIColor? = nil, borderColor: UIColor? = nil, cornerRadius: CGFloat? = nil, imageSize: CGSize) -> UIImage? {
        defer {  UIGraphicsEndImageContext() }

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)

        let rect = CGRect(origin: .zero, size: imageSize)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(cornerRadius ?? 0))
        path.addClip()

        if let color = color {
            color.setFill()
            path.fill()
        }

        if let borderColor = borderColor {
            borderColor.setStroke()
            path.lineWidth = 2
            path.stroke()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    static func image(withImage image: UIImage, _ overlayColor: UIColor?, _ borderColor: UIColor?, _ cornerRadius: CGFloat?, _ size: CGSize) -> UIImage? {
        defer {  UIGraphicsEndImageContext() }

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        guard let overlay = UIImage.image(withColor: overlayColor, cornerRadius: cornerRadius, imageSize: size) else { return nil }

        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(cornerRadius ?? 0))
        path.addClip()

        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        overlay.draw(in: CGRect(origin: CGPoint.zero, size: size))

        if let borderColor = borderColor {
            borderColor.setStroke()
            path.lineWidth = 2
            path.stroke()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

