//// LocationView.swift
//// WeatherApp
////
//// Created by Shimaa on 12/05/2024.
////
//
//import SwiftUI
//import CoreLocation
//
//struct WeatherView: View {
//    @State private var location: CLLocation?
//    @State private var locationManager = CLLocationManager()
//    @ObservedObject var locationManagerDelegate = LocationManager()
//
//    var body: some View {
//        VStack {
//            Text("Current Location: \(location != nil ? "\(location!.coordinate.latitude), \(location!.coordinate.longitude)" : "Unknown")")
//                .padding()
//
//            if let location = locationManagerDelegate.location {
//                Button("Fetch Weather Data") {
//                    // Call the fetchWeatherData function passing latitude and longitude
//                    WeatherService().fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { result in
//                        switch result {
//                        case .success(let weatherData):
//                            print("Weather Data: \(weatherData)")
//                            // Handle success, update UI with weather data
//                        case .failure(let error):
//                            print("Error fetching weather data: \(error)")
//                            // Handle error, show alert or retry option
//                        }
//                    }
//                }
//                .padding()
//            } else {
//                Text("Fetching location...")
//                    .padding()
//            }
//        }
//        .onAppear {
//            requestLocation()
//        }
//    }
//
//    func requestLocation() {
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.delegate = locationManagerDelegate
//        locationManager.startUpdatingLocation()
//    }
//}
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private var locationManager = CLLocationManager()
//    @Published var location: CLLocation?
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        location = locations.last
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Location manager failed with error: \(error.localizedDescription)")
//    }
//}
//
//struct WeatherContentView: View {
//    var body: some View {
//        WeatherView()
//    }
//}
