//
//  Spot.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 10/29/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase
import MapKit

class Spot: NSObject, MKAnnotation{
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserId: String
    var documentID: String
    
    //need a dictionary when we save things to cloud firestore
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "latitude": latitude, "longitude": longitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserId]
    }
    
    var latitude: CLLocationDegrees{
        return coordinate.latitude
    }
    var longitude: CLLocationDegrees{
        return coordinate.longitude
    }
    var title: String? {
        return name
    }
    var subtitle: String? {
        return address
    }
    var location: CLLocation{
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String){
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserId = postingUserID
        self.documentID = documentID
        
        
    }
    
    convenience override init(){
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(),averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longitude = dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReviews: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = Auth.auth().currentUser?.uid else{
            print("ERROR: Could not save data because we don't have a valid postingUserID.")
            return completion(false)
        }
        self.postingUserId = postingUserID
        //Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        //if we have a saved record, well have an ID, otherwise .addDocument will create one
        if self.documentID == "" { //Create a new document via .addDocument
            var ref: DocumentReference? = nil //firestore will create a new ID for us
            ref = db.collection("spots").addDocument(data: dataToSave){ (error) in
                guard error == nil else{
                    print("ERROR: adding document \(error?.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added a document: \(self.documentID)") //it works!
            }
        }else { //else save to the existing documentID with setData
            let ref = db.collection("spots").document(self.documentID)
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
