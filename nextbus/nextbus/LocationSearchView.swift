//
//  LocationSearchView.swift
//  nextbus
//
//  Created by Sameera Sandakelum on 2025-10-23.
//

import SwiftUI

struct LocationSearchView: View {
    @Binding var searchText: String

    var body: some View {
        NavigationStack {
            ScrollView{
                List {
                    Text("Colombo")
                    Text("Rathnapura")
                    Text("Badulla")
                    Text("Kandy")
                    Text("Gampaha")
                    Text("Matara")
                    Text("Nuwara Eliya")
                    Text("Polonnaruwa")
                    Text("Ella")
                    Text("Panadura")
                }
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    LocationSearchView(searchText: .constant("Search"))
}
