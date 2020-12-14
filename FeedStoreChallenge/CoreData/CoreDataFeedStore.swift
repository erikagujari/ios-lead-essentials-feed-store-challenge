//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Erik Agujari on 03/10/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import CoreData

public struct CoreDataFeedStore: FeedStore {
    let context: NSManagedObjectContext?
    
    public init() {
        context = CoreDataFeedStore.container?.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        guard let context = context,
              let fetch = try? context.fetch(CoreDataFeed.fetchRequest()) as? [CoreDataFeed]
        else {
            completion(CoreDataError.deleteError)
            return
        }
        fetch.forEach { feed in
            context.delete(feed)
        }
        
        save(context: context, errorCompletion: completion)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        deleteCachedFeed { error in
            guard error == nil,
                  let context = context
            else {
                completion(CoreDataError.insertionError)
                return
            }
            let coreDataFeed = CoreDataFeed(context: context)
            feed.forEach { coreDataFeed.addToImages(CoreDataFeedImageMapper.fromLocalFeedImage($0, feed: coreDataFeed, context: context)) }
            coreDataFeed.timestamp = timestamp
            
            save(context: context, errorCompletion: completion)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let context = context,
              let fetch = try? context.fetch(CoreDataFeed.fetchRequest()) as? [CoreDataFeed]
        else {
            completion(.failure(CoreDataError.retrieveError))
            return
        }
        
        guard let coreDataFeed = fetch.first,
              let imageSet = coreDataFeed.images as? Set<CoreDataFeedImage>,
              let timestamp = coreDataFeed.timestamp,
              imageSet.count != 0
        else {
            completion(.empty)
            return
        }
        
        completion(.found(feed: imageSet.compactMap { CoreDataFeedImageMapper.toLocalFeedImage($0) }, timestamp: timestamp))
    }
}

private extension CoreDataFeedStore {
    static var container: NSPersistentContainer? = {
        let fileName = "CoreDataFeed"
        guard let url = Bundle(for: CoreDataFeed.self).url(forResource: fileName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: url)
        else { return nil }
        
        var container: NSPersistentContainer? = NSPersistentContainer(name: fileName, managedObjectModel: managedObjectModel)
        
        container?.loadPersistentStores { (_, error) in
            guard error != nil else { return }
            container = nil
        }
        
        return container
    }()
    
    enum CoreDataError: Error {
        case retrieveError
        case insertionError
        case deleteError
    }
    
    struct CoreDataFeedImageMapper {
        static func toLocalFeedImage(_ coreDataFeedImage: CoreDataFeedImage) -> LocalFeedImage {
            return LocalFeedImage(id: coreDataFeedImage.id,
                                  description: coreDataFeedImage.imageDescription,
                                  location: coreDataFeedImage.location,
                                  url: coreDataFeedImage.url)
        }
        
        static func fromLocalFeedImage(_ localFeedImage: LocalFeedImage, feed: CoreDataFeed, context: NSManagedObjectContext) -> CoreDataFeedImage {
            return CoreDataFeedImage(id: localFeedImage.id,
                                     imageDescription: localFeedImage.description,
                                     location: localFeedImage.location,
                                     url: localFeedImage.url,
                                     feed: feed,
                                     context: context)
        }
    }
    
    func save(context: NSManagedObjectContext, errorCompletion: (Error?) -> Void) {
        do {
            try context.save()
            errorCompletion(nil)
        } catch {
            print(error)
            errorCompletion(error)
        }
    }
}
