import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var currentAddress: String?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocationAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied or restricted.")
        case .notDetermined:
            requestLocationAuthorization()
        @unknown default:
            break
        }
    }


    func fetchAddress(for location: CLLocation? = nil) async -> String? {
        // Use provided location or last known location
        guard let coordinate = location ?? lastKnownLocation.map({ CLLocation(latitude: $0.latitude, longitude: $0.longitude) }) else {
            print("No location available yet.")
            return nil
        }

        // Create reverse geocoding request
        guard let request = MKReverseGeocodingRequest(location: coordinate) else {
            print("Failed to create reverse geocoding request.")
            return nil
        }

        do {
            // Get map items
            let mapItems = try await request.mapItems
            if let mapItem = mapItems.first,
               let addressRep = mapItem.addressRepresentations {

                // Use fullAddress or cityWithContext
                let address = addressRep.fullAddress(includingRegion: true, singleLine: true)

                DispatchQueue.main.async {
                    self.currentAddress = address
                }
                print("Fetched address: \(address)")
                return address
            }
        } catch {
            print("Reverse geocoding failed: \(error.localizedDescription)")
        }

        return nil
    }

}
