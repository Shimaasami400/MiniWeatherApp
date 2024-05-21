//
//  HourlyForecastRow.swift
//  WeatherApp
//
//  Created by Shimaa on 13/05/2024.
//

import SwiftUI

struct HourlyForecastCell: View {
    var hour: HourlyForecast
    
    var body: some View {
            HStack {
                Text(hour.time.components(separatedBy: " ").last ?? "") 
                    .frame(width: 100, alignment: .leading)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: hour.condition.icon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                Spacer()
                Text(String(format: "%.1f", hour.temp_c) + "°C")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
struct HourlyForecastCell_Previews: PreviewProvider {
    static var previews: some View {
        let sampleHourlyForecast = HourlyForecast(time: "12:00 PM", temp_c: 20.0, condition: WeatherCondition(text: "Clear", icon: "sun.max.fill", code: 1000))
        return HourlyForecastCell(hour: sampleHourlyForecast)
            .previewLayout(.fixed(width: UIScreen.main.bounds.width, height: 60))
    }
}
