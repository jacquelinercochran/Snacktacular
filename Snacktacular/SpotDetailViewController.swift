//
//  SpotDetailViewController.swift
//  Snacktacular
//
//  Created by Jackie Cochran on 10/28/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class SpotDetailViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var spot: Spot!
    let regionDistance: CLLocationDegrees = 750.0
    var locationManager: CLLocationManager!
    var reviews: Reviews!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self
        if  spot == nil{
            spot = Spot()
        }
        
        setUpMapView()
        reviews = Reviews() //eventually load data in updateUserInterface
        updateUserInterface()
        getLocation()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reviews.loadData(spot: spot) {
            self.tableView.reloadData()
        }
    }
    
    func setUpMapView(){
        let region = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
    }
    
    func updateUserInterface(){
        nameTextField.text = spot.name
        addressTextField.text = spot.address
        updateMap()
        
    }
    
    func updateMap(){
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(spot)
        mapView.setCenter(spot.coordinate, animated: true)
    }
    
    func updateFromInterface(){
        spot.name = nameTextField.text!
        spot.address = addressTextField.text!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           updateFromInterface()
           switch segue.identifier ?? "" {
           case "AddReview":
               let navigationController = segue.destination as! UINavigationController
               let destination = navigationController.viewControllers.first as! ReviewTableViewController
               destination.spot = spot
           case "ShowReview":
               let destination = segue.destination as! ReviewTableViewController
               let selectedIndexPath = tableView.indexPathForSelectedRow!
               destination.review = reviews.reviewArray[selectedIndexPath.row]
               destination.spot = spot
           default:
               print("Couldn't find a case for segue identifiers, this should not hav ehappened")
           }
       }
       
    
    func saveCancelAlert(title: String, message: String, segueIdentifier: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.spot.saveData { (success) in
                self.performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode{
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        spot.saveData { (success) in
            if success {
                self.leaveViewController()
            }else{
                
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud")
            }
        }
        leaveViewController()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func lookupButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        if spot.documentID == ""{
            saveCancelAlert(title: "This Venue Has Not Been Saved", message: "You mut save this venue before you can review it", segueIdentifier: "AddReview")
        }else{
            performSegue(withIdentifier: "AddReview", sender: nil)
        }
    }
    
}

extension SpotDetailViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    spot.name = place.name ?? "Unknown Place"
    spot.address = place.formattedAddress ?? "Unknown Address"
    spot.coordinate = place.coordinate
    updateUserInterface()
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
//  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//    UIApplication.shared.isNetworkActivityIndicatorVisible = true
//  }
//
//  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//  }

}

extension SpotDetailViewController: CLLocationManagerDelegate{
    
    func getLocation() {
        //creating a CLLocationManager will automatically check authroization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Checking authentication status")
        handleAuthorization(status: status)
    }
    
    func handleAuthorization(status: CLAuthorizationStatus){
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //TODO: handle alert
            self.oneButtonAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select settings below to enable device settings and enable location services for this app")
        case .authorizedAlways:
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("DEVELOPER ALERT: Unknown case of status in handAuthenticalStatus\(status)")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else{
            print("Something went wrong getting the UIApplication.openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Deal with change in location
//        guard spot.name == "" else{
//            return //return if have a spot name, otherwise we'd override the spot info with the current location
//        }
        print("Updating location")
        let currentLocation = locations.last ?? CLLocation()
        print("Current locatioon is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        var name = ""
        var address = ""
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if error != nil {
                print("ERROR: retrieving place. \(error!.localizedDescription)")
            }
            if placemarks != nil {
                //get the first placemark
                let placemark = placemarks?.last
                //assign placemark to locationName
                name = placemark?.name ?? "Name Unknown"
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            }else{
                print("ERROR: retrieving placemark.")
            }
            print("locationName = \(name)")
            //if there is no spot data, make device location the spot
            if self.spot.name == "" && self.spot.address == ""{
                self.spot.name = name
                self.spot.address = address
                self.spot.coordinate = currentLocation.coordinate
            }
            //Update weatherLocations[0] with the current location so it can be used in updateUserInterface. getLocation only called when locationIndex == 0
            self.mapView.userLocation.title = name
            self.mapView.userLocation.subtitle = address.replacingOccurrences(of: "\n", with: ", ")
            self.updateUserInterface()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //deal with error
        print("ERROR: \(error.localizedDescription). Failed to get device locatioon")
    }
}

extension SpotDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! SpotReviewTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        return cell
    }
    
    
}
