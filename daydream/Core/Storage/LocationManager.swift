import CoreLocation

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    var currentLocation: CLLocation?
    var locationName: String?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() async -> CLLocation? {
        let status = manager.authorizationStatus

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
            // Wait for the authorization callback before proceeding
            let granted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
                self.authContinuation = cont
            }
            guard granted else { return nil }
        } else {
            guard status == .authorizedWhenInUse || status == .authorizedAlways else {
                return nil
            }
        }

        return await withCheckedContinuation { continuation in
            // Resume any previously leaked continuation to avoid misuse warning
            self.continuation?.resume(returning: nil)
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    @available(iOS, deprecated: 26.0, message: "Use MKReverseGeocodingRequest when targeting iOS 26+")
    func reverseGeocode(location: CLLocation) async -> String? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                return [placemark.locality, placemark.subLocality]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
        } catch {
            print("Geocoding error: \(error)")
        }
        return nil
    }

    // MARK: - Authorization continuation

    private var authContinuation: CheckedContinuation<Bool, Never>?

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        MainActor.assumeIsolated {
            self.authorizationStatus = manager.authorizationStatus
            if let authCont = self.authContinuation {
                let granted = manager.authorizationStatus == .authorizedWhenInUse
                    || manager.authorizationStatus == .authorizedAlways
                authCont.resume(returning: granted)
                self.authContinuation = nil
            }
        }
    }

    // MARK: - Location delegates

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        MainActor.assumeIsolated {
            let location = locations.last
            self.currentLocation = location
            self.continuation?.resume(returning: location)
            self.continuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        MainActor.assumeIsolated {
            print("Location error: \(error)")
            self.continuation?.resume(returning: nil)
            self.continuation = nil
        }
    }
}
