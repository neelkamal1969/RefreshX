//
//  LoginView.swift
//  RefreshX
//
//  Created by student-2 on 26/03/25.
//


import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingPassword = false
    @State private var isEmailValid = true
    @State private var isLoading = false
    @State private var rotationAngle: Double = 0
    
    var onSignUp: () -> Void
    var onForgotPassword: () -> Void
    var onLoginSuccess: (User) -> Void
    var onLoginError: (String) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("Welcome Back")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(Color("PrimaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                
                TextField("", text: $email, prompt: Text("your@email.com").foregroundStyle(.gray))
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .submitLabel(.next)
                    .padding()
                    .background(Color("FieldBackground"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isEmailValid ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
                    )
                    .onChange(of: email) {
                        isEmailValid = email.isEmpty || User.isValidEmail(email)
                    }
                
                if !isEmailValid {
                    Text("Please enter a valid email address")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                
                HStack {
                    if isShowingPassword {
                        TextField("", text: $password, prompt: Text("Enter your password").foregroundStyle(.gray))
                            .autocapitalization(.none)
                            .textContentType(.password)
                            .submitLabel(.go)
                    } else {
                        SecureField("", text: $password, prompt: Text("Enter your password").foregroundStyle(.gray))
                            .textContentType(.password)
                            .submitLabel(.go)
                    }
                    
                    Button(action: { isShowingPassword.toggle() }) {
                        Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
                .padding()
                .background(Color("FieldBackground"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Forgot password
            HStack {
                Spacer()
                Button(action: onForgotPassword) {
                    Text("Forgot Password?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(.top, -8)
            
            // Sign in button
            Button(action: handleLogin) {
                ZStack {
                    Text("Sign In")
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
            
            // Sign up option
            HStack {
                Text("Need an account?")
                    .font(.system(size: 16))
                    .foregroundColor(Color("SecondaryText"))
                
                Button(action: onSignUp) {
                    Text("Sign Up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(.top, 20)
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && User.isValidEmail(email) && !password.isEmpty
    }
    
    private func handleLogin() {
        isLoading = true
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Simulate backend call - integrate with Supabase in the future
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            rotationAngle = 0
            
            // Demo login for now - replace with actual authentication
            if email == "john@example.com" && password == "password123" {
                do {
                    let user = try User(
                        name: "John Doe",
                        email: email,
                        password: password,
                        dateOfBirth: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
                    )
                    onLoginSuccess(user)
                } catch {
                    onLoginError(error.localizedDescription)
                }
            } else {
                // For a real app, this would check with Supabase
                onLoginError("Invalid email or password")
            }
        }
    }
}

#Preview {
    LoginView(
        onSignUp: {},
        onForgotPassword: {},
        onLoginSuccess: { _ in },
        onLoginError: { _ in }
    )
    .padding()
    .previewLayout(.sizeThatFits)
}


