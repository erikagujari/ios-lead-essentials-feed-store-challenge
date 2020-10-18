//
//  CoreDataFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Erik Agujari on 03/10/2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//
import Foundation

public class CoreDataFeedImage: NSObject, NSCoding {
    public let id: String?
    public let imageDescription: String?
    public let location: String?
    public let url: String?
    
    public init(id: String?, imageDescription: String?, location: String?, url: String?) {
        self.id = id
        self.imageDescription = imageDescription
        self.location = location
        self.url = url
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: EncodingKeys.id)
        coder.encode(imageDescription, forKey: EncodingKeys.description)
        coder.encode(location, forKey: EncodingKeys.location)
        coder.encode(url, forKey: EncodingKeys.url)
    }
    
    public required init?(coder: NSCoder) {
        let id = coder.decodeObject(forKey: EncodingKeys.id) as? String
        let imageDescription = coder.decodeObject(forKey: EncodingKeys.description) as? String
        let location = coder.decodeObject(forKey: EncodingKeys.location) as? String
        let url = coder.decodeObject(forKey: EncodingKeys.url) as? String
        
        self.id = id
        self.imageDescription = imageDescription
        self.location = location
        self.url = url
    }
    
    private enum EncodingKeys {
        static let id = "id"
        static let description = "description"
        static let location = "location"
        static let url = "url"
    }
}
