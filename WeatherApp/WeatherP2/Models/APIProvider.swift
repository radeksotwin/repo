//
//  APIProvider.swift
//  WeatherP2
//
//  Created by Rdm on 21/10/2020.
//

import Foundation

enum APIProviderResult {
    case success(data: Data)
    case failure(error: String)
    
}


class APIRequest {

    var baseUrl = "https://api.darksky.net/forecast/f51efb500212a162226a726e327176e4/"
//    var pickedLocation: Place = Place(latitude: 50.058717899999998, longitude: 19.9371674, title: "Kraków")
    var weather: Weather!

    
}
