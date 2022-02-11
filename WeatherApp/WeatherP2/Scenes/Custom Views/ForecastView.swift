//
//  ForecastView.swift
//  WeatherP2
//
//  Created by Rdm on 18/10/2020.
//

import UIKit

@IBDesignable
class ForecastView: UIView {
    
    var forecast: DailyForecast!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var airHumidity: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .systemBlue
    }
    
    
    func setIconForString(string: String) -> UIImage {
        switch string {
        case "clear-day": return UIImage(named: "clear-day")!
        case "clear-night": return UIImage(named: "clear-night")!
        case "cloudy": return UIImage(named: "cloudy")!
        case "fog": return UIImage(named: "fog")!
        case "hail": return UIImage(named: "hail")!
        case "partly-cloudy-day": return UIImage(named: "partly-cloudy-day")!
        case "partly-cloudy-night": return UIImage(named: "partly-cloudy-night")!
        case "rain": return UIImage(named: "rain")!
        case "sleet": return UIImage(named: "sleet")!
        case "snow": return UIImage(named: "snow")!
        case "thunderstorm": return UIImage(named: "thunderstorm")!
        case "tornado": return UIImage(named: "tornado")!
        case "wind": return UIImage(named: "wind")!
        default:
            return UIImage(named: "clear-day")!
        }
    }
    
    func setDescription(string: String) -> String {
        switch string {
        case "clear-day": return "Clear day"
        case "clear-night": return "Clear night"
        case "rain":  return "Rain"
        case "snow": return "Snow"
        case "sleet": return "Sleet"
        case "wind": return "Wind"
        case "fog": return "Fog"
        case "cloudy": return "Cloudy"
        case "partly-cloudy-day": return "Partly cloudy day"
        case "partly-cloudy-night": return "Partly cloudy night"
        case "hail": return "Hail"
        case "thunderstorm": return "Thunderstorm"
        case "tornado": return "Tornado"
        default:
            return "Clear day"
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
