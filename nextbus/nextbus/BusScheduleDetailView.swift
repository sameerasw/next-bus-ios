import SwiftUI
import MapKit

struct BusScheduleDetailView: View {
    let schedule: BusSchedule

    private var address: String? {
        schedule.location?["address"]
    }
    private var latitude: Double? {
        if let latStr = schedule.location?["lat"], let d = Double(latStr) { return d }
        return nil
    }
    private var longitude: Double? {
        if let lngStr = schedule.location?["lng"], let d = Double(lngStr) { return d }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                whenWhereSection
                if hasCoordinate {
                    mapSection
                }
                busDetailsSection
            }
            .padding()
        }
        .navigationTitle(schedule.route)
        .navigationBarTitleDisplayMode(.inline)
        .background(.background)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: "bus.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tint)
                    .font(.system(size: 44, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                    Text(schedule.timestamp, style: .time)
                }
                .foregroundStyle(.secondary)
                if !schedule.place.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(schedule.place)
                    }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                }
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private var whenWhereSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent {
                    Text(schedule.timestamp, format: .dateTime.hour().minute())
                } label: {
                    Label("Departure", systemImage: "clock")
                }

                if !schedule.place.isEmpty {
                    LabeledContent {
                        Text(schedule.place)
                    } label: {
                        Label("From", systemImage: "mappin.and.ellipse")
                    }
                }

                if let addr = address, !addr.isEmpty {
                    LabeledContent {
                        Text(addr)
                            .multilineTextAlignment(.leading)
                    } label: {
                        Label("Address", systemImage: "map")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("When & Where", systemImage: "calendar.badge.clock")
        }
    }

    private var hasCoordinate: Bool {
        latitude != nil && longitude != nil
    }

    private var mapSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                if let lat = latitude, let lng = longitude {
                    Map(initialPosition: .region(.init(center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                                                       span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)))) {
                        Annotation("Pickup", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)) {
                            ZStack {
                                Circle().fill(Color.blue.opacity(0.2))
                                    .frame(width: 28, height: 28)
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Map", systemImage: "map.fill")
        }
    }

    private var busDetailsSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if let type = schedule.bus.type, !type.isEmpty {
                    LabeledContent {
                        Text(type.uppercased())
                    } label: {
                        Label("Provider", systemImage: providerIcon(for: type))
                    }
                }
                if let tier = schedule.bus.tier, !tier.isEmpty {
                    LabeledContent {
                        Text(displayTier(tier))
                    } label: {
                        Label("Class", systemImage: "ticket")
                    }
                }
                if let seating = schedule.seating, !seating.isEmpty {
                    LabeledContent {
                        Text(seating)
                    } label: {
                        Label("Seating", systemImage: seatingIcon(for: seating))
                    }
                }
                if let rating = schedule.bus.rating {
                    LabeledContent {
                        Text(String(format: "%.1f", rating))
                    } label: {
                        Label("Rating", systemImage: "star.fill")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Bus Details", systemImage: "bus")
        }
    }

    private func providerIcon(for type: String) -> String {
        switch type.lowercased() {
        case "sltb": return "building.columns"
        case "private": return "person.2"
        default: return "bus"
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

    private func displayTier(_ tier: String) -> String {
        switch tier.lowercased() {
        case "x1": return "Normal"
        case "x1.5": return "Semi‑Luxury"
        case "x2": return "Luxury"
        case "x4": return "Express"
        default: return tier
        }
    }
}

#Preview {
    let bus = Bus(type: "sltb", tier: "x2", rating: 4.5)
    let schedule = BusSchedule(timestamp: Date(), route: "Colombo → Kandy", place: "Colombo Fort", bus: bus)
    schedule.seating = "Available"
    schedule.location = ["lat": "6.9355", "lng": "79.8428", "address": "Colombo Fort, Sri Lanka"]
    return NavigationStack { BusScheduleDetailView(schedule: schedule) }
}
