//
//  MapViewController.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 30/10/2024.
//

import UIKit
import MapKit


class MapViewController: UIViewController {
    
    
    // MARK: - Properties
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        
        return map
    }()
    
    private var currentCity: City?
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    
    // MARK: - Setup Methods
    
    private func setupMapView() {
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Additional map view configuration
        mapView.mapType = .standard
        mapView.showsUserLocation = false
        mapView.delegate = self
    }
    
    
    // MARK: - Update

    func updateMap(for city: City) {
        currentCity = city
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let coordinate = city.location
            
            // Validate the coordinate
            guard CLLocationCoordinate2DIsValid(coordinate) else {
                ErrorHandler.shared.handle(error: GeneralError.unknownError, in: self)
                return
            }
            
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 30000,
                longitudinalMeters: 30000
            )
            self.mapView.setRegion(region, animated: true)
            self.addAnnotation(for: city)
        }
    }
    
    
    // MARK: - Private Methods

    private func addAnnotation(for city: City) {
        // Remove existing annotations to avoid duplicates
        mapView.removeAnnotations(mapView.annotations)
        
        // Create a new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = city.location
        annotation.title = city.name
        annotation.subtitle = "Tap for more info"
        
        mapView.addAnnotation(annotation)
    }
}


// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Use default user location view
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "CityAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            // Initialize a new annotation view
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.glyphImage = UIImage(systemName: "mappin.and.ellipse")
            annotationView?.markerTintColor = .systemRed
            
            // Add a button
            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation, let cityName = annotation.title ?? "" else { return }
        
        guard let city = currentCity, city.name == cityName else {
            ErrorHandler.shared.handle(error: GeneralError.unknownError, in: self)
            return
        }
        
        // Navigate to the city's information view controller
        let infoVC = CityInfoViewController(city: city)
        navigationController?.pushViewController(infoVC, animated: true)
    }
}
