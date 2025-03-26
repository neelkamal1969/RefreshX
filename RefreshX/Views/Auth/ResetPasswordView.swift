//
//  ResetPasswordView.swift
//  RefreshX
//
//  Created by student-2 on 26/03/25.
//

import SwiftUI

struct ResetPasswordView: View {
    let email: String
    let otp: String
    var onBackToLogin: () -> Void
    var onResetSuccess: () -> Void
    var onResetError: (String) -> Void
    
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isShowingNewPassword = false
    @State private var isShowingConfirmPassword = false
    @State private var isPasswordValid = true
    @State private var isPasswordMatching = true
    @State private var isLoading = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Set New Password")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(Color("PrimaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Enter your new password for \(email)")
                .font(.system(size: 16))
                .foregroundColor(Color("SecondaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // New Password field
            VStack(alignment: .leading, spacing: 6) {
                Text("New Password")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                
                HStack {
                    if isShowingNewPassword {
                        TextField("", text: $newPassword, prompt: Text("Enter new password").foregroundColor(.gray))
                            .autocapitalization(.none)
                    } else {
                        SecureField("", text: $newPassword, prompt: Text("Enter new password").foregroundColor(.gray))
                    }
                    
                    Button(action: { isShowingNewPassword.toggle() }) {
                        Image(systemName: isShowingNewPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color("FieldBackground"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isPasswordValid ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
                )
                
                if !isPasswordValid && !newPassword.isEmpty {
                    Text(newPassword.passwordStrength().message)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Confirm Password field
            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                
                HStack {
                    if isShowingConfirmPassword {
                        TextField("", text: $confirmPassword, prompt: Text("Confirm new password").foregroundColor(.gray))
                            .autocapitalization(.none)
                    } else {
                        SecureField("", text: $confirmPassword, prompt: Text("Confirm new password").foregroundColor(.gray))
                    }
                    
                    Button(action: { isShowingConfirmPassword.toggle() }) {
                        Image(systemName: isShowingConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color("FieldBackground"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isPasswordMatching ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
                )
                
                if !isPasswordMatching && !confirmPassword.isEmpty {
                    Text("Passwords do not match")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            // Reset button
            Button(action: handleReset) {
                ZStack {
                    Text("Reset Password")
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
        .onChange(of: newPassword) {
            isPasswordValid = newPassword.isValidPassword
            isPasswordMatching = newPassword == confirmPassword
        }
        .onChange(of: confirmPassword) {
            isPasswordMatching = newPassword == confirmPassword
        }
    }
    
    private var isFormValid: Bool {
        !newPassword.isEmpty && isPasswordValid && isPasswordMatching
    }
    
    private func handleReset() {
        isLoading = true
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Simulate backend call to update password
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            rotationAngle = 0
            
            // Here you would typically call an API to update the password
            onResetSuccess()
        }
    }
}
