//
//  LoadingView.swift
//  UalaTest
//
//  Created by Cristian Carlassare on 31/10/2024.
//

import UIKit


class LoadingView {
    static let shared = LoadingView()
    private var spinnerView: UIView?

    private init() {}
    
    
    // MARK: - Public Methods
    
    func show(in view: UIView) {
        guard spinnerView == nil else { return }  // Prevent multiple spinners
        
        // Create a semi-transparent background view
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.layer.cornerRadius = 10
        backgroundView.alpha = 0
        
        // Create the spinner
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        // Add spinner to the background view
        backgroundView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
        
        // Add background view to the main view and set animation
        view.addSubview(backgroundView)
        UIView.animate(withDuration: 0.3) {
            backgroundView.alpha = 1
        }
        
        // Keep a reference to the spinner view
        spinnerView = backgroundView
    }
    
    func hide() {
        guard let spinnerView = spinnerView else { return }
        
        // Animate spinner disappearing effect
        UIView.animate(withDuration: 0.3, animations: {
            spinnerView.alpha = 0
        }) { _ in
            spinnerView.removeFromSuperview()
        }
        
        self.spinnerView = nil
    }
}
