//
//  ViewController.swift
//  Weather App
//
//  Created by Марк Курлович on 11/8/20.
//  Copyright © 2020 Mark Kurlovich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let button : UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Detect location", for: .normal)
        button.addTarget(self, action: #selector(showLocation), for: .touchUpInside)
        
        return button
    }()
    
    private let location : UILabel = {
        let location = UILabel()
        location.translatesAutoresizingMaskIntoConstraints = false
        location.text = ""
        location.textColor = .black
        return location
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        view.addSubview(location)
        addConstraints()
        
    }

    private func addConstraints() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(button.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                         multiplier: 0.5))
        constraints.append(button.heightAnchor.constraint(equalTo: view.heightAnchor,
                                                          multiplier: 0.08))
        constraints.append(button.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100))
        
        constraints.append(location.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(location.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func showLocation() {
        if (location.text == "") {
            location.text = "Minsk, Belarus"
            button.setTitle("Hide location", for: .normal)
        }
        else {
            location.text = ""
            button.setTitle("Show location", for: .normal)
        }
    }

}

