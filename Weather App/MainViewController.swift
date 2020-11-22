//
//  ViewController.swift
//  Weather App
//
//  Created by Марк Курлович on 11/8/20.
//  Copyright © 2020 Mark Kurlovich. All rights reserved.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController {
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private var isUpdatingLocation = false
    private var lastLocationError: Error?
    
    private var placemark: CLPlacemark?
    private let geocoder = CLGeocoder()
    private var isPerfomingReverseGeocoding = false
    private var lastGeocodingError: Error?
    
    private var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    
    private let detectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Detect location", for: .normal)
        button.addTarget(self, action: #selector(showLocation), for: .touchUpInside)
        return button
    }()
    
    private var locationLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.text = "HELLO"
        return label
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        arrangeSubviews()
        setupViewConstraints()
    }
    
    @objc func showLocation() {
        DispatchQueue.main.async {
            self.locationLabel.text = ""
            self.activityIndicatorView.startAnimating()
        }
        requestUserLocation()
        DispatchQueue.main.async {
            if self.placemark != nil {
                self.locationLabel.text = self.placemark?.locality!
            }
            self.activityIndicatorView.stopAnimating()
        }
    }
}

private extension MainViewController {
    
    func arrangeSubviews() {
        view.addSubview(detectButton)
        view.addSubview(locationLabel)
        view.addSubview(activityIndicatorView)
    }
    
    func setupViewConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            detectButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            detectButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08),
            detectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detectButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdatingLocation = false
        }
    }
    
    func reportLocationServiceDeniedError() {
        let alert = UIAlertController(title: "Location services disabled", message: "Please, go to Settings > Privacy to enable location services for this app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager did fail with error: \(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
        stopLocationManager()
        
        guard let location = self.userLocation else { return }
        if !isPerfomingReverseGeocoding {
            isPerfomingReverseGeocoding = true
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                self.lastGeocodingError = error
                if error == nil, let placemarks = placemarks, !placemarks.isEmpty {
                    self.placemark = placemarks.last!
                } else {
                    self.placemark = nil
                }
                self.isPerfomingReverseGeocoding = false
            }
        }
    }
    
    func requestUserLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            reportLocationServiceDeniedError()
            return
        }
        
        if isUpdatingLocation {
            stopLocationManager()
        } else {
            userLocation = nil
            lastLocationError = nil
            startLocationManager()
        }
    }
}

