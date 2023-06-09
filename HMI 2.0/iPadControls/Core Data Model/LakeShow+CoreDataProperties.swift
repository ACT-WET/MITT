//
//  LakeShow+CoreDataProperties.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/5/23.
//  Copyright © 2023 WET. All rights reserved.
//
//

import Foundation
import CoreData


extension LakeShow {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LakeShow> {
        return NSFetchRequest<LakeShow>(entityName: "LakeShow")
    }

    @NSManaged public var duration: Int32
    @NSManaged public var name: String?
    @NSManaged public var number: Int16

}
