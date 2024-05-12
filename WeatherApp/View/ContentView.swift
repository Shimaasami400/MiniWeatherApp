//
//  ContentView.swift
//  WeatherApp
//
//  Created by Shimaa on 12/05/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var currentTime = Date()
    @StateObject var weatherViewModel = WeatherViewModel()

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
            weatherViewModel.fetchWeatherData()
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
            .foregroundColor(isMorning ? .black : .white)
            .opacity(0.7)
    }
}

struct WeatherTopView: View {
    var weatherData: WeatherForecastResponse?

    var body: some View {
        VStack {
            Text(weatherData?.location.name ?? "Unknown").font(.title)
            Text(String(format: "%.1f", weatherData?.current.temp_c ?? 0) + "°C").font(.title)
            Text(weatherData?.current.condition.text ?? "Unknown").font(.headline)
            Text("H: \(String(format: "%.1f", weatherData?.forecast.forecastday[0].day.maxtemp_c ?? 0))° - L: \(String(format: "%.1f", weatherData?.forecast.forecastday[0].day.mintemp_c ?? 0))°").font(.headline)
                    }
    }
}

struct WeatherMiddleView: View {
    var weatherData: WeatherForecastResponse?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THREE DAY FORECAST")
            Divider()
            ForecastRow(day: "Today", icon: weatherData?.forecast.forecastday[0].day.condition.icon ?? "", temperature: "\(weatherData?.forecast.forecastday[0].day.maxtemp_c ?? 0)° - \(weatherData?.forecast.forecastday[0].day.mintemp_c ?? 0)°")
            Divider()
            ForecastRow(day: "Tomorrow", icon: weatherData?.forecast.forecastday[1].day.condition.icon ?? "", temperature: "\(weatherData?.forecast.forecastday[1].day.maxtemp_c ?? 0)° - \(weatherData?.forecast.forecastday[1].day.mintemp_c ?? 0)°")
            Divider()
            ForecastRow(day: "Day after Tomorrow", icon: weatherData?.forecast.forecastday[2].day.condition.icon ?? "", temperature: "\(weatherData?.forecast.forecastday[2].day.maxtemp_c ?? 0)° - \(weatherData?.forecast.forecastday[2].day.mintemp_c ?? 0)°")
        }
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
            Spacer()
            Image(systemName: icon)
                .resizable()
                .frame(width: 30, height: 30)
            Spacer()
            Text(temperature).font(.headline)
        }
    }
}

struct WeatherBottomView: View {
    var weatherData: WeatherForecastResponse?

    var body: some View {
        HStack {
            Spacer()
            Text("Visibility")
            Spacer()
            Text("Humidity")
            Spacer()
        }.padding(.top, 50)
        HStack {
            Spacer()
            Text("\(String(format: "%.1f", weatherData?.current.vis_km ?? 0))km").font(.title)
            Spacer()
            Text("\(weatherData?.current.humidity ?? 0)%").font(.title)
            Spacer()
        }
        HStack {
            Spacer()
            Text("Feels Like")
            Spacer()
            Text("Pressure")
            Spacer()
        }.padding(.top, 50)
        HStack {
            Spacer()
            Text("\(String(format: "%.1f", weatherData?.current.feelslike_c ?? 0))°C").font(.title)
            Spacer()
            Text("\(String(format: "%.1f", weatherData?.current.pressure_mb ?? 0)) ").font(.title)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
