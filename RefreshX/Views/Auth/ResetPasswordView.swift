//
//  ResetPasswordView.swift
//  RefreshX
//
//  Created by student-2 on 26/03/25.


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
    @State private var showPasswordInfo = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Set New Password")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(Color("PrimaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter your new password for")
                    .font(.system(size: 16))
                    .foregroundColor(Color("SecondaryText"))
                
                Text(email)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // New Password field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("New Password")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("PrimaryText"))
                    
                    Spacer()
                    
                    Button(action: {
                        showPasswordInfo.toggle()
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color("AccentColor"))
                    }
                }
                
                HStack {
                    if isShowingNewPassword {
                        TextField("Enter new password", text: $newPassword)
                            .autocapitalization(.none)
                            .textContentType(.newPassword)
                            .submitLabel(.next)
                    } else {
                        SecureField("Enter new password", text: $newPassword)
                            .textContentType(.newPassword)
                            .submitLabel(.next)
                    }
                    
                    Button(action: { isShowingNewPassword.toggle() }) {
                        Image(systemName: isShowingNewPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
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
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                
                HStack {
                    if isShowingConfirmPassword {
                        TextField("Confirm new password", text: $confirmPassword)
                            .autocapitalization(.none)
                            .textContentType(.newPassword)
                            .submitLabel(.done)
                    } else {
                        SecureField("Confirm new password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .submitLabel(.done)
                    }
                    
                    Button(action: { isShowingConfirmPassword.toggle() }) {
                        Image(systemName: isShowingConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
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
            .padding(.top, 12)
            
            // Back to login
            Button(action: onBackToLogin) {
                HStack {

                    Text("Back to Login")
                        .font(.system(size: 16))
                }
                .foregroundColor(Color("AccentColor"))
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .onChange(of: newPassword) {
            oldValue, newValue in isPasswordValid = newPassword.isEmpty || newPassword.isValidPassword
            isPasswordMatching = newPassword == confirmPassword
        }
        .onChange(of: confirmPassword) {
            oldValue, newValue in isPasswordMatching = newPassword == confirmPassword
        }
        .sheet(isPresented: $showPasswordInfo) {
            PasswordInfoSheet()
                .presentationDetents([.height(250)])
        }
    }
    
    private var isFormValid: Bool {
        !newPassword.isEmpty && newPassword.isValidPassword && isPasswordMatching && !confirmPassword.isEmpty
    }
    
    private func handleReset() {
        isLoading = true
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Simulate backend call to update password
        // In a real app, this would call a Supabase function to update the user's password
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            rotationAngle = 0
            
            // Simulate success - in production would verify OTP and update password in database
            onResetSuccess()
        }
    }
}

struct PasswordInfoSheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Password Requirements")
                .font(.headline)
                .foregroundColor(Color("PrimaryText"))
            
            VStack(alignment: .leading, spacing: 8) {
                PasswordRequirementRow(text: "At least 6 characters")
                PasswordRequirementRow(text: "1 uppercase letter (A-Z)")
                PasswordRequirementRow(text: "1 lowercase letter (a-z)")
                PasswordRequirementRow(text: "1 number (0-9)")
                PasswordRequirementRow(text: "1 special character (!@#$%^&*)")
            }
            .font(.subheadline)
        }
        .padding(20)
    }
}

#Preview {
    ResetPasswordView(
        email: "user@example.com",
        otp: "123456",
        onBackToLogin: {},
        onResetSuccess: {},
        onResetError: { _ in }
    )
    .padding()
}
