//
//  ContentView.swift
//  WeatherApp
//
//  Created by Shimaa on 12/05/2024.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @State private var currentTime = Date()
    @StateObject var weatherViewModel = WeatherViewModel()
    @State private var locationManager = LocationManager()

    var body: some View {
        ZStack {
                BackgroundView(time: $currentTime)
                VStack {
                    if let weatherData = weatherViewModel.weatherData {
                        WeatherTopView(weatherData: weatherData)
                        WeatherMiddleView(weatherData: weatherData)
                            .padding(.top, 75)
                        WeatherBottomView(weatherData: weatherData)
                    } else {
                        ProgressView("Loading...")
                            .padding(.top, 100)
                    }
                }
                .padding()
            }
            .onAppear {
                CLLocationManager().requestWhenInUseAuthorization()
                locationManager.delegate = weatherViewModel
                locationManager.requestLocation()
                updateTime()
                
            }
            .onReceive(Timer.publish(every: 60, on: .main, in: .default).autoconnect()) { _ in
                updateTime()
            }
        }

        func updateTime() {
            currentTime = Date()
        }
    }

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    weak var delegate: WeatherViewModel?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}


struct BackgroundView: View {
    @Binding var time: Date

    var body: some View {
        let hour = Calendar.current.component(.hour, from: time)
        let isMorning = hour >= 5 && hour < 18

        return Image(isMorning ? "morning" : "evening")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(isMorning ? .black : .gray)
            .opacity(0.9)
    }
}

struct WeatherTopView: View {
    var weatherData: WeatherForecastResponse?
    
    var body: some View {
        VStack {
            Text(weatherData?.location.name ?? "Unknown")
                .font(.title)
                .foregroundColor(isMorning ? .black : .white)
            Text(String(format: "%.1f", weatherData?.current.temp_c ?? 0) + "°C")
                .font(.title)
                .foregroundColor(isMorning ? .black : .white)
            Text(weatherData?.current.condition.text ?? "Unknown")
                .font(.headline)
                .foregroundColor(isMorning ? .black : .white)
            Text("H: \(String(format: "%.1f", weatherData?.forecast.forecastday[0].day.maxtemp_c ?? 0))° - L: \(String(format: "%.1f", weatherData?.forecast.forecastday[0].day.mintemp_c ?? 0))°")
                .font(.headline)
                .foregroundColor(isMorning ? .black : Color.white.opacity(0.9))
       }
    }
    
    private var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
}

struct WeatherMiddleView: View {
    var weatherData: WeatherForecastResponse?
    @State private var hourlyForecast: [HourlyForecast] = []
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" 
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("3-DAY FORECAST").foregroundColor(isMorning ? .black : .white)
            Divider().background(isMorning ? Color.black : Color.white)
            ForecastRow(day: "Today", icon: weatherData?.forecast.forecastday[0].day.condition.icon ?? "", temperature: "\(weatherData?.forecast.forecastday[0].day.maxtemp_c ?? 0)° - \(weatherData?.forecast.forecastday[0].day.mintemp_c ?? 0)°")
            Divider().background(isMorning ? Color.black : Color.white)
            ForecastRow(day: dateFormatter.string(from: Date().addingTimeInterval(24 * 3600)),
                icon: weatherData?.forecast.forecastday[1].day.condition.icon ?? "",
                temperature: "\(weatherData?.forecast.forecastday[1].day.maxtemp_c ?? 0)° - \(weatherData?.forecast.forecastday[1].day.mintemp_c ?? 0)°")
            Divider().background(isMorning ? Color.black : Color.white) 
            ForecastRow(day: dateFormatter.string(from: Date().addingTimeInterval(48 * 3600)),
                icon: weatherData?.forecast.forecastday[2].day.condition.icon ?? "",
                temperature: "\(weatherData?.forecast.forecastday[2].day.maxtemp_c ?? 0)° - \(weatherData?.forecast.forecastday[2].day.mintemp_c ?? 0)°")
        }
    }
    
    private var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
}



struct ForecastRow: View {
    var day: String
    var icon: String
    var temperature: String

    var body: some View {
        HStack {
            Text(day)
                .frame(width: 100, alignment: .leading)
                .font(.headline)
                .foregroundColor(isMorning ? .black : .white)
            Spacer()
            Image(systemName: icon)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(isMorning ? .black : .white)
            Spacer()
            Text(temperature).font(.headline)
                .foregroundColor(isMorning ? .black : .white)
        }
    }
    
    private var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
}

struct WeatherBottomView: View {
    var weatherData: WeatherForecastResponse?

    var body: some View {
        HStack {
            Spacer()
            Text("Visibility")
                .foregroundColor(isMorning ? .black : .white)
            Spacer()
            Text("Humidity")
                .foregroundColor(isMorning ? .black : .white)
            Spacer()
        }.padding(.top, 50)
        HStack {
            Spacer()
            Text("\(String(format: "%.1f", weatherData?.current.vis_km ?? 0))km").font(.title)  .foregroundColor(isMorning ? .black : .white)
            Spacer()
            Text("\(weatherData?.current.humidity ?? 0)%").font(.title)  .foregroundColor(isMorning ? .black : .white)
            Spacer()
        }
        HStack {
            Spacer()
            Text("Feels Like") .foregroundColor(isMorning ? .black : .white)
            Spacer()
            Text("Pressure")  .foregroundColor(isMorning ? .black : .white)
            Spacer()
        }.padding(.top, 50)
        HStack {
            Spacer()
            Text("\(String(format: "%.1f", weatherData?.current.feelslike_c ?? 0))°C").font(.title)  .foregroundColor(isMorning ? .black : .white)
            Spacer()
            Text("\(String(format: "%.1f", weatherData?.current.pressure_mb ?? 0)) ").font(.title)  .foregroundColor(isMorning ? .black : .white)
            Spacer()
        }
    }
    
    private var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
