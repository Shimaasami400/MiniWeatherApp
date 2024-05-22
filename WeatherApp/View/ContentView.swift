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
        NavigationView {
            ZStack {
                BackgroundView(time: $currentTime)
                
                VStack(spacing: 40) {
                    if let weatherData = weatherViewModel.weatherData {
                        FirstSectionView(weatherData: weatherData)
                            .padding(.top, 50)
                        SecondSectionView(weatherData: weatherData)
                        LasttSectionView(weatherForecastResponse: weatherData)
                            .padding(.bottom, 90)
                    } else {
                        ProgressView("Loading...")
                            .padding(.top, 20)
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
        print("Error in location manager: \(error.localizedDescription)")
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

struct FirstSectionView: View {
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
            
            if let iconURL = weatherData?.current.condition.icon {
                let imageName = iconURL.components(separatedBy: "/").last?.replacingOccurrences(of: ".png", with: "")
                if let imageName = imageName {
                    
                    let imageNameToUse = isMorning ? "\(imageName)" : "\(imageName)"
                    
                    if let image = UIImage(named: imageNameToUse) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    } 
                    else {
                        Image(systemName: "questionmark.square")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    }
                }
                }
            
            
        }
    }
    
    private var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
}



struct SecondSectionView: View {
    var weatherData: WeatherForecastResponse?
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("3-DAY FORECAST")
                .foregroundColor(isMorning ? .black : .white)
                .font(.headline)
            Divider().background(isMorning ? Color.black : Color.white)
            
            List {
                Section {
                    ForEach(0..<3, id: \.self) { index in
                        NavigationLink(destination: HourlyForecastView(hourlyForecast: weatherData?.forecast.forecastday[index].hour ?? [])) {
                            ForecastRow(day: self.forecastDay(for: index),
                                        icon: self.forecastIcon(for: index),
                                        temperature: self.forecastTemperature(for: index))
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .listRowSeparatorTint(.white)
        }
        .padding(.horizontal)
    }
    
    private var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
    
    private func forecastDay(for index: Int) -> String {
        switch index {
        case 0: return "Today"
        case 1: return dateFormatter.string(from: Date().addingTimeInterval(24 * 3600))
        case 2: return dateFormatter.string(from: Date().addingTimeInterval(48 * 3600))
        default: return ""
        }
    }
    
    private func forecastIcon(for index: Int) -> String {
        if let iconURL = weatherData?.forecast.forecastday[index].day.condition.icon {
            let iconName = iconURL.components(separatedBy: "/").last?.replacingOccurrences(of: ".png", with: "")
            let imageNameToUse = isMorning ? "\(iconName ?? "")" : "\(iconName ?? "")"
            return imageNameToUse
        }
        return "bee"
    }

    
    private func forecastTemperature(for index: Int) -> String {
        let maxTemp = { () -> Double in
            switch index {
            case 0: return weatherData?.forecast.forecastday[0].day.maxtemp_c ?? 0
            case 1: return weatherData?.forecast.forecastday[1].day.maxtemp_c ?? 0
            case 2: return weatherData?.forecast.forecastday[2].day.maxtemp_c ?? 0
            default: return 0
            }
        }()
        let minTemp = { () -> Double in
            switch index {
            case 0: return weatherData?.forecast.forecastday[0].day.mintemp_c ?? 0
            case 1: return weatherData?.forecast.forecastday[1].day.mintemp_c ?? 0
            case 2: return weatherData?.forecast.forecastday[2].day.mintemp_c ?? 0
            default: return 0
            }
        }()
        return "\(maxTemp)° - \(minTemp)°"
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
            Image(icon)
                .resizable()
                .frame(width: 30, height: 30)
                .onAppear {
                    print("Loading image with name: \(icon)")
                }
            Spacer()
            Text(temperature)
                .font(.headline)
                .foregroundColor(isMorning ? .black : .white)
        }
    }
    
    private var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }
}


struct LasttSectionView: View {
    var weatherForecastResponse: WeatherForecastResponse?
    
    var body: some View {
        VStack(spacing: 50) {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Text("Visibility")
                        .foregroundColor(isMorning ? .black : .white)
                    Spacer()
                    Text("Humidity")
                        .foregroundColor(isMorning ? .black : .white)
                    Spacer()
                }.padding(.bottom, 5)
                
                HStack {
                    Spacer()
                    Text("\(String(format: "%.1f", weatherForecastResponse?.current.vis_km ?? 0))km").font(.title).foregroundColor(isMorning ? .black : .white)
                    Spacer()
                    Text("\(weatherForecastResponse?.current.humidity ?? 0)%").font(.title).foregroundColor(isMorning ? .black : .white)
                    Spacer()
                }
            }
            
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Text("Feels Like").foregroundColor(isMorning ? .black : .white)
                    Spacer()
                    Text("Pressure").foregroundColor(isMorning ? .black : .white)
                    Spacer()
                }.padding(.bottom, 5)
                
                HStack {
                    Spacer()
                    Text("\(String(format: "%.1f", weatherForecastResponse?.current.feelslike_c ?? 0))°C").font(.title).foregroundColor(isMorning ? .black : .white)
                    Spacer()
                    Text("\(String(format: "%.1f", weatherForecastResponse?.current.pressure_mb ?? 0))").font(.title).foregroundColor(isMorning ? .black : .white)
                    Spacer()
                }
            }
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
