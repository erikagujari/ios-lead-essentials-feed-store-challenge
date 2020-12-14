//
//  CoreDataFeedImage+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Erik Agujari on 14/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreDataFeedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataFeedImage> {
        return NSFetchRequest<CoreDataFeedImage>(entityName: "CoreDataFeedImage")
    }

    @NSManaged public var id: UUID
    @NSManaged public var imageDescription: String?
    @NSManaged public var location: String?
    @NSManaged public var url: URL
    @NSManaged public var feed: CoreDataFeed?
    
    public convenience init(id: UUID, imageDescription: String?, location: String?, url: URL, feed: CoreDataFeed?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id
        self.imageDescription = imageDescription
        self.location = location
        self.url = url
        self.feed = feed
    }
}

extension CoreDataFeedImage : Identifiable {

}
