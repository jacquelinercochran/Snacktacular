//
//  PhotoViewController.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 11/12/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    var spot: Spot!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard spot != nil else{
            print("ERROR: No spot passed to PhotoViewController.swift")
            return
        }
        
        if photo == nil {
            photo = Photo()
        }
        
        updateUserInterface()
        // Do any additional setup after loading the view.
    }
    
    func updateUserInterface() {
        postedByLabel.text = "by: \(photo.photoUserEmail)"
        dateLabel.text = "on: \(dateFormatter.string(from: photo.date))"
        descriptionTextView.text = photo.description
        
        if photo.documentID == ""{//This is a new review
            addBordersToEditableObjects()
        }else{
            if photo.photoUserID == Auth.auth().currentUser?.uid {
                //Review posted by current user
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                self.navigationController?.setToolbarHidden(false, animated: true)
            }else{
                //Review posted by different user
                saveBarButton.hide()
                cancelBarButton.hide()
                postedByLabel.text = "Posted by: \(photo.photoUserEmail)"
                descriptionTextView.isEditable = false
                descriptionTextView.backgroundColor = .white
                
            }
        }
        guard let url = URL(string: photo.photoURL) else{
            //then this must be a new image so get image from photo.image passed in rather than from the url
            photoImageView.image = photo.image
            return
        }
        photoImageView.sd_imageTransition = .fade
        photoImageView.sd_imageTransition?.duration = 0.5
        photoImageView.sd_setImage(with: url)
    }
    
    
    func updateFromUserInterface(){
        photo.description = descriptionTextView.text!
        photo.image = photoImageView.image!
    }
    
    func addBordersToEditableObjects() {
        descriptionTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode{
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }

   
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        photo.deleteData(spot: spot) { (success) in
            if success{
                self.leaveViewController()
            }else{
                print("ERROR: delete unsuccesful")
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        photo.saveData(spot: spot) { (success) in
            if success {
                self.leaveViewController()
            }else{
                print("ERROR: Cannot unwind segue from PhotoViewController because of photo saving error")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
}
