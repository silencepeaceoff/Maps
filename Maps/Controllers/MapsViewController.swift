//
//  ViewController.swift
//  Maps
//
//  Created by Dmitrii Tikhomirov on 2/23/23.
//

import UIKit
import MapKit

class MapsViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    private var places: [Places] = []
    
    private let space: CGFloat = 12.0
    private let padding: CGFloat = 24.0
    private let heightSearch: CGFloat = 44.0
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        map.showsUserLocation = true
        return map
    }()
    
    lazy var searchTextField: UITextField = {
        searchTextField = UITextField()
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 10
        searchTextField.clipsToBounds = true
        searchTextField.backgroundColor = .systemBackground
        searchTextField.placeholder = "Search"
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchTextField.leftViewMode = .always
        return searchTextField
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupUI()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestLocation()
    }
    
    private func setupUI() {
        setupMapView()
        setupSearchTextField()
        
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchTextField() {
        view.addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: guide.topAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: heightSearch),
            searchTextField.widthAnchor.constraint(equalToConstant: view.bounds.size.width * 0.8),
            searchTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //searchTextField.returnKeyType = .go
        ])
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager,
              let location = locationManager.location else { return }
        
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        case .denied:
            print("Location services has been denied")
        case .notDetermined, .restricted:
            print("Location services cannot be determined or restricted.")
        default:
            print("Some error. Unable to get location.")
        }
    }
    
    private func presentPlaces(places: [Places]) {
        guard let userLocation = locationManager?.location else { return }
        
        let placesView = PlacesTableViewController(userLocation: userLocation, places: places)
        placesView.modalPresentationStyle = .pageSheet
        
        if let sheet = placesView.sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.detents = [.medium(), .large()]
            present(placesView, animated: true)
        }
    }
    
    private func findPlaces(by query: String) {
        mapView.removeAnnotations(mapView.annotations)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else { return }
            self?.places = response.mapItems.map(Places.init)
            self?.places.forEach { place in
                self?.mapView.addAnnotation(place)
            }
            if let places = self?.places {
                self?.presentPlaces(places: places)
            }
        }
    }
    
}

extension MapsViewController: CLLocationManagerDelegate {
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if !text.isEmpty {
                textField.resignFirstResponder()
                findPlaces(by: text)
            }
        }
        return true
    }
}

extension MapsViewController: MKMapViewDelegate {
    
    private func clearAllSelections() {
        self.places = self.places.map({ place in
            place.isSelected = false
            return place
        })
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        //Clear selection
        clearAllSelections()
        
        guard let selectedPlace = annotation as? Places else { return }
        let place = self.places.first(where: { $0.id == selectedPlace.id })
        place?.isSelected = true
        presentPlaces(places: self.places)
    }
}
