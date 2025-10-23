//
//  nextbusApp.swift
//  nextbus
//
//  Created by Sameera Sandakelum on 2025-10-23.
//

import SwiftUI
import SwiftData

@main
struct nextbusApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BusSchedule.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
