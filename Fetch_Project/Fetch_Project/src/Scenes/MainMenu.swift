//
//  ViewController.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/10/23.
//

import UIKit

/**
 Initialize a test screen. Allows for future expansion to other categories of the API through similar methods and screens.
 */
class FirstScreen: UIViewController {

    //UI Elements
    let nextButton = UIButton()
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //View Has Loaded
        setupUI()
    }
    
    /**
     Setup the label and button of the menu
     */
    func setupUI(){
        //establish background color
        view.backgroundColor = .systemBackground
        
        //Setup UI Elements
        setupButton()
        setupLabel()
    }
    
    func setupLabel() {
        // Add the label to the view
        view.addSubview(self.titleLabel)
        
        // Set accessibility identifier for the label
        self.titleLabel.accessibilityIdentifier = "titleLabel"
        
        // Stylize the label
        self.titleLabel.text = "Pocket Cookbook"
        self.titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        self.titleLabel.textAlignment = .center
        
        // Constraints for the label
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20) // Position it above the nextButton
        ])
    }
    
    func setupButton() {
        view.addSubview(nextButton)
        
        // Set accessibility identifier for the button
        nextButton.accessibilityIdentifier = "nextButton"
        
        // Functionality
        nextButton.addTarget(self, action: #selector(goToNextScreen), for: .touchUpInside)
        
        // Stylize
        nextButton.configuration = .filled()
        nextButton.configuration?.baseBackgroundColor = .systemRed
        nextButton.configuration?.title = "View Desserts"
        
        // Constraints for the button
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    //Navigation Controls
    @objc func goToNextScreen(){
        let nextScreen = RecipeTableView()
        nextScreen.title = "Dessert Recipes"
        navigationController?.pushViewController(nextScreen, animated: true)
    }

}

