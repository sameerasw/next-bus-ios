//
//  LocationSearchView.swift
//  nextbus
//
//  Created by Sameera Sandakelum on 2025-10-23.
//

import SwiftUI

struct LocationSearchView: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss

    // The list of available cities
    let cities = [
        "Colombo", "Rathnapura", "Badulla", "Kandy",
        "Gampaha", "Matara", "Nuwara Eliya", "Polonnaruwa",
        "Ella", "Panadura"
    ]

    // Filtered cities based on search text
    var filteredCities: [String] {
        if searchText.isEmpty {
            return cities
        } else {
            return cities.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredCities, id: \.self) { city in
                Button(action: {
                    // When a city is tapped, set the binding and dismiss
                    searchText = city
                    dismiss()
                }) {
                    Text(city)
                }
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Pick a route"
        )
    }
}

#Preview {
    LocationSearchView(searchText: .constant(""))
}
