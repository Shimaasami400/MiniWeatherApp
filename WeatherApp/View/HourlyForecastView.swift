//
//  HourlyForecastView.swift
//  WeatherApp
//
//  Created by Shimaa on 13/05/2024.
//

import SwiftUI

struct HourlyForecastView: View {
    var hourlyForecast: [HourlyForecast]

    var body: some View {
        ZStack {
            Image(backgroundImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Text("Hourly Forecast")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 50)

                List {
                    Section {
                        ForEach(hourlyForecast, id: \.time) { hour in
                            VStack {
                                HourlyForecastCell(hour: hour)
                            }
                            .listRowBackground(Color.clear.opacity(0.5)) 
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
        }
    }
    
    private var backgroundImage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return (hour >= 6 && hour < 18) ? "morning" : "evening"
    }
}

struct HourlyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        let hourlyForecast = [
            HourlyForecast(time: "12:00 PM", temp_c: Double(Int(20.0)), condition: WeatherCondition(text: "Clear", icon: "", code: 1000)),
            HourlyForecast(time: "1:00 PM", temp_c: Double(Int(20.0)), condition: WeatherCondition(text: "Clear", icon: "", code: 1000))
        ]
        return HourlyForecastView(hourlyForecast: hourlyForecast)
    }
}


