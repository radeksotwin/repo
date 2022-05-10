//
//  ViewController.swift
//  WeatherP2
//
//  Created by Rdm on 15/10/2020.
//

import UIKit
import MapKit

class HomeViewController: UIViewController {
   
    var weather: Weather?
    var pickedLocation: Place = Place(latitude: 52.5, longitude: 21.0, title: "Warsaw")
    var placesArray: [Place] = []
    var autoCompletionPossibilities: [String] = []
    var isExpanded: Bool = false
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    
    private let cellIdentifier = "weatherCell"
    private let baseUrl: String = "https://api.darksky.net/forecast/f51efb500212a162226a726e327176e4/"
   
    @IBOutlet weak var navigationView: NavigationView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupDelegateAndDataSource()
        setObservers()
        handleNavigationViewCallBacks()
        fetchForecastForPickedLocation()
        
        setBackagroundImage(string: "seaBgView")
    }

    
    func handleNavigationViewCallBacks() {
        guard let nv = navigationView else { return }
        nv.textFieldText = { [weak self] (text) in
            guard let me = self else { return }
            me.updateSearchResults(locationName: text)
        }
          
        guard let sv = nv.searchView else { return }
        sv.pickedLocationCallBack = { [weak self] in
            guard let me = self else { return }
            me.updatePickedLocationAndFetchForecast()
            sv.results.removeAll()
            nv.textField.resignFirstResponder()
        }
    }
    
    func updateSearchResults(locationName: String) {
        updateLocationsForString(location: locationName) { [weak self] (places) in
            guard let me = self else { return }
            guard let sv = me.navigationView.searchView else { return }
            me.placesArray.removeAll()
            me.placesArray = places
            me.autoCompletionPossibilities.append(me.placesArray[0].title)
            sv.results = me.placesArray
            sv.searchTableView.reloadData()
        }
    }
    
    func updatePickedLocationAndFetchForecast() {
        pickedLocation = placesArray[0]
        navigationView.setTitle(text: pickedLocation.title)
        navigationView.textField.text = ""
        fetchForecastForPickedLocation()
    }
    
    func displayFetchedWeatherForcast(weather: Weather) {
        self.weather = weather
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func fetchForecastForPickedLocation() {
        weather = nil
        activityIndicator.startAnimating()
        tableView.reloadData()
        fetchForecast(place: pickedLocation) { [weak self] (weather) in
            guard let me = self else { return }
            me.displayFetchedWeatherForcast(weather: weather)
        }
    }
    
    func updateLocationsForString(location: String, completion: @escaping([Place]) -> Void) {
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
            if error == nil {
                guard let marks = placemarks else { return }
                var places = [Place]()
                for location in marks {
                    guard let cords = location.location?.coordinate else { return }
                    guard let title = location.name else { return }
                    let place = Place(latitude: cords.latitude, longitude: cords.longitude, title: title)
                    places.append(place)
                }
                completion(places)
            }
        }
    }
    
    func fetchForecast(place: Place, completion: @escaping (Weather) -> Void) {
        
        let urlString = baseUrl + "\(place.latitude),\(place.longitude)" + "?units=si"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                print("Data decoding error")
            }
            guard let data = data else { return }
            let me = self
            let decoder = JSONDecoder()
            do {
                me.weather = try decoder.decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    completion(me.weather!)
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    func didExpandeCell() {
        self.isExpanded = !isExpanded
        tableView.reloadRows(at: [selectedIndex], with: .automatic)
        tableView.scrollToRow(at: selectedIndex, at: .middle, animated: true)
    }

    func setupDelegateAndDataSource() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setObservers() {
        let keyboardWillShow = UIResponder.keyboardWillShowNotification
        let keyboardWillHide = UIResponder.keyboardWillHideNotification
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(sender:)), name: keyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(sender:)), name: keyboardWillShow, object: nil)
    }
    
    @objc func hideKeyboard(sender: NSNotification) {
        navigationView.backgroundColor = .systemOrange
    }
    
    @objc func showKeyboard(sender: NSNotification) {
        navigationView.backgroundColor = .systemPink
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = weather != nil ? weather!.daily!.data.count : 0
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HomeForecastCell
        cell?.forecast = weather!.daily!.data[indexPath.row]
        cell?.setupView()
    
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard isExpanded && selectedIndex == indexPath else { return 76 }
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        didExpandeCell()
    }
}


