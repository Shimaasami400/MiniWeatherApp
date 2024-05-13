////
////  HourlyForecastView.swift
////  WeatherApp
////
////  Created by Shimaa on 13/05/2024.
////
//
//import SwiftUI
//
//struct HourlyForecastView: View {
//    var hourlyForecast: [HourlyForecast]
//
//    var body: some View {
//        List(hourlyForecast, id: \.time) { hour in
////            HourlyForecastRow(hour: hour)
//        }
//        .navigationTitle("Hourly Forecast")
//    }
//}
//
//struct HourlyForecastView_Previews: PreviewProvider {
//    static var previews: some View {
//        let hourlyForecast = [
//            HourlyForecast(time: "12:00 PM", icon: "sun.max.fill", temperature: 25),
//            HourlyForecast(time: "1:00 PM", icon: "cloud.sun.fill", temperature: 24),
//            HourlyForecast(time: "2:00 PM", icon: "cloud.fill", temperature: 23)
//        ]
//        return HourlyForecastView(hourlyForecast: hourlyForecast)
//    }
//}
//
