//
//  ViewController.swift
//  MeMe 1.0
//
//  Created by Anna Kulaieva on 8/18/19.
//  Copyright © 2019 Anna Kulaieva. All rights reserved.
//

import UIKit
import AVFoundation

class CreateMemeViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var saveBar: UIToolbar!
    @IBOutlet weak var imageBar: UIToolbar!
    
    func configureTextField(_ textField: UITextField) {
        textField.textAlignment = .center
        textField.delegate = self
        textField.defaultTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Impact", size: 25.0)!, NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.strokeColor : UIColor.black, NSAttributedString.Key.strokeWidth : -2.5]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets default states of textfields, image view and buttons
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        configureTextField(topText)
        configureTextField(bottomText)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        updateImageConstraints(image: UIImage(named: "picPlaceholder")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribeToNotifications()
        tabBarController?.tabBar.isHidden = true
    }
    
    // Calls the unsubscribe function
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Subtracts keyboard height from view origin to slide it up
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomText.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // Adds keyboard height to view origin to slide it back down
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
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
    
    // Updates constraints to fit the chosen image
    func updateImageConstraints(image: UIImage)
    {
        let imageSize: CGSize = image.size
        var bounds: CGRect = view.frame
        bounds.size.height *= 0.7
        let scaledImageSize = AVMakeRect(aspectRatio: imageSize, insideRect: bounds)
        for constraint in memeImage.constraints {
            if let _ = constraint.firstItem as? UIView {
                if constraint.identifier == "memeWidth"
                {
                    constraint.constant = scaledImageSize.width
                }
                else if constraint.identifier == "memeHeight"
                {
                    constraint.constant = scaledImageSize.height
                }
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
            updateImageConstraints(image: memeImage.image!)
        }
        else {
            print("Image not found")
        }
    }
    
    func showPickerController(_ source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    // Shows the "pick an image" VC
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        showPickerController(.photoLibrary)
    }
    
    // Shows the camera view
    @IBAction func clickAnImage(_ sender: UIBarButtonItem) {
        showPickerController(.camera)
    }
   
    // Shows the activity VC
    @IBAction func shareOrSave(_ sender: UIBarButtonItem) {
        if shareButton.isEnabled {
            let meme = generateMeme()
            let shareController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
            shareController.completionWithItemsHandler = {activity, success, items, error in
                if success {
                    self.saveMeme()
                }
            }
            self.present(shareController, animated: true)
        }
    }
    
    // "Grabs" an image context and renders the view hierarchy into a UIImage object
    func generateMeme() -> UIImage {
        let scaleFactor = UIScreen.main.scale
        let scaledRect = memeImage.frame.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, scaleFactor)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        var memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        if let imageRef = memedImage.cgImage?.cropping(to: scaledRect) {
            memedImage = UIImage(cgImage: imageRef)
        }
        return memedImage
    }
    
    // Creates the Meme struct object
    func saveMeme() {
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: memeImage.image!, memedImage: generateMeme())
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    // Unsibscribes from keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Cancels applied changes and reverts image view to initiate state
    @IBAction func cancelChanges(_ sender: UIBarButtonItem) {
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        memeImage.image = UIImage(named: "picPlaceholder")
        updateImageConstraints(image: UIImage(named: "picPlaceholder")!)
        shareButton.isEnabled = false
    }
}
