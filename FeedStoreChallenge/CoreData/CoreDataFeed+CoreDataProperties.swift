//
//  CoreDataFeed+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Erik Agujari on 11/12/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreDataFeed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataFeed> {
        return NSFetchRequest<CoreDataFeed>(entityName: "CoreDataFeed")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var images: NSOrderedSet

}

// MARK: Generated accessors for images
extension CoreDataFeed {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: CoreDataFeedImage)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: CoreDataFeedImage)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension CoreDataFeed : Identifiable {

}
