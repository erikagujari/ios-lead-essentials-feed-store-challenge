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
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
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
        
        completion(.found(feed: coreDataFeed.images.compactMap { $0.toLocalFeedImage() }, timestamp: coreDataFeed.timestamp))
    }
}

private extension CoreDataFeedStore {
    static func container() -> NSPersistentContainer? {
        let fileName = "CoreDataFeed"
        guard let url = Bundle(for: CoreDataFeed.self).url(forResource: fileName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: url)
        else { return nil }
        
        return NSPersistentContainer(name: fileName, managedObjectModel: managedObjectModel)
    }
    
    enum CoreDataError: Error {
        case retrieveError
    }
}
