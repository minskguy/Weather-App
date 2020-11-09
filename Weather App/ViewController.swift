//
//  ViewController.swift
//  Weather App
//
//  Created by Марк Курлович on 11/8/20.
//  Copyright © 2020 Mark Kurlovich. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {
    
    private let detectButton: UIButton = {
        let detectButton = UIButton()
        detectButton.backgroundColor = .blue
        detectButton.translatesAutoresizingMaskIntoConstraints = false
        detectButton.setTitle("Detect location", for: .normal)
        detectButton.addTarget(self, action: #selector(showLocation), for: .touchUpInside)
        return detectButton
    }()
    
    private let locationLabel: UILabel = {
        let location = UILabel()
        location.translatesAutoresizingMaskIntoConstraints = false
        return location
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        arrangeSubviews()
        setupViewConstraints()
    }
    
    @objc func showLocation() {
        if locationLabel.text == "" {
            locationLabel.text = "Minsk, Belarus"
            detectButton.setTitle("Hide location", for: .normal)
        }
        else {
            locationLabel.text = ""
            detectButton.setTitle("Show location", for: .normal)
        }
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
            detectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detectButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

