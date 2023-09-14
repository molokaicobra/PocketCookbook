//
//  DetailedRecipeView.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/10/23.
//

import UIKit


/**
 Provides a detailed view of the recipe that the User selected. Calls through our dedicated network layers and functions to get the needed data. Handles nil cases.
 */
class DetailedRecipeView: UIViewController, UIScrollViewDelegate {

    
    var selectedRecipeStr: String
    var recipe: [String:Any] = [:]
    private let recipeAPICaller = RecipeAPI()


    /**
     custom initializer for the DetailedRecipeView class that allows for the creation of a DetailedRecipeView when the user passes in a idMeal
     from the RecipeTableView.
     - Note: This method calls on fetchRecipe() that populates this view's self.recipe property. This method is done asynchronously.
     
     - Parameter selectedRecipe: String of digits that represent a meal's idMeal from their JSON.
     */
    init(selectedRecipe: String) {
        self.selectedRecipeStr = selectedRecipe
        super.init(nibName: nil, bundle: nil)
        
        Task {
            await fetchRecipe()
        }
    }
    
    /**
     Required initializer that should not be called
     - Warning: Do not call this method
     */
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //TODO: Create popup and have errors and send to remote database for tracking
    /**
     Makes API to network layer to populate self.recipe, Once this data has been called in it makes a call to displayRecipeDetails().
     This call is to ensure that the UI is populated with the information from the API.
     - Note: self.recipe is a custom data structure and not raw or formatted JSON. self.recipe is a [String:Any].
     
     - Catches:

        - `NTError.invalidURL`: If the API URL is invalid.
        - `NTError.invalidResponse`: If the API response is not as expected.
        - `NTError.invalidData`: If the data received from the API is invalid.
        - `NTError.badRequest`: If the API request is malformed or incorrect.
        - `NTError.decodingError`: If there is an error decoding the JSON from the API.
        - Any other unexpected errors.
     */
    private func fetchRecipe() async{
        do {
            self.recipe = try await recipeAPICaller.getAndFormatRecipe(recipeID: self.selectedRecipeStr)
        } catch NTError.invalidURL {
            print("Invalid URL")
        } catch NTError.invalidResponse {
            print("Invalid Response")
        } catch NTError.invalidData {
            print("Invalid data")
        } catch NTError.badRequest {
            print("Bad Request")
        } catch NTError.decodingError {
            print("Decoding Error")
        } catch {
            print("An unexpected error occurred: \(error)")
        }
        
        //Display information if valid data
        displayRecipeDetails()
        
    }
    
    
    // MARK: - View Lifecycle
    
    /**
     called when DetaiuledRecipeView loads in.
     Assigns all subviews and allows for scrolling in the interface. Calls on setUpConstraints() which assigns the auto layout constraints for the class.
     
     - SeeAlso: setUpConstraints()
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Add subviews to the scrollView
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(imageView)
        scrollView.addSubview(ingredientsAndMeasurementsTextView)
        scrollView.addSubview(instructionsTextView)

        // Add the scrollView to the view
        view.addSubview(scrollView)
        
        //Setup nondynamic accessibility ids:
        self.ingredientsAndMeasurementsTextView.accessibilityIdentifier = "IngredientsAndMeasurements"
        self.nameLabel.accessibilityIdentifier = "mealLabel"
        self.imageView.accessibilityIdentifier = "picture of dessert"
        self.instructionsTextView.accessibilityIdentifier = "Instructions"



        // Set up constraints
        setUpConstraints()
    }
    
    /**
     Ensures that the properties of the ScrollView are properly set
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.bounds.width, height: instructionsTextView.frame.maxY + 20)
    }

    
    //MARK: UI Element setup
    /**
     Create and assign some properties of the nameLabel of the food. In the UI this display's the recipe's name.
     */
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /**
     Create and assign some properties of the ScrollView of the food. This allows for scrolling in the UI.
     */
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.delegate = self
        return scroll
    }()
    
    /**
     Create and assign some of the properties of the UIImageView of the food.
     */
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /**
     Create and assign the properties of the ingredientsAndMeasurementsTextView of the recipe. Displayed in UI as: \u{2022} X (measurement) of Y (Ingredient) (Example: * 1/2 cup sugar)
     */
    let ingredientsAndMeasurementsTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    //TODO: Write multiple text formatters that can better format the text and handle the different common formats from the API.
    /**
     Create and assign some of the properties of the instructionsTextView. Displayed as the format from the JSON.
     */
    let instructionsTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

   
    /**
     Responsible for fully populating all the class properties with their respective content. This method is called after the completion of the async task in fetchRecipe().
     
     - Modifies: instructionsTextView, ingredientsAndMeasurementsTextView, imageView, nameLabel.
     
     This method ensures that all properties are correctly populated with data. In cases where a URL fails to load, it provides defaults to inform the user that the recipe is not available.
     
     - SeeAlso: fetchRecipe(), ImageCache, and ImageCacheExtension.
     */

    func displayRecipeDetails() {

        if let mealName = self.recipe["strMeal"] {
            nameLabel.text = (mealName as! String).capitalized
            } else {
                nameLabel.text = "No recipe name available"
            }
        
        /**
        These images are cached through an extension that has been made to UIImageView class.
        - SeeAlso: ImageCacheExtension and ImageCache
        */
        if let imageURLString = self.recipe["strMealThumb"], let imageURL = URL(string: imageURLString as! String) {
            self.imageView.loadImage(from: imageURL)
            }
        
        //Assign content and properties to ingredients and Measurements
        if let ingredientsAndMeasurements = self.recipe["combinedIngredientsAndMeasurements"], !(ingredientsAndMeasurements as! Array<String>).isEmpty {
            
            let content = (ingredientsAndMeasurements as! Array<String>).joined(separator: "\n") //Go through the list of ingredients and measurements and turns them into a list
            let formattedContent = "Ingredients:\n\n\(content)"

            ingredientsAndMeasurementsTextView.text = formattedContent
            
        } else {
            ingredientsAndMeasurementsTextView.text = "No ingredients available"
            // If there was an error, just say there is "No ingredients available"
        }

        //Assign the instructions as they are read from our data structure
        if let instructions = self.recipe["strInstructions"], !(instructions as! String).isEmpty {
            instructionsTextView.text = "Instructions:\n\n\(instructions)"
            } else {
                instructionsTextView.text = "No instructions available"
            }

    }

    /**
     Programmatically setup the Auto Layout constraints for the DetailedRecipeView
     - Note: called by ViewDidLoad()
     */
    func setUpConstraints() {
        NSLayoutConstraint.activate([
            //Position image to the top of the page filling up the top portion of the screen.
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6), // Adjust the multiplier to control the image size

            //Position the nameLabel 20 below the image and pad margins
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            //Position the ingredientsAndMeasurementsTextView 20 below the nameLabel and pad marigins
            ingredientsAndMeasurementsTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            ingredientsAndMeasurementsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ingredientsAndMeasurementsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            //Position the ingredientsAndMeasurementsTextView 20 below the nameLabel and pad marigins
            instructionsTextView.topAnchor.constraint(equalTo: ingredientsAndMeasurementsTextView.bottomAnchor, constant: 20),
            instructionsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            instructionsTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20) //leave a marigin of 20 points between the scrollView and the instructions
        ])
    }}
