//
//  Item.swift
//  nextbus
//
//  Created by Sameera Sandakelum on 2025-10-23.
//

import Foundation
import SwiftData

@Model
final class BusSchedule {
    var timestamp: Date
    var route: String
    var location: [String: String]?
    var place: String
    var bus: Bus
    var seating: String?
    //    var comments: [Comment]?

    init(timestamp: Date, route: String, place: String, bus: Bus) {
        self.timestamp = timestamp
        self.route = route
        self.place = place
        self.bus = bus
    }
}
