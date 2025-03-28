//
//  ValidationHelpers.swift
//  RefreshX
//
//  Created by student-2 on 26/03/25.

import Foundation
import SwiftUICore

extension String {
    var isValidPassword: Bool {
        // At least 6 characters
        guard self.count >= 6 else { return false }
        
        // Contains at least one uppercase letter
        let uppercaseRegex = ".*[A-Z]+.*"
        guard self.range(of: uppercaseRegex, options: .regularExpression) != nil else { return false }
        
        // Contains at least one lowercase letter
        let lowercaseRegex = ".*[a-z]+.*"
        guard self.range(of: lowercaseRegex, options: .regularExpression) != nil else { return false }
        
        // Contains at least one digit
        let digitRegex = ".*[0-9]+.*"
        guard self.range(of: digitRegex, options: .regularExpression) != nil else { return false }
        
        // Contains at least one special character
        let specialCharRegex = ".*[^A-Za-z0-9].*"
        guard self.range(of: specialCharRegex, options: .regularExpression) != nil else { return false }
        
        return true
    }
    
    func passwordStrength() -> (isValid: Bool, message: String) {
        if self.isEmpty {
            return (false, "Password is required")
        }
        
        if self.count < 6 {
            return (false, "Password must be at least 6 characters")
        }
        
        if !self.contains(where: { $0.isUppercase }) {
            return (false, "Password must contain at least 1 uppercase letter")
        }
        
        if !self.contains(where: { $0.isLowercase }) {
            return (false, "Password must contain at least 1 lowercase letter")
        }
        
        if !self.contains(where: { $0.isNumber }) {
            return (false, "Password must contain at least 1 number")
        }
        
        if self.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) == nil {
            return (false, "Password must contain at least 1 special character")
        }
        
        return (true, "Password is strong")
    }
    
    // Helper function to validate email format
    // This is redundant since User already has this, but keeping for consistency
    var isValidEmail: Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}

// Extension for handling common validation UI updates
extension View {
    func validateField<T: Equatable>(value: T, condition: (T) -> Bool, errorMessage: String) -> some View {
        let isValid = condition(value)
        return self
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isValid ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
            )
            .padding(.bottom, isValid ? 0 : 20) // Space for error message
            .overlay(
                Group {
                    if !isValid {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                },
                alignment: .bottom
            )
    }
}
