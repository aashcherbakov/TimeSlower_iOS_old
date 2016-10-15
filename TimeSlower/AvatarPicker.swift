//
//  AvatarPicker.swift
//  TimeSlower
//
//  Created by Alexander Shcherbakov on 10/8/16.
//  Copyright © 2016 Oleksandr Shcherbakov. All rights reserved.
//

import Foundation

/// Struct responsible for creation controllers to pick or create a picture of user
internal struct AvatarPicker {
    
    private var imagePickerDelegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    init(withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        imagePickerDelegate = delegate
    }
    
    /// Creates instance of UIImagePickerController with sourcy type .PhotoLibrary
    ///
    /// - returns: UIImagePickerController?
    func photoPicker() -> UIImagePickerController? {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let photoPicker = UIImagePickerController()
            photoPicker.sourceType = .photoLibrary
            photoPicker.delegate = imagePickerDelegate
            photoPicker.allowsEditing = true
            return photoPicker
        }
        
        return nil
    }
    
    
    /// Looks for image from given info by UIImagePickerControllerEditedImage or
    /// UIImagePickerControllerOriginalImage key
    ///
    /// - parameter info: [String:Any] returned from
    /// imagePickerController:didFinishPickingMediaWithInfo: method
    ///
    /// - returns: selected UIImage?
    func image(fromInfo info: [String : Any]) -> UIImage? {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        return image
    }
}
