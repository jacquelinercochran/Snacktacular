//
//  SnackUsers.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 11/25/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class SnackUsers{
    var userArray: [SnackUser] = []
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.userArray = [] //clean out existing spotArray since new data will load
            //there are query.Snapchsot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                //make sure you have a dictionary initializer that takes
                let snackUser = SnackUser(dictionary: document.data())
                snackUser.documentID = document.documentID
                self.userArray.append(snackUser)
            }
            completed()
        }
    }
}
