//
//  AuthView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import SwiftUI

struct AuthView: View {
    @State private var isSignup = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var dateOfBirth = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 20) {
            // App logo/title
            VStack {
                Image(systemName: "eye")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("RefreshX")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 30)
            
            // Form title
            Text(isSignup ? "Create Account" : "Welcome Back")
                .font(.title)
                .fontWeight(.semibold)
            
            // Form fields
            VStack(spacing: 15) {
                if isSignup {
                    TextField("Full Name", text: $name)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .autocapitalization(.words)
                        
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(.horizontal)
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedTextFieldStyle())
            }
            .padding(.bottom, 20)
            
            // Submit button
            Button(action: {
                isLoading = true
                if isSignup {
                    handleSignup()
                } else {
                    handleLogin()
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(isSignup ? "Create Account" : "Login")
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isFormInvalid || isLoading)
            
            // Toggle between signup and login
            Button(action: {
                isSignup.toggle()
                clearFields()
            }) {
                Text(isSignup ? "Already have an account? Login" : "Don't have an account? Sign Up")
                    .foregroundColor(.blue)
                    .font(.subheadline)
            }
            .padding(.top, 10)
            
            // Demo login button
            Button(action: {
                dataManager.loadSampleData()
            }) {
                Text("Demo Login")
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 30)
        }
        .padding(.horizontal, 30)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var isFormInvalid: Bool {
        if isSignup {
            return email.isEmpty || password.isEmpty || name.isEmpty
        } else {
            return email.isEmpty || password.isEmpty
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        name = ""
        dateOfBirth = Date()
    }
    
    private func handleLogin() {
        // This is a temporary implementation until we connect to Supabase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if email == "john@example.com" && password == "password123" {
                dataManager.loadSampleData()
            } else {
                alertMessage = "Invalid email or password"
                showAlert = true
            }
            isLoading = false
        }
    }
    
    private func handleSignup() {
        // This is a temporary implementation until we connect to Supabase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
                dataManager.setCurrentUser(user)
            } catch {
                alertMessage = "Signup failed: \(error.localizedDescription)"
                showAlert = true
            }
            isLoading = false
        }
    }
}

// Custom styles
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(configuration.isPressed ? Color.blue.opacity(0.8) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(DataManager.shared)
    }
}
