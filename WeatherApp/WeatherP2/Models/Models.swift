//
//  ForecastModel.swift
//  WeatherP2
//
//  Created by Rdm on 18/10/2020.
//

import MapKit
import UIKit

struct Place: Decodable {
    
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var title: String
    
}

struct Weather: Decodable {
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var timezone: String?
    var daily: Daily?
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, timezone, daily
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(CLLocationDegrees.self, forKey: CodingKeys.latitude)
        longitude = try container.decode(CLLocationDegrees.self, forKey: CodingKeys.longitude)
        timezone = try container.decode(String.self, forKey: CodingKeys.timezone)
        daily = try container.decode(Daily.self, forKey: CodingKeys.daily)
    }
}

struct Daily: Decodable {

    var summary: String
    var icon: String
    var data: [DailyForecast]
    
    enum CodingKeys: String, CodingKey {
        case summary, icon, data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        summary = try container.decode(String.self, forKey: CodingKeys.summary)
        icon = try container.decode(String.self, forKey: CodingKeys.icon)
        data = try container.decode([DailyForecast].self, forKey: CodingKeys.data)
    }
}

struct DailyForecast: Decodable {
    
    var time: Double
    var icon: String
    var temperatureMax: Double
    var summary: String
    var sunriseTime: Double
    var sunsetTime: Double
    var humidity: Double
    
    enum CodingKeys: String, CodingKey {
        case time, icon, temperatureMax, summary, sunriseTime, sunsetTime, humidity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        time = try container.decode(Double.self, forKey: CodingKeys.time)
        icon = try container.decode(String.self, forKey: CodingKeys.icon)
        temperatureMax = try container.decode(Double.self, forKey: CodingKeys.temperatureMax)
        summary = try container.decode(String.self, forKey: CodingKeys.summary)
        sunriseTime = try container.decode(Double.self, forKey: CodingKeys.sunriseTime)
        sunsetTime = try container.decode(Double.self, forKey: CodingKeys.sunsetTime)
        humidity = try container.decode(Double.self, forKey: CodingKeys.humidity)
    }
}

