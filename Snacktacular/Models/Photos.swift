//
//  Photos.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 11/13/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase


class Photos {
    var photoArray: [Photo] = []
    
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentID != "" else{
            return
        }
        db.collection("spots").document(spot.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.photoArray = [] //clean out existing spotArray since new data will load
            //there are query.Snapchsot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                //make sure you have a dictionary initializer that takes
                let photo = Photo(dictionary: document.data())
                photo.documentID = document.documentID
                self.photoArray.append(photo)
            }
            completed()
        }
    }
    
}
