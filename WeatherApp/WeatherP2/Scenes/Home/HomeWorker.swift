//
//  Worker.swift
//  WeatherP2
//
//  Created by Rdm on 18/10/2020.
//

import CoreLocation
import UIKit

class Worker {
    
    var baseUrl: String = "https://api.darksky.net/forecast/f51efb500212a162226a726e327176e4/"
    var weather: Weather!
    var locationsArray: [Place] = []
    var pickedLocation: Place = Place(latitude: 50.058717899999998, longitude: 19.9371674, title: "Kraków")
 
    
    func pickLocation(request: FetchData.Request) {
       pickedLocation = locationsArray[0]
        let response = FetchData.Response.FetchPickedLocation(locationName: pickedLocation.title)
//        homeVC.displayForecastForPickedLocation(viewModel: response.locationName)
        
    }
    
 
}
