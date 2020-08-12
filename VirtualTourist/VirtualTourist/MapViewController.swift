//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Nadyah Abdulrahman on 22/12/1441 AH.
//  Copyright © 1441 Sarah Alhabib. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var pins:[Pin]!
    
    var dataController:DataController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPins()
        setUpMapView()
    }
    
    func fetchPins() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do{
            let result = try dataController.viewContext.fetch(fetchRequest)
            pins = result
        }catch {
            fatalError("the fetch could not be performed \(error.localizedDescription)")
        }
        
    }
    
    fileprivate func setUpMapView() {
        
        mapView.delegate=self
        
        var annotations = [MKPointAnnotation]()
        
        for pin in pins {
            
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            //pinView!.isDraggable = true
        }
        else {
            pinView!.annotation = annotation
        }
            
        return pinView
    }

    
    @IBAction func mapTap(_ sender: Any) {
        let sender = sender as! UITapGestureRecognizer
        
        if sender.state == .ended{
            addPinToMapView(sender: sender)
        }
    }
    
    func addPinToMapView(sender: UITapGestureRecognizer){
        let location = sender.location(in: mapView)
        let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        mapView.addAnnotation(annotation)
        addPinToModel(coordinates: coordinates)
    }
    
    func addPinToModel(coordinates: CLLocationCoordinate2D){
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        
        try? dataController.viewContext.save()
    }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
//        let annotationToDelete: MKAnnotation =
//    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "photoAlbumSegue", sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        <#code#>
//    }
}

