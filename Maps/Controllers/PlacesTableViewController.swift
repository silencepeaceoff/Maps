//
//  PlacesTableViewController.swift
//  Maps
//
//  Created by Dmitrii Tikhomirov on 2/23/23.
//

import UIKit
import MapKit

class PlacesTableViewController: UITableViewController {
    
    var userLocation: CLLocation
    var places: [Places]
    
    private var indexSelectedRow: Int? {
        self.places.firstIndex(where: { $0.isSelected == true })
    }
    
    init(userLocation: CLLocation, places: [Places]) {
        self.userLocation = userLocation
        self.places = places
        super.init(nibName: nil, bundle: nil)
        
        //Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        //Make selected cell on top
        if let index = indexSelectedRow {
            self.places.swapAt(index, 0)
        }
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        from.distance(from: to)
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        let meters = Measurement(value: distance, unit: UnitLength.meters)
        return meters.converted(to: .kilometers).formatted()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        let placeDetailView = DetailViewController(place: place)
        present(placeDetailView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = places[indexPath.row]
        
        //Cell configuration
        var content = cell.defaultContentConfiguration()
        content.text = place.name
        let distance = calculateDistance(from: userLocation, to: place.location)
        content.secondaryText = formatDistance(distance)
        cell.contentConfiguration = content
        cell.backgroundColor = place.isSelected ? .systemGray3 : .clear
        return cell
    }

}
