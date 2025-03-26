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
    @State private var rotationAngle: Double = 0 // For rotating animation
    
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App logo/title
                VStack {
                    Image("appImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.top, 40)
                        .padding(.bottom, 8)
                    
                    Text("RefreshX")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryText"))
                }
                
                // Form title
                Text(isSignup ? "Create Account" : "Welcome Back")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("PrimaryText"))
                    .padding(.top, 20)
                
                // Form fields
                VStack(spacing: 16) {
                    if isSignup {
                        TextField("Full Name", text: $name)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.name)
                            .submitLabel(.next)
                        
                        DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .accentColor(Color("AccentColor"))
                            .padding(.horizontal, 8)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .submitLabel(.next)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.password)
                        .submitLabel(.go)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                
                // Submit button
                Button(action: {
                    isLoading = true
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                    if isSignup {
                        handleSignup()
                    } else {
                        handleLogin()
                    }
                }) {
                    ZStack {
                        Text(isSignup ? "Create Account" : "Sign In")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .opacity(isLoading ? 0 : 1)
                        
                        if isLoading {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(rotationAngle))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(isFormInvalid ? Color("AccentColor").opacity(0.5) : Color("AccentColor"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .disabled(isFormInvalid || isLoading)
                .padding(.horizontal, 16)
                
                // Toggle between signup and login
                Button(action: {
                    withAnimation(.easeInOut) {
                        isSignup.toggle()
                        clearFields()
                    }
                }) {
                    Text(isSignup ? "Already have an account? Sign In" : "Need an account? Sign Up")
                        .font(.system(size: 15))
                        .foregroundColor(Color("AccentColor"))
                }
                .padding(.top, 12)
                
                // Demo login button
                Button(action: {
                    email = "john@example.com"
                    password = "password123"
                    isLoading = true
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                    handleLogin()
                }) {
                    Text("Demo Sign In")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("SecondaryText"))
                }
                .padding(.top, 20)
            }
            .padding(.bottom, 40)
        }
        .background(Color("PrimaryBackground").ignoresSafeArea())
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if email == "john@example.com" && password == "password123" {
                dataManager.loadSampleData()
            } else {
                alertMessage = "Invalid email or password"
                showAlert = true
            }
            isLoading = false
            rotationAngle = 0
        }
    }
    
    private func handleSignup() {
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
            rotationAngle = 0
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 17))
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color("FieldBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(Color("PrimaryText"))
            .autocapitalization(.none)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(DataManager.shared)
    }
}
