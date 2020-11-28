//
//  ReviewTableViewController.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 11/6/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class ReviewTableViewController: UITableViewController {
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var buttonsBackgroundView: UIView!
    @IBOutlet weak var reviewTitleField: UITextField!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var starButtonCollection: [UIButton]!
    
    var review: Review!
    var spot: Spot!
    var rating = 0 {
        didSet {
            for starButton in starButtonCollection{
                let imageName = (starButton.tag < rating ? "star.fill" : "star")
                starButton.setImage(UIImage(systemName: imageName), for: .normal)
                starButton.tintColor = (starButton.tag < rating ? .systemRed : .darkText)
            }
            review.rating = rating
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard spot != nil else{
            print("ERROR: No spot was passed to ReviewTableViewController.swift")
            return
        }
        if review == nil{
            review = Review()
        }
        updateUserInterface()
    }
    
    func updateUserInterface(){
        nameLabel.text = spot.name
        addressLabel.text = spot.address
        reviewTitleField.text = review.title
        reviewTextView.text = review.text
        rating = review.rating
        reviewDateLabel.text = "posted: \(dateFormatter.string(from: review.date))"
        if review.documentID == ""{//This is a new review
            addBordersToEditableObjects()
        }else{
            if review.reviewUserID == Auth.auth().currentUser?.uid{
                //Review posted by current user
                self.navigationItem.leftItemsSupplementBackButton = false
                saveButton.title = "Update"
                addBordersToEditableObjects()
                deleteButton.isHidden = false
            }else{
                //Review posted by different user
                saveButton.hide()
                cancelButton.hide()
                postedByLabel.text = "Posted by: \(review.reviewUserEmail)"
                for starButton in starButtonCollection{
                    starButton.backgroundColor = .white
                    starButton.isEnabled = false
                }
                reviewTitleField.isEnabled = false
                reviewTitleField.borderStyle = .none
                reviewTextView.isEditable = false
                reviewTitleField.backgroundColor = .white
                reviewTextView.backgroundColor = .white
                
            }
        }
    }
    
    func updateFromUserInterface(){
        review.title = reviewTitleField.text!
        review.text = reviewTextView.text!
    }
    
    func addBordersToEditableObjects(){
        reviewTitleField.addBorder(width: 0.5, radius: 5.0, color: .black)
        reviewTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
        buttonsBackgroundView.addBorder(width: 0.5, radius: 5.0, color: .black)

    }
    
   
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode{
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func reviewTitleChanged(_ sender: UITextField) {
        //prevent a title of blank spaces from being saved too
        let noSpaces = reviewTitleField.text!.trimmingCharacters(in: .whitespaces)
        if noSpaces != "" {
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
    }
    
    
    @IBAction func reviewTitleDonePressed(_ sender: UITextField) {
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        review.deleteData(spot: spot) { (success) in
            if success {
                self.leaveViewController()
            }else{
                print("ERROR: Delete unsuccessful")
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        review.saveData(spot: spot) { (success) in
            if success {
                self.leaveViewController()
            }else{
                print("ERROR: Can't unwind segue from Review because of review saving error")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    
    @IBAction func starButtonPressed(_ sender: UIButton) {
        rating = sender.tag + 1
        
    }
    
    
}
