//
//  CoreDataManager.swift
//  LetsEat
//
//  Created by Xinyi Li on 14/10/2018.
//  Copyright © 2018 shawneeluis. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    let container: NSPersistentContainer
//    let selectId: Int?
    
    
    override init() {
        container = NSPersistentContainer(name: "LetsEatModel")
        container.loadPersistentStores { (storeDesc, error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
        }
        
        super.init()
    }
    
    func addReview(_ item: ReviewItem) {
        let review = Review(context: container.viewContext)
        review.title = item.title
        review.name = item.name
        review.date = NSDate() as Date
        if let rating = item.rating { review.rating = rating }
        review.customerReview = item.customerReview
        review.uuid = item.uuid
        
        if let id = item.restaurantID {
            review.restaurantID = Int32(id)
//            print("restaurant id \(id)")
            save()
        }
    }
    
    func addPhoto(_ item: RestaurantPhotoItem) {
        let photo = RestaurantPhoto(context: container.viewContext)
        photo.date = NSDate() as Date
        photo.photo = item.photoData as Data
        photo.uuid = item.uuid
        
        if let id = item.restaurantID {
            photo.restaurantID = Int32(id)
//            print("restaurant id \(id)")
            save()
        }
    }
    
    fileprivate func save() {
        do {
            if container.viewContext.hasChanges {
                try container.viewContext.save()
//                print("saved")
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchReviews(by identifier: Int) -> [ReviewItem] {
        let moc = container.viewContext
        let request: NSFetchRequest<Review> = Review.fetchRequest()
        let predicate = NSPredicate(format: "restaurantID = %i", Int32(identifier))
        
        var items:[ReviewItem] = []
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = predicate
        
        do {
            for data in try moc.fetch(request) {
                items.append(ReviewItem(data: data))
            }
            return items
        } catch {
            fatalError("Failed to fetch reviews: \(error)")
        }
    }
    
    func fetchPhotos(by identifier: Int) -> [RestaurantPhotoItem] {
        let moc = container.viewContext
        let request: NSFetchRequest<RestaurantPhoto> = RestaurantPhoto.fetchRequest()
        let predicate = NSPredicate(format: "restaurantID = %i", Int32(identifier))
        
        var items:[RestaurantPhotoItem] = []
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = predicate
        
        do {
            for data in try moc.fetch(request) {
                items.append(RestaurantPhotoItem(data: data))
            }
            return items
            
        } catch {
            fatalError("Failed to fetch photos: \(error)")
        }
    }
    
    func fetchRestaurantRating(by identifier: Int) -> Float {
        let reviews = fetchReviews(by: identifier).map({ $0 })
        let sum = reviews.reduce(0, { $0 + ($1.rating ?? 0)})
        return sum / Float(reviews.count)
    }

    func addFavorite(by restaurantID: Int) {
        let item = Favorite(context: container.viewContext)
        item.restaurantID = Int32(restaurantID)
        
        save()
    }
    
    func isFavorite(with identifier: Int) -> Bool {
        let moc = container.viewContext
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        let predicate = NSPredicate(format: "restaurantID = %i", Int32(identifier))
        request.predicate = predicate
        do {
            let count = try moc.count(for: request)
            if count == 0 { return false }
            else { return true }
        } catch {
            fatalError("Failed to fetch reviews: \(error)")
        }
    }
}
