//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Nadyah Abdulrahman on 22/12/1441 AH.
//  Copyright © 1441 Sarah Alhabib. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var photos:[Photo]!
    
    var dataController:DataController!
    
    var pin:Pin!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
//        self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let space:CGFloat = 1.5
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        navigationController?.setToolbarHidden(false, animated: true)

        fetchImages()
        if photos.count == 0 {
            requestImages()
        }
        
    }
    
    func fetchImages(){
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate=predicate
        do{
            let result = try dataController.viewContext.fetch(fetchRequest)
            photos = result
            collectionView.reloadData()
        }catch {
            fatalError("the fetch could not be performed \(error.localizedDescription)")
        }
    }
    
    @IBAction func requestNewCollection(_ sender: Any) {
        if photos != nil && photos.count>0{
        deletePhotos()
        }
        photos.removeAll()
        requestImages()
    }
    
    func requestImages(){
        Network.getPhotosData(lat: pin.latitude, lon: pin.longitude) { (photosData, error) in
            guard let photosData = photosData else{
                self.showRequestImageFaultAlert()
                return
            }
            for data in photosData{
                let photo = Photo(context: self.dataController.viewContext)
                photo.image = data
                photo.pin = self.pin
                self.photos.append(photo)
            }
            try? self.dataController.viewContext.save()
            self.collectionView.reloadData()
        }
    }
    
    func deletePhotos(){
        for photo in photos{
            dataController.viewContext.delete(photo)
        }
        try? dataController.viewContext.save()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.imageView?.image = UIImage(named: "placeHolder")
        cell.imageView?.image = UIImage(data: photos[indexPath.row].image!)
    
        return cell
    }

    // MARK: delete image
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
        let photoToRemove = photos[indexPath.item]
        photos.remove(at: indexPath.item)
        dataController.viewContext.delete(photoToRemove)
        try? dataController.viewContext.save()
    }

    
    //MARK: Alert
    
    func showRequestImageFaultAlert() {
        let alert = UIAlertController(title: "Ops!", message: "images could not be downloaded, click new collection please", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
