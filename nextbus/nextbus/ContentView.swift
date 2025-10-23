//
//  ContentView.swift
//  nextbus
//
//  Created by Sameera Sandakelum on 2025-10-23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var schedule: [BusSchedule]
    @State private var newSheetOpen: Bool = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(schedule) { item in
                    NavigationLink {
                        BusScheduleDetailView(schedule: item)
                    } label: {
                        HStack {
                            Image(systemName: "bus.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.tint)
                                .imageScale(.large)
                                .frame(width: 30)
                            VStack(alignment: .leading) {
                                Text(item.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(item.route)
                                    .font(.headline)
                                if let shortCity = shortCityDisplay(for: item), !shortCity.isEmpty {
                                    Label(shortCity, systemImage: "mappin.and.ellipse")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if let seating = item.seating, !seating.isEmpty {
                                Label(seating, systemImage: seatingIcon(for: seating))
                                    .labelStyle(.iconOnly)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Next Bus")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: openSheet) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $newSheetOpen){
                NewScheduleView()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
                    .presentationContentInteraction(.resizes)
            }
        } detail: {
            ContentPlaceholderView()
        }
    }

    private func shortCityDisplay(for schedule: BusSchedule) -> String? {
        if let address = schedule.location?["address"], let city = cityName(from: address), !city.isEmpty {
            return city
        }
        return schedule.place.isEmpty ? nil : schedule.place
    }

    private func cityName(from address: String) -> String? {
        // Split by commas
        let parts = address
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !parts.isEmpty else { return nil }

        if parts.count >= 3 {
            // Avoid country/region words commonly at the end
            let middleIndex = parts.count / 2
            return parts[middleIndex]
        } else if parts.count == 2 {
            return parts[0]
        } else {
            return parts[0]
        }
    }

    private func openSheet() {
        newSheetOpen = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(schedule[index])
            }
        }
    }

    private func seatingIcon(for seating: String) -> String {
        switch seating.lowercased() {
        case "available": return "person"
        case "almost full": return "person.2"
        case "full": return "person.3"
        case "loaded": return "person.3.fill"
        default: return "person"
        }
    }
}

private struct ContentPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bus")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Select a schedule")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BusSchedule.self, inMemory: true)
}
