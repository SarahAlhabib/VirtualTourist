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

    //MARK: Set Up
    @IBOutlet weak var mapView: MKMapView!
    
    var pins:[Pin]!
    
    var dataController:DataController!
    
    var selectedPin:Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPins()
        setUpMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
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
    

    //MARK: Map View DataSource
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.isDraggable = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    //MARK: Map View Delegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinates = view.annotation?.coordinate
        for pin in pins {
            if pin.latitude==coordinates!.latitude && pin.longitude==coordinates!.longitude {
            selectedPin = pin
            }
        }
        performSegue(withIdentifier: "photoAlbumSegue", sender: self)
    }

    @IBAction func mapTap(_ sender: Any) {
        let sender = sender as! UILongPressGestureRecognizer
        
        if sender.state == .ended{
            addPinToMapView(sender: sender)
        }
    }
    
    //MARK: Drag pin feature
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        let annotationToDelete: CLLocationCoordinate2D!
        let newAnnotation: CLLocationCoordinate2D!
        
        if view.dragState == .starting {
            annotationToDelete = view.annotation?.coordinate
            deletePinFromModel(coordinates: annotationToDelete)
        }
        if view.dragState == .ending {
            newAnnotation = view.annotation?.coordinate
            addPinToModel(coordinates: newAnnotation)
        }
    }
    
    //MARK: Editting
    
    func addPinToMapView(sender: UILongPressGestureRecognizer){
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
        pins.append(pin)
        try? dataController.viewContext.save()
    }
    
    func deletePinFromModel(coordinates: CLLocationCoordinate2D){
        var pinToDelete:Pin?
        var i = 0
        for pin in pins {
            if pin.latitude==coordinates.latitude && pin.longitude==coordinates.longitude {
                pinToDelete = pin
                pins.remove(at: i)
            }
            i+=1
        }
        if let pinToDelete = pinToDelete {
            dataController.viewContext.delete(pinToDelete)
            try? dataController.viewContext.save()
        }
        
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CollectionViewController
        vc.dataController = dataController
        vc.pin = selectedPin
    }
}

