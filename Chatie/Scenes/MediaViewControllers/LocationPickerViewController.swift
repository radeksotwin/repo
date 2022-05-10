//
//  LocationPickerViewController.swift
//  Chatie
//
//  Created by Rdm on 23/04/2022.
//


import UIKit
import CoreLocation
import MapKit

/// While showing PickerVC via chosen location, make map more contextual (Zoom in, set region)

class LocationPickerController: UIViewController {

    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private var isPickable = true
    private let map: MKMapView = {
       let map = MKMapView()
        return map
    }()
    
    init(coordinates: CLLocationCoordinate2D?, isPickable: Bool) {
        self.coordinates = coordinates
        self.isPickable = isPickable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        
        if isPickable {
            title = "Pick Location"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonTapped))
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            map.addGestureRecognizer(gesture)
            map.isUserInteractionEnabled = true
            
            
        } else {
            title = "Location"
            guard let coordinates = coordinates else {
                return
            }

            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
        
    }
    
    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }

        completion?(coordinates)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        
        self.coordinates = coordinates
        
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = view.bounds
    }


}
