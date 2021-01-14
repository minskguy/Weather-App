import Foundation
import UIKit
import CoreLocation

struct WeatherModel: Codable {
    var weather: [Weather]
    var main: Main
}

struct Weather: Codable {
    var main: String
}

struct Main: Codable {
    var temp: Double
}

final class WeatherViewController: UIViewController {
    var city: String = ""
    var weatherModel: WeatherModel?
    
    private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return activityIndicator
    }()

    private var cityLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica", size: 40)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var weatherStateLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica", size: 40)
        label.textAlignment = .center
        return label
    }()
    
    private var temperatureLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica", size: 40)
        label.textAlignment = .center
        return label
    }()
    
    private var labelStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .green
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Refresh", for: .normal)
        button.addTarget(self, action: #selector(refreshWeather), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureStackView()
        arrangeSubviews()
        setupViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareUIForRequest()
        request(location: city)
    }
    
    func request(location: String) {
        activityIndicatorView.startAnimating()
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(location)&appid=d2fef664f793756b0586171c28a62a27") else { return }
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode < 200 && response.statusCode > 226 {
                return
            }
                

            guard let data = data else { return }

            do {
                self.weatherModel = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.async {
                    guard let weather = self.weatherModel else { return }
                    self.cityLabel.text = self.city
                    self.weatherStateLabel.text = String(weather.weather[0].main)
                    self.temperatureLabel.text = String(Int(weather.main.temp) - 273)
                    self.activityIndicatorView.stopAnimating()
                    self.updateUIAfterRequest()
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }

        }.resume()
    }
    
    func prepareUIForRequest() {
        labelStackView.isHidden = true
    }
    
    func updateUIAfterRequest() {
        labelStackView.isHidden = false
    }
    
    func configureStackView() {
        labelStackView.addArrangedSubview(cityLabel)
        labelStackView.addArrangedSubview(weatherStateLabel)
        labelStackView.addArrangedSubview(temperatureLabel)
        
        labelStackView.axis = .vertical
        labelStackView.distribution = UIStackView.Distribution.equalSpacing
        labelStackView.spacing = 20
    }
    
    func arrangeSubviews() {
        view.addSubview(labelStackView)
        view.addSubview(refreshButton)
        view.addSubview(activityIndicatorView)
    }
    
    func setupViewConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            labelStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            labelStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            labelStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            labelStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            refreshButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            refreshButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08),
            activityIndicatorView.centerXAnchor.constraint(equalTo: labelStackView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: labelStackView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func refreshWeather() {
        prepareUIForRequest()
        request(location: city)
    }
}
