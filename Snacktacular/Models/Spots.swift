//
//  Spots.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 10/30/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class Spots{
    var spotArray: [Spot] = []
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("spots").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.spotArray = [] //clean out existing spotArray since new data will load
            //there are query.Snapchsot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                //make sure you have a dictionary initializer that takes
                let spot = Spot(dictionary: document.data())
                spot.documentID = document.documentID
                self.spotArray.append(spot)
            }
            completed()
        }
    }
}
