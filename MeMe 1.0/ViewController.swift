//
//  ViewController.swift
//  MeMe 1.0
//
//  Created by Anna Kulaieva on 8/18/19.
//  Copyright © 2019 Anna Kulaieva. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        let memedImage: UIImage
    }
    
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var saveBar: UIToolbar!
    @IBOutlet weak var imageBar: UIToolbar!
    
    var bottomEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets default states of textfields and buttons
        subscribeToNotifications()
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = .center
        let textFieldsAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Impact", size: 25.0)!, NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.strokeColor : UIColor.black, NSAttributedString.Key.strokeWidth : -2.5, NSAttributedString.Key.paragraphStyle : paragraphStyle]
        topText.defaultTextAttributes = textFieldsAttributes
        bottomText.defaultTextAttributes = textFieldsAttributes
        topText.delegate = self
        bottomText.delegate = self
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    // Returns the height of the keyboard for textfields input
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Subscribe to keyboard notifications (keyboard sliding up when the textfield editing begins and down, when it ends)
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    // Subtracts keyboard height from view origin to slide it up
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomText.isEditing {
            bottomEdited = true
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // Adds keyboard height to view origin to slide it back down
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomEdited {
            bottomEdited = false
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    // Clears textfields contents when first editing begins
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    // Hides keyboard, when enter is hit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Calculates an actual size of chosen picture on the screen
    func calculateRealImageView(imageView: UIImageView) -> CGFloat
    {
        let imageViewSize: CGSize = imageView.frame.size
        let imageSize: CGSize = imageView.image!.size
        let scaleW: CGFloat = imageViewSize.width / imageSize.width
        let scaleH: CGFloat = imageViewSize.height / imageSize.height
        let aspect: CGFloat = fmin(scaleW, scaleH)
        var aspectHeight = imageSize.height
        aspectHeight *= aspect
        let deltaY = (memeImage.frame.height - aspectHeight) / 2
        return(deltaY)
    }
    
    // Slides top and bottom textfield to fit it on the actual picked image
    func updateTextFieldConstraints(didCancel: Bool) {
        var deltaY: CGFloat = 0
        if didCancel == false {
            deltaY = calculateRealImageView(imageView: memeImage)
        }
        else {
            deltaY = 115
        }
        for constraint in self.view.constraints {
            if constraint.identifier == "topTextConstant" {
                constraint.constant = deltaY
            }
            else if constraint.identifier == "bottomTextConstant" {
                constraint.constant = -deltaY
            }
        }
    }
    
    // Sets the "image" property of the meme image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true
        cancelButton.isEnabled = true
        if let image = info[.originalImage] as? UIImage {
            memeImage.image = image
            updateTextFieldConstraints(didCancel: false)
        }
        else {
            print("Image not found")
        }
    }
    
    // Shows the "pick an image" VC
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let libraryController = UIImagePickerController()
        libraryController.sourceType = .photoLibrary
        libraryController.delegate = self
        present(libraryController, animated: true)
    }
    
    // Shows the camera view
    @IBAction func clickAnImage(_ sender: UIBarButtonItem) {
        let libraryController = UIImagePickerController()
        libraryController.sourceType = .camera
        libraryController.delegate = self
        present(libraryController, animated: true)
    }
   
    // Shows the activity VC
    @IBAction func shareOrSave(_ sender: UIBarButtonItem) {
        if shareButton.isEnabled {
            let meme = generateMeme()
            let shareController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
            present(shareController, animated: true)
        }
    }
    
    // "Grabs" an image context and renders the view hierarchy into a UIImage object
    func generateMeme() -> UIImage {
        saveBar.isHidden = true
        imageBar.isHidden = true
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        saveBar.isHidden = false
        imageBar.isHidden = false
        return memedImage
    }
    
    // Creates the Meme struct object
    func saveMeme() {
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: memeImage.image!, memedImage: generateMeme())
    }
    
    // Unsibscribes from keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Cancels applied changes and reverts image view to initiate state
    @IBAction func cancelChanges(_ sender: UIBarButtonItem) {
        updateTextFieldConstraints(didCancel: true)
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        memeImage.image = nil
    }
    
    // Calls the unsubscribe function
    deinit {
        unsubscribeFromKeyboardNotifications()
    }
}
