//
//  Errors.swift
//  Fetch_Project
//
//  Created by Cobra Curtis on 9/11/23.
//

import Foundation

/**
 custom errors that can be thrown by the RecipeAPI class
 */
enum NTError: Error{
    case invalidURL
    case invalidResponse
    case badRequest
    case invalidData
    case decodingError
    case unsupportedURL
}
