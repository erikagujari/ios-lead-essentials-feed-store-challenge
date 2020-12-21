//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Erik Agujari on 03/10/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import CoreData

public struct CoreDataFeedStore: FeedStore {
    private let context: NSManagedObjectContext
    
    public init(localURL: URL) throws {
        let fileName = "CoreDataFeed"
        guard let url = Bundle(for: CoreDataFeed.self).url(forResource: fileName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: url)
        else { throw CoreDataError.loadError }
        
        let container: NSPersistentContainer = NSPersistentContainer(name: fileName, managedObjectModel: managedObjectModel)
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: localURL)]
        var persistentError: Error?
        
        container.loadPersistentStores { (_, error) in
            persistentError = error
        }
        guard persistentError == nil else { throw CoreDataError.loadError }
        
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        context.perform {
            do {
                let fetch = try context.fetch(CoreDataFeed.fetchRequest()) as [NSManagedObject]
                fetch.forEach { feed in
                    context.delete(feed)
                }
                save(context: context, errorCompletion: completion)
            } catch let error {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        deleteCachedFeed { error in
            if let error = error {
                completion(error)
            } else {
                let coreDataFeed = CoreDataFeed(context: context)
                let coreDataFeedImages = feed.map { CoreDataFeedImageMapper.fromLocalFeedImage($0, feed: coreDataFeed, context: context)}
                
                coreDataFeed.images = NSOrderedSet(array: coreDataFeedImages)
                coreDataFeed.timestamp = timestamp
                
                save(context: context, errorCompletion: completion)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform {
            do {
                guard let fetch = try context.fetch(CoreDataFeed.fetchRequest()) as? [CoreDataFeed],
                      let coreDataFeed = fetch.first,
                      let imageSet = coreDataFeed.images.array as? [CoreDataFeedImage]
                else {
                    completion(.empty)
                    return
                }
                let timestamp = coreDataFeed.timestamp
                completion(.found(feed: imageSet.map { CoreDataFeedImageMapper.toLocalFeedImage($0) }, timestamp: timestamp))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
}

private extension CoreDataFeedStore {    
    enum CoreDataError: Error {
        case loadError
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
            errorCompletion(error)
        }
    }
}
