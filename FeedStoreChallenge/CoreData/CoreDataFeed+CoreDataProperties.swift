//
//  CoreDataFeed+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Erik Agujari on 03/10/2020.
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
    @NSManaged public var images: [CoreDataFeedImage]
}

extension CoreDataFeed : Identifiable {

}
