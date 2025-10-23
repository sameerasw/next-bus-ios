//
//  newScheduleView.swift
//  nextbus
//
//  Created by Sameera Sandakelum on 2025-10-23.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct NewScheduleView: View {
    @State private var date = Date()
    @State private var pickup: String = ""
    @State private var type: String = "sltb"
    @State private var tier: String = "x1"
    @State private var seating: String = "Available"
    @State private var pickedRoute: String = ""
    @State private var plate: String = ""
    @State private var rating: Double?
    @StateObject var locationManager = LocationManager()
    @State private var locationSheetOpen: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let pickups = ["Colombo", "Kandy", "Galle", "Jaffna", "Anuradhapura", "Negombo", "Batticaloa"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {

                    DatePicker(
                        "Time",
                        selection: $date,
                        displayedComponents: [.hourAndMinute]
                    )
                    .padding(.horizontal, 16)

                    GroupBox(label:
                                HStack{
                        Label("From", systemImage: "location")
                        Spacer()
                    }
                    ) {
                        VStack(alignment: .leading) {
                            if let address = locationManager.currentAddress {
                                Text(address)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("Locating...")
                                    .foregroundColor(.gray)
                                    .onAppear {
                                        Task {
                                            while locationManager.lastKnownLocation == nil {
                                                try? await Task.sleep(nanoseconds: 500_000_000)
                                            }
                                            await locationManager.fetchAddress()
                                        }
                                    }
                            }
                        }
                        .padding(.top, 8)
                        ZStack(alignment: .bottomTrailing) {
                            Map {
                                if let location = locationManager.lastKnownLocation {
                                    Marker("Your Location", coordinate: location)
                                        .tint(.blue)
                                }
                            }
                            .mapControlVisibility(.hidden)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 5)

                            Button(action: {
                                Task {
                                    locationManager.requestLocationAuthorization()
                                    await locationManager.fetchAddress()
                                }
                            }) {
                                Image(systemName: "repeat")
                            }
                            .buttonStyle(.glass)
                            .padding(6)
                        }

                    }

                    Image(systemName: "arrow.down")

                    GroupBox(label: Label("Route", systemImage: "mappin.and.ellipse")) {
                        HStack {
                            if (!pickedRoute.isEmpty){
                                Text(pickedRoute)
                            } else {
                                Text("No route selected")
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .onTapGesture {
                        locationSheetOpen = true
                    }

                    if (!pickedRoute.isEmpty){
                        // Service Picker
                        VStack(alignment: .leading) {
                            Text("Service")
                            Picker("Bus Provider", selection: $type) {
                                Text("SLTB").tag("sltb")
                                Text("Private").tag("private")
                            }
                            .pickerStyle(.palette)
                            .controlSize(.large)
                        }

                        // Class/Price Picker
                        VStack(alignment: .leading) {
                            Text("Class/ Pricing \(tier)")
                            Picker("Bus Class", selection: $tier) {
                                Text("Normal").tag("x1")
                                Text("Semi-Luxury").tag("x1.5")
                                Text("Luxury").tag("x2")
                                Text("Express").tag("x4")
                            }
                            .pickerStyle(.palette)
                            .controlSize(.large)
                        }

                        // Seating Picker
                        VStack(alignment: .leading) {
                            Text("Seating \(seating)")
                            Picker("Seating", selection: $seating) {
                                Label("Available", systemImage: "person").tag("Available").labelStyle(.iconOnly)
                                Label("Almost full", systemImage: "person.2").tag("Almost full").labelStyle(.iconOnly)
                                Label("Full", systemImage: "person.3").tag("Full").labelStyle(.iconOnly).foregroundStyle(.yellow)
                                Label("Loaded", systemImage: "person.3.fill").tag("Loaded").labelStyle(.iconOnly).foregroundStyle(.red)
                            }
                            .pickerStyle(.palette)
                            .controlSize(.large)
                        }

                        // License Plate
                        VStack(alignment: .leading) {
                            Text("License Plate")
                            TextField("NA-6969", text: $plate)
                                .textFieldStyle(.roundedBorder)
                                .controlSize(.large)
                        }
                    }

                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Cancel",systemImage: "xmark" ) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create",systemImage: "checkmark" ) {
                        // Minimal validation: require a route
                        guard !pickedRoute.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                            // You could show an alert/toast here
                            return
                        }

                        // Build related model(s)
                        let bus = Bus(type: type, tier: tier, rating: rating)
                        // Optional: plate could be stored on Bus or BusSchedule if you add a property later

                        // Determine place: use explicit pickup if set, otherwise current address
                        let resolvedPlace = pickup.isEmpty ? (locationManager.currentAddress ?? "") : pickup

                        // Create schedule
                        let newSchedule = BusSchedule(
                            timestamp: date,
                            route: pickedRoute,
                            place: resolvedPlace,
                            bus: bus
                        )
                        // Optional fields
                        newSchedule.seating = seating

                        if let coord = locationManager.lastKnownLocation {
                            newSchedule.location = [
                                "lat": String(coord.latitude),
                                "lng": String(coord.longitude),
                                "address": locationManager.currentAddress ?? ""
                            ]
                        }

                        // Persist to SwiftData
                        modelContext.insert(newSchedule)

                        // Dismiss sheet
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                locationManager.requestLocationAuthorization()
                locationManager.startUpdatingLocation()
            }
        }
        .sheet(isPresented: $locationSheetOpen) {
            LocationSearchView(searchText: $pickedRoute)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.resizes)
        }
    }
}

#Preview {
    NewScheduleView()
}

