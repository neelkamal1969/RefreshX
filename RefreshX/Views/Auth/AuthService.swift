//
//  AuthService.swift
//  RefreshX
//
//  Created by student-2 on 28/03/25.
import Foundation

// This service class will handle all authentication-related API calls
// It's designed to make future Supabase integration straightforward
class AuthService {
    // Singleton pattern
    static let shared = AuthService()
    
    private init() {}
    
    // Store existing users (simulating a database)
    // In production, this would be replaced with Supabase auth calls
    private let existingUsers = [
        "john@example.com": "John Doe"
    ]
    
    // MARK: - Authentication Methods
    
    /// Sign in with email and password
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - completion: Callback with Result type (User on success, Error on failure)
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real implementation, this would call Supabase auth.signIn
            if email.lowercased() == "john@example.com" && password == "password123" {
                do {
                    let user = try User(
                        name: "John Doe",
                        email: email,
                        password: password,
                        dateOfBirth: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
                    )
                    completion(.success(user))
                } catch {
                    completion(.failure(AuthError.invalidCredentials))
                }
            } else {
                completion(.failure(AuthError.invalidCredentials))
            }
        }
    }
    
    /// Sign up a new user
    /// - Parameters:
    ///   - name: User's name
    ///   - email: User's email
    ///   - password: User's password
    ///   - dateOfBirth: User's date of birth
    ///   - completion: Callback with Result type (User on success, Error on failure)
    func signUp(name: String, email: String, password: String, dateOfBirth: Date, completion: @escaping (Result<User, Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Check if email already exists
            if self.existingUsers.keys.contains(email.lowercased()) {
                completion(.failure(AuthError.emailAlreadyExists))
                return
            }
            
            // In a real implementation, this would verify the email is valid
            // using a service like abstract-api.com or similar
            
            // Create the user in Supabase auth
            do {
                let user = try User(
                    name: name,
                    email: email,
                    password: password,
                    dateOfBirth: dateOfBirth,
                    weekdays: 5,
                    numberOfBreaksPreferred: 4,
                    breakDuration: 15
                )
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Send a password reset request
    /// - Parameters:
    ///   - email: User's email
    ///   - completion: Callback with Result type (Void on success, Error on failure)
    func sendPasswordResetEmail(to email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Check if email exists in our system
            if self.existingUsers.keys.contains(email.lowercased()) {
                // In a real implementation, this would trigger Supabase's password reset
                // or use a third-party service to send OTP via email
                completion(.success(()))
            } else {
                completion(.failure(AuthError.emailNotFound))
            }
        }
    }
    
    /// Verify OTP code
    /// - Parameters:
    ///   - otp: One-time password code
    ///   - email: User's email
    ///   - completion: Callback with Result type (Void on success, Error on failure)
    func verifyOTP(otp: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real implementation, this would verify the OTP against what was stored
            // For demo purposes, the correct OTP is "123456"
            if otp == "123456" {
                completion(.success(()))
            } else {
                completion(.failure(AuthError.invalidOTP))
            }
        }
    }
    
    /// Reset user's password
    /// - Parameters:
    ///   - email: User's email
    ///   - newPassword: New password
    ///   - otp: One-time password for verification
    ///   - completion: Callback with Result type (Void on success, Error on failure)
    func resetPassword(email: String, newPassword: String, otp: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Verify OTP first
        verifyOTP(otp: otp, email: email) { result in
            switch result {
            case .success:
                // Simulate network delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    // In a real implementation, this would update the user's password in Supabase
                    // For demo purposes, always succeed
                    completion(.success(()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Verify if email exists
    /// - Parameters:
    ///   - email: User's email to check
    ///   - completion: Callback with Result type (Bool on success, Error on failure)
    func checkEmailExists(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // In a real implementation, this would check with Supabase if the email exists
            let exists = self.existingUsers.keys.contains(email.lowercased())
            completion(.success(exists))
        }
    }
    
    /// Verify email is valid/deliverable (would use an API service in production)
    /// - Parameters:
    ///   - email: Email to verify
    ///   - completion: Callback with Result type (Bool on success, Error on failure)
    func verifyEmailIsValid(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In production, would use a service like:
            // - abstract-api.com
            // - mailboxvalidator.com
            // - emailvalidation.io
            
            // For demo purposes, consider all emails valid except invalid@example.com
            let isValid = email.lowercased() != "invalid@example.com"
            completion(.success(isValid))
        }
    }
}

// MARK: - Authentication Errors

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case emailNotFound
    case invalidOTP
    case networkError
    case serverError
    case invalidEmail
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "The email or password you entered is incorrect."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .emailNotFound:
            return "No account found with this email."
        case .invalidOTP:
            return "The verification code is invalid or has expired."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .serverError:
            return "Server error. Please try again later."
        case .invalidEmail:
            return "The email address appears to be invalid."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}
