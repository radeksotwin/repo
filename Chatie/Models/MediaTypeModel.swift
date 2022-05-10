//
//  MediaTypeModel.swift
//  Chatie
//
//  Created by Rdm on 07/05/2022.
//

import Foundation
import MapKit
import MessageKit

struct Media: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    
    var location: CLLocation
    var size: CGSize
}
