//
//  Network+CoreDataProperties.swift
//  iPadControls
//
//  Created by Arpi Derm on 1/30/17.
//  Copyright © 2017 WET. All rights reserved.
//

import Foundation
import CoreData


extension Network {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Network>{
        return NSFetchRequest<Network>(entityName: "Network");
    }

    @NSManaged public var spmIpAddress: String?
    @NSManaged public var serverIpAddress: String?
    @NSManaged public var server2IpAddress: String?
    @NSManaged public var mittlagplcIpAddress: String?
    @NSManaged public var mittlaplcIpAddress: String?
}
