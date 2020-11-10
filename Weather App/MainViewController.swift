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
    
    private var locationManager: CLLocationManager? = CLLocationManager()
    private var userLocation: CLLocation? = CLLocation()
    
    
    private let detectButton: UIButton = {
        let detectButton = UIButton()
        detectButton.backgroundColor = .blue
        detectButton.translatesAutoresizingMaskIntoConstraints = false
        detectButton.setTitle("Detect location", for: .normal)
        detectButton.addTarget(self, action: #selector(showLocation), for: .touchUpInside)
        return detectButton
    }()
    
    private var locationLabel: UILabel = {
        var locationLabel = UILabel()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        return locationLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arrangeSubviews()
        setupViewConstraints()
        locationManager?.delegate = self
    }
    
    func requestUserLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
        } else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    @objc func showLocation() {
        requestUserLocation()
    }

}

private extension MainViewController {
    
    func arrangeSubviews() {
        view.addSubview(detectButton)
        view.addSubview(locationLabel)
    }
    
    func setupViewConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            detectButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            detectButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08),
            detectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detectButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        manager.stopUpdatingLocation()
    }
}

