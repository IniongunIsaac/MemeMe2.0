//
//  ViewController.swift
//  MemeMe2.0
//
//  Created by Isaac Iniongun on 05/12/2019.
//  Copyright © 2019 Ing Groups. All rights reserved.
//

import UIKit
import RSKImageCropper

class CreateMemeViewController: UIViewController {

    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
    @IBOutlet weak var topTextfield: UITextField!
    @IBOutlet weak var bottomTextfield: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var shareMemeMeButton: UIBarButtonItem!
    
    let pickerController = UIImagePickerController()
    
    let textSize = 40
    
    var memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.strokeWidth : -2.0
    ]
    
    let topText = "TOP"
    let bottomText = "BOTTOM"
    
    fileprivate var shouldAdjustViewFrame = false
    
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var currentMeme: Meme?
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerController.delegate = self
        memeImageView.contentMode = .scaleAspectFit
        
        topTextfield.delegate = self
        bottomTextfield.delegate = self
        
        setTextfieldTextWithAttributes(topTextfield, topText)
        setTextfieldTextWithAttributes(bottomTextfield, bottomText)
        
        setMemeDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        toggleShareMemeMeButtonIsEnabledProperty(memeImageView.image != nil)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    // MARK: - IBAction Methods
    
    @IBAction func pickImageFromCamera(_ sender: UIBarButtonItem) {
        
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func pickImageFromPhotoLibrary(_ sender: UIBarButtonItem) {
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareMemeMe(_ sender: Any) {
        
        let memedImage = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { [weak self] type, completed, items, error in
            
            if completed {
               self?.save(memedImage)
            }
            
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        present(activityVC, animated: true, completion: nil)
        
    }
    
    @IBAction func fontSelectorTapped(_ sender: UIBarButtonItem) {
        showFontStylesActionSheet()
    }
    
    //MARK:- Private Utility Methods
    
    fileprivate func setMemeDetails() {
        if let currentMeme = currentMeme {
            setTextfieldTextWithAttributes(topTextfield, currentMeme.topText)
            setTextfieldTextWithAttributes(bottomTextfield, currentMeme.bottomText)
            memeImageView.image = currentMeme.originalImage
        }
    }
    
    fileprivate func toggleShareMemeMeButtonIsEnabledProperty(_ shouldEnable: Bool) {
        shareMemeMeButton.isEnabled = shouldEnable
    }
    
    fileprivate func setTextfieldTextWithAttributes(_ textfield: UITextField, _ text: String) {
        textfield.text = text
        textfield.defaultTextAttributes = memeTextAttributes
        textfield.textAlignment = .center
    }
    
    fileprivate func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        if shouldAdjustViewFrame {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc fileprivate func keyboardWillHide() {
        if shouldAdjustViewFrame {
            view.frame.origin.y = 0
        }
    }
    
    fileprivate func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func generateMemedImage() -> UIImage {

        //Hide toolbar and navbar
        hideOrShowNavBarAndBottomToolbar(true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        //Show toolbar and navbar
        hideOrShowNavBarAndBottomToolbar(false)

        return memedImage
    }
    
    fileprivate func hideOrShowNavBarAndBottomToolbar(_ shouldShow: Bool) {
        bottomToolbar.isHidden = shouldShow
        navigationController?.navigationBar.isHidden = shouldShow
    }
    
    fileprivate func save(_ memedImage: UIImage) {
        
        //if we're editing a meme then we just want to update it
        if let currentMeme = currentMeme {
            var meme = appDelegate.memes.first { $0.id == currentMeme.id }
            meme?.topText = topTextfield.text!
            meme?.bottomText = bottomTextfield.text!
            meme?.originalImage = memeImageView.image!
            meme?.memedImage = memedImage
            
            let index = appDelegate.memes.firstIndex { $0.id == currentMeme.id }!
            appDelegate.memes[index] = meme!
            
        } else {
            // Create the meme
            let meme = Meme(topText: topTextfield.text!, bottomText: bottomTextfield.text!, originalImage: memeImageView.image!, memedImage: memedImage)
            //save the meme
            appDelegate.memes.append(meme)
        }
        
    }
    
    fileprivate func showFontStylesActionSheet() {
        
        let alertController = UIAlertController(title: "Font Styles", message: "Select your preferred font style", preferredStyle: .actionSheet)
        
        let defaultFont = UIAlertAction(title: "Default", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.memeTextAttributes[NSAttributedString.Key.font] = UIFont(name: "Impact", size: CGFloat(self.textSize))
            self.setTextfieldTextWithAttributes(self.topTextfield, self.topTextfield.text!)
            self.setTextfieldTextWithAttributes(self.bottomTextfield, self.bottomTextfield.text!)
            
        }
        
        let courierFont = UIAlertAction(title: "Courier", style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.memeTextAttributes[NSAttributedString.Key.font] = UIFont(name: "Courier", size: CGFloat(self.textSize))
            self.setTextfieldTextWithAttributes(self.topTextfield, self.topTextfield.text!)
            self.setTextfieldTextWithAttributes(self.bottomTextfield, self.bottomTextfield.text!)
            
        }
        
        let georgiaFont = UIAlertAction(title: "Georgia", style: .default) { [weak self] _ in
        
            guard let self = self else { return }
            
            self.memeTextAttributes[NSAttributedString.Key.font] = UIFont(name: "Georgia", size: CGFloat(self.textSize))
            self.setTextfieldTextWithAttributes(self.topTextfield, self.topTextfield.text!)
            self.setTextfieldTextWithAttributes(self.bottomTextfield, self.bottomTextfield.text!)
            
        }
        
        let helveticaNeueFont = UIAlertAction(title: "Helvetica Neue", style: .default) { [weak self] _ in
        
            guard let self = self else { return }
            
            self.memeTextAttributes[NSAttributedString.Key.font] = UIFont(name: "HelveticaNeue", size: CGFloat(self.textSize))
            self.setTextfieldTextWithAttributes(self.topTextfield, self.topTextfield.text!)
            self.setTextfieldTextWithAttributes(self.bottomTextfield, self.bottomTextfield.text!)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(defaultFont)
        alertController.addAction(courierFont)
        alertController.addAction(georgiaFont)
        alertController.addAction(helveticaNeueFont)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}

//MARK: - UITextFieldDelegate Methods

extension CreateMemeViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = textField.text!.uppercased()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == topText || textField.text == bottomText {
            textField.text = ""
        }
        
        if textField.tag == 2 {
            shouldAdjustViewFrame = true
        } else {
            shouldAdjustViewFrame = false
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 && textField.text == "" {
            textField.text = topText
        }
        if textField.tag == 2 && textField.text == "" {
            textField.text = bottomText
        }
    }
    
    
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate and RSKImageCropViewControllerDelegate Methods

extension CreateMemeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            toggleShareMemeMeButtonIsEnabledProperty(true)
            
            var imageCropVC: RSKImageCropViewController!
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.square)
            imageCropVC.delegate = self
            navigationController?.pushViewController(imageCropVC, animated: true)
        
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        memeImageView.image = croppedImage
        
        navigationController?.popViewController(animated: true)
    }
    
}
