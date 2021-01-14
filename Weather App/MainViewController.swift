import Foundation
import UIKit
import CoreLocation

final class MainViewController: UIViewController {
    
    private var weatherViewController: WeatherViewController = WeatherViewController()
    private let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.pausesLocationUpdatesAutomatically = true
        return locationManager
    }()
    private var userLocation: CLLocation?
    private var lastLocationError: Error?
    
    private var placemark: CLPlacemark?
    private let geocoder = CLGeocoder()
    private var lastGeocodingError: Error?
    
    private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return activityIndicator
    }()
    
    private let detectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Detect location", for: .normal)
        button.addTarget(self, action: #selector(showLocation), for: .touchUpInside)
        return button
    }()
    
    private let showWeatherButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show weather", for: .normal)
        button.addTarget(self, action: #selector(showWeather), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private var locationLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Weather App"
        view.backgroundColor = .white
        
        arrangeSubviews()
        setupViewConstraints()
        locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
    }
    
    @objc func showLocation() {
        locationLabel.text = ""
        activityIndicatorView.startAnimating()
        requestUserLocation()
    }
    
    @objc func showWeather() {
        locationLabel.text = placemark?.locality!
        weatherViewController.city = (placemark?.locality)!
        navigationController?.pushViewController(weatherViewController, animated: true)
    }
}

private extension MainViewController {
    
    func arrangeSubviews() {
        view.addSubview(detectButton)
        view.addSubview(showWeatherButton)
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
            showWeatherButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            showWeatherButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08),
            showWeatherButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showWeatherButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func requestUserLocation() {
        locationManager.requestAlwaysAuthorization()
        let delay = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            if self.placemark != nil {
                self.locationLabel.text = self.placemark?.locality!
                self.showWeatherButton.isHidden = false
            } else {
                self.locationLabel.text = "Error"
                self.showWeatherButton.isHidden = true
            }
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            print("No access!")
        }
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
        activityIndicatorView.stopAnimating()
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
        guard let location = userLocation else { return }
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.lastGeocodingError = error
            if error == nil, let placemarks = placemarks, !placemarks.isEmpty {
                self.placemark = placemarks.last!
            }
        }
        activityIndicatorView.stopAnimating()
    }
}

