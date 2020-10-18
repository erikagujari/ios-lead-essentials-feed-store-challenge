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
        context = CoreDataFeedStore.container()?.newBackgroundContext()
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
        guard let context = context
        else {
            completion(CoreDataError.insertionError)
            return
        }
        
        let coreDataImages = feed.map { CoreDataFeedImageMapper.fromLocalFeedImage($0) }
        let coreDataFeed = CoreDataFeed(context: context)
        coreDataFeed.images = coreDataImages
        coreDataFeed.timestamp = timestamp
        
        save(context: context, errorCompletion: completion)
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let context = context,
              let fetch = try? context.fetch(CoreDataFeed.fetchRequest()) as? [CoreDataFeed]
        else {
            completion(.failure(CoreDataError.retrieveError))
            return
        }
        
        guard let coreDataFeed = fetch.first,
              !coreDataFeed.images.isEmpty
        else {
            completion(.empty)
            return
        }
        
        completion(.found(feed: coreDataFeed.images.compactMap { CoreDataFeedImageMapper.toLocalFeedImage($0) }, timestamp: coreDataFeed.timestamp))
    }
}

private extension CoreDataFeedStore {
    static func container() -> NSPersistentContainer? {
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
    }
    
    enum CoreDataError: Error {
        case retrieveError
        case insertionError
        case deleteError
    }
    
    struct CoreDataFeedImageMapper {
        static func toLocalFeedImage(_ coreDataFeedImage: CoreDataFeedImage) -> LocalFeedImage? {
            guard let id = coreDataFeedImage.id,
                  let imageUrl = coreDataFeedImage.url,
                  let uuid = UUID(uuidString: id),
                  let url = URL(string: imageUrl)
            else { return nil }
            return LocalFeedImage(id: uuid,
                                  description: coreDataFeedImage.imageDescription,
                                  location: coreDataFeedImage.location,
                                  url: url)
        }
        
        static func fromLocalFeedImage(_ localFeedImage: LocalFeedImage) -> CoreDataFeedImage {
            return CoreDataFeedImage(id: localFeedImage.id.uuidString,
                                     imageDescription: localFeedImage.description,
                                     location: localFeedImage.location,
                                     url: localFeedImage.url.absoluteString)
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
