//
//  ImagePickerController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-07-04.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import TOCropViewController
import RaceSyncAPI

protocol ImagePickerDelegate {

}

class ImagePickerController: NSObject {

    let imagePicker = UIImagePickerController()
    var croppingStyle: TOCropViewCroppingStyle = .circular
    var completion: ObjectCompletionBlock<UIImage>?

    func presentImagePicker(croppingStyle: TOCropViewCroppingStyle = .circular, _ completion: ObjectCompletionBlock<UIImage>?) {

        self.croppingStyle = croppingStyle
        self.completion = completion

        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self

        UIViewController.topMostViewController()?.present(imagePicker, animated: true, completion: nil)
    }
}

extension ImagePickerController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }

        let cropVC = TOCropViewController(croppingStyle: croppingStyle, image: image)
        cropVC.doneButtonTitle = "Upload"
        cropVC.cancelButtonTitle = "Back"
        cropVC.delegate = self
        cropVC.resetAspectRatioEnabled = false

        if croppingStyle == .default {
            cropVC.customAspectRatio = CGSize(width: 1100, height: 620)
            cropVC.aspectRatioLockDimensionSwapEnabled = false
            cropVC.aspectRatioLockEnabled = true
        }

        DispatchQueue.main.async {
            picker.pushViewController(cropVC, animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ImagePickerController: TOCropViewControllerDelegate {

    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        handle(image: image, with: cropRect)
    }

    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        handle(image: image, with: cropRect)
    }

    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.navigationController?.popViewController(animated: true)
    }

    fileprivate func handle(image: UIImage, with cropRect: CGRect) {
        //let croppedImage = image.cropImage(to: cropRect) // already cropped apparently
        completion?(image, nil)

        DispatchQueue.main.async { [weak self] in
            self?.imagePicker.dismiss(animated: true)
        }
    }
}
