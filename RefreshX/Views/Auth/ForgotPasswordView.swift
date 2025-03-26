//
//  ForgotPasswordView.swift
//  RefreshX
//
//  Created by student-2 on 26/03/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isEmailValid = true
    @State private var isLoading = false
    @State private var rotationAngle: Double = 0
    
    var onBackToLogin: () -> Void
    var onSendCodeSuccess: (String) -> Void
    var onSendCodeError: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(Color("PrimaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Enter your email address and we'll send you a verification code")
                .font(.system(size: 16))
                .foregroundColor(Color("SecondaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Email field
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                
                TextField("", text: $email, prompt: Text("your@email.com").foregroundColor(.gray))
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color("FieldBackground"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isEmailValid ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
                    )
                    .onChange(of: email) { isEmailValid = User.isValidEmail(email) }
                
                if !isEmailValid && !email.isEmpty {
                    Text("Please enter a valid email address")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            // Send Code button
            Button(action: handleSendCode) {
                ZStack {
                    Text("Send Verification Code")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(isLoading ? 0 : 1)
                    
                    if isLoading {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isFormValid ? Color("AccentColor") : Color("AccentColor").opacity(0.5))
                .cornerRadius(12)
            }
            .disabled(!isFormValid || isLoading)
            
            // Back to login
            Button(action: onBackToLogin) {
                HStack {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14))
                    Text("Back to Login")
                        .font(.system(size: 16))
                }
                .foregroundColor(Color("AccentColor"))
            }
            .padding(.top, 20)
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && User.isValidEmail(email)
    }
    
    private func handleSendCode() {
        isLoading = true
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Simulate SMTP/Backend call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            rotationAngle = 0
            
            let existingEmails = ["john@example.com"]
            if existingEmails.contains(email.lowercased()) {
                onSendCodeSuccess(email)
            } else {
                onSendCodeError("No account found with this email")
            }
        }
    }
}
