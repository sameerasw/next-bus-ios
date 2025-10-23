//
//  newScheduleView.swift
//  nextbus
//
//  Created by Sameera Sandakelum on 2025-10-23.
//

import SwiftUI
import MapKit
import CoreLocation

struct newScheduleView: View {
    @State private var date = Date()
    @State private var pickup: String = ""
    @State private var route: String = ""
    @State private var type: String = "sltb"
    @State private var tier: String = "x1"
    @State private var seating: String = "Available"
    @State private var fromLocation: String = ""
    @State private var plate: String = ""
    @StateObject var locationManager = LocationManager()
    @State private var locationSheetOpen: Bool = false

    let pickups = ["Colombo", "Kandy", "Galle", "Jaffna", "Anuradhapura", "Negombo", "Batticaloa"]

    var body: some View {
        NavigationStack{
            ScrollView(){
                VStack(spacing: 25){

                    //            VStack {
                    //                if let location = locationManager.lastKnownLocation {
                    //                    Text("Latitude: \(location.latitude)")
                    //                    Text("Longitude: \(location.longitude)")
                    //                } else {
                    //                    Text("Getting location...")
                    //                }
                    //
                    //                Button("Request Location") {
                    //                    locationManager.requestLocationAuthorization()
                    //                }
                    //            }
                    //            .onAppear {
                    //                locationManager.requestLocationAuthorization()
                    //            }

                    DatePicker(
                        "Time",
                        selection: $date,
                        displayedComponents: [.hourAndMinute]
                    )
                    .padding(.horizontal, 16)

                    GroupBox(label:
                                Label("From", systemImage: "location")
                    ){
                        ZStack(alignment: .bottomTrailing){

                            Map {
                                if let location = locationManager.lastKnownLocation {
                                    Marker("Your Location", coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                                        .tint(.blue)
                                }
                            }
                            .mapControlVisibility(.hidden)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 5)

                            Button("Refresh", systemImage: "repeat"){
                                locationManager.requestLocationAuthorization()
                            }
                            .zIndex(1)
                            .buttonStyle(.glass)
                            .labelStyle(.iconOnly)
                            .controlSize(.large)
                            .padding(6)
                        }
                    }
                    .onTapGesture {
                        locationSheetOpen = true
                    }

                    Image(systemName: "arrow.down")

                    GroupBox(label:
                                Label("To", systemImage: "mappin.and.ellipse")
                    ){
                        VStack(alignment: .leading){
                            Text("Route")
                            TextField("138", text: $route)
                                .textFieldStyle(.roundedBorder)
                                .controlSize(.large)
                        }
                    }
                    .onTapGesture {
                        locationSheetOpen = true
                    }

                    VStack(alignment: .leading){
                        Text("Service")
                        Picker("Bus Provider", selection: $type){
                            Text("SLTB").tag("sltb")
                            Text("Private").tag("private")
                        }
                        .pickerStyle(.palette)
                        .controlSize(.large)
                    }

                    VStack(alignment: .leading){
                        Text("Class/ Pricing \(tier)")
                        Picker("Bus Class", selection: $tier){
                            Text("Normal").tag("x1")
                            Text("Semi-Luxury").tag("x1.5")
                            Text("Luxury").tag("x2")
                            Text("Express").tag("x4")
                        }
                        .pickerStyle(.palette)
                        .controlSize(.large)
                    }

                    VStack(alignment: .leading){
                        Text("Seating \(seating)")
                        Picker("Seating", selection: $seating){
                            Label("Available", systemImage: "person")
                                .tag("Available")
                                .labelStyle(.iconOnly)
                            Label("Almost full", systemImage: "person.2")
                                .tag("Almost full")
                                .labelStyle(.iconOnly)
                            Label("Full", systemImage: "person.3")
                                .tag("Full")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.yellow)
                            Label("Loaded", systemImage: "person.3.fill")
                                .tag("Loaded")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.red)
                        }
                        .pickerStyle(.palette)
                        .controlSize(.large)
                    }

                    VStack(alignment: .leading){
                        Text("License Plate")
                        TextField("NA-6969", text: $plate)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.large)
                    }

                }
                .padding()
            }
            .toolbar{
                ToolbarItem(placement: .destructiveAction){

                    Button("Cancel", systemImage: "xmark"){

                    }
                    .labelStyle(.iconOnly)
                }

                ToolbarItem(placement: .confirmationAction){
                    Button("Create", systemImage: "checkmark"){

                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.glassProminent)
                }
            }
        }
        .sheet(isPresented: $locationSheetOpen){
            LocationSearchView(searchText: $fromLocation)
                .presentationDragIndicator(.visible)
            //                    .presentationBackground(.ultraThinMaterial)
                .presentationDetents([.medium,.large])
                .presentationContentInteraction(.resizes)
        }
    }
}

#Preview {
    newScheduleView()
}
