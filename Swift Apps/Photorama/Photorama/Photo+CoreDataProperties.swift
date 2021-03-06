//
//  Photo+CoreDataProperties.swift
//  Photorama
//
//  Created by Doolittle, Jonathan J on 3/2/22.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photoID: String?
    @NSManaged public var remoteURL: URL?
    @NSManaged public var dateTaken: Date?
    @NSManaged public var title: String?

}

extension Photo : Identifiable {

}
