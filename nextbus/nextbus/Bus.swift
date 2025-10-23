//
//  Bus.swift
//  nextbus
//
//  Created by Sameera Sandakelum on 2025-10-23.
//

import Foundation
import SwiftData

@Model
final class Bus {
    var type: String?
    var tier: String?
    var rating: Double?
//    var photos: [Photo]?


    init(type: String? = nil, tier: String? = nil, rating: Double? = nil) {
        self.type = type
        self.tier = tier
        self.rating = rating
    }
}
