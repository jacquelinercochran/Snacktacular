//
//  Review.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 11/7/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewUserID: String
    var date: Date
    var documentID: String

//create dictionary to take properties of class and turn it into dictionary that Firestore can do
    var dictionary: [String: Any]{
        //make date type conversion so firebase can store it
        let timeIntervalDate = date.timeIntervalSince1970
        return["title": title, "text": text, "rating": rating, "reviewUserID": reviewUserID,"date": timeIntervalDate, "documentID": documentID]
    }
    
   //base initializer
    init(title: String, text:String, rating: Int, reviewUserID: String, date: Date, documentID: String){
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewUserID = reviewUserID
        self.date = date
        self.documentID = documentID
        
    }
    
    //convenience initializer
    convenience init(){
        let reviewUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(title: "", text: "", rating: 0, reviewUserID: reviewUserID, date: Date(), documentID: "")
    }
    
 
    convenience init(dictionary: [String: Any]){
        //downcasts dictionary value to types we need
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let reviewUserID = dictionary["reviewUserID"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        //always have to call back to base initializer
        self.init(title: title, text: text, rating: rating, reviewUserID: reviewUserID, date: date, documentID: documentID)
    }
    
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
            let db = Firestore.firestore()
            //Create the dictionary representing data we want to save
            let dataToSave: [String: Any] = self.dictionary
            //if we have a saved record, well have an ID, otherwise .addDocument will create one
            if self.documentID == "" { //Create a new document via .addDocument
                var ref: DocumentReference? = nil //firestore will create a new ID for us
                ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave){ (error) in
                    guard error == nil else{
                        print("ERROR: adding document \(error?.localizedDescription)")
                        return completion(false)
                    }
                    self.documentID = ref!.documentID
                    print("Added a document: \(self.documentID)") //it works!
                }
            }else { //else save to the existing documentID with setData
                let ref = db.collection("spots").document(spot.documentID).collection("Reviews").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else{
                        print("ERROR: updating document \(error?.localizedDescription)")
                        return completion(false)
                    }
                    print("Updated document: \(self.documentID)")
                    completion(true)
            }
        }
        
    }

}
