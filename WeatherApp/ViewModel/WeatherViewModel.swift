//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Shimaa on 12/05/2024.
//

import Foundation
import Combine
import CoreLocation

class WeatherViewModel :NSObject,ObservableObject{
    @Published var weatherData : WeatherForecastResponse?{
        didSet{
            bindResultToViewController()
        }
    }
    // func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
    //func fetchWeatherData() {
    func fetchWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
//            let latitude = 37.7749
//            let longitude = -122.4194
            
            let apiKey = "9766e8969476461c875141549241205"
            
            guard let url = URL(string: "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=3") else {
                return
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(WeatherForecastResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.weatherData = decodedData
                            // Print the decoded data
                            if let weatherData = self.weatherData {
                                print(weatherData)
                            }
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
    
        
    var bindResultToViewController: (()->()) = {}
    }
