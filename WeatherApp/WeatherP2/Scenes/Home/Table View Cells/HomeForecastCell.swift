//
//  ForecastCell.swift
//  WeatherP2
//
//  Created by Rdm on 18/10/2020.
//

import UIKit


class HomeForecastCell: UITableViewCell {
    
    @IBOutlet weak var forecastView: ForecastView!
    
    let identifier = "cell"
    
    var forecast: DailyForecast!
    
    override func awakeFromNib() {

    }
    
    func setupView() {
        guard forecast != nil else {return}
        forecastView.forecast = forecast
        forecastView.dayLabel.text = Date.timeIntervalToFullDayOfWeek(duration: forecast.time)
        forecastView.dateLabel.text = Date.timeIntervalToFullDate(duration: forecast.time)
        forecastView.airHumidity.text = "Air humidity: \(Int(forecast.humidity * 100))%"
        forecastView.summaryLabel.text = forecast.summary
        forecastView.sunriseLabel.text = Date.timeIntervalToHourAndMinute(duration: forecast.sunriseTime)
        forecastView.sunsetLabel.text = Date.timeIntervalToHourAndMinute(duration: forecast.sunsetTime)
        forecastView.temperatureLabel.text = "\(Int(forecast.temperatureMax))°C"
        forecastView.weatherIcon.image = forecastView.setIconForString(string: forecast.icon)
    }
    
//    func shadowRadiusSetup() {
//        layer.masksToBounds = false
//        layer.shadowRadius = 1
//        layer.shadowOpacity = 0.05
//        layer.shadowOffset = CGSize(width: 1, height: 1)
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowPath = UIBezierPath(rect: self.frame).cgPath
//    }
}
