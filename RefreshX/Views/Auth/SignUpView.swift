//
//  SignUpView.swift
//  RefreshX
//
//  Created by student-2 on 26/03/25.


import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var isShowingPassword = false
    @State private var isShowingConfirmPassword = false
    @State private var isLoading = false
    @State private var rotationAngle: Double = 0
    @State private var showPasswordInfo = false
    
    // Validation states
    @State private var isNameValid = true
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var isPasswordMatching = true
    @State private var isAgeValid = true
    
    var onBackToLogin: () -> Void
    var onSignUpSuccess: (User) -> Void
    var onSignUpError: (String) -> Void
    
    // Min age is 3 years
    private let minimumDate = Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
    private let existingEmails = ["john@example.com"] // In real app, this would be checked with Supabase
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                nameField
                dateOfBirthField
                emailField
                passwordField
                confirmPasswordField
                createAccountButton
                loginOption
            }
            .padding(.vertical, 20)
        }
        .onChange(of: password) { oldValue, newValue in updatePasswordValidation() }
        .onChange(of: confirmPassword) { oldValue, newValue in isPasswordMatching = password == confirmPassword }
        // Dismiss keyboard when tapping outside
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .sheet(isPresented: $showPasswordInfo) {
            PasswordInfoSheet()
                .presentationDetents([.height(250)])
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text("Create Account")
            .font(.system(size: 28, weight: .semibold, design: .rounded))
            .foregroundColor(Color("PrimaryText"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Full Name")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("PrimaryText"))
            
            TextField("", text: $name, prompt: Text("Enter your name").foregroundStyle(.gray))
                .textContentType(.name)
                .submitLabel(.next)
                .padding()
                .background(Color("FieldBackground"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isNameValid ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
                )
                .onChange(of: name) { oldValue, newValue in isNameValid = name.isEmpty || name.count >= 3 }
            
            if !isNameValid {
                Text("Name must be at least 3 characters")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
    }
    
    private var dateOfBirthField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Date of Birth")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Only the DatePicker with its own background
                DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .accentColor(Color.blue)
                    .onChange(of: dateOfBirth) {
                        oldValue, newValue in let ageComponents = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date())
                        isAgeValid = (ageComponents.year ?? 0) >= 3
                    }
            }
            .padding(.vertical, 4)
            
            if !isAgeValid {
                Text("You must be at least 3 years old")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
    }
    
    private var emailField: some View {
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
                    oldValue, newValue in isEmailValid = email.isEmpty || User.isValidEmail(email)
                }
            
            if !isEmailValid {
                Text("Please enter a valid email address")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Password")
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
                if isShowingPassword {
                    TextField("", text: $password, prompt: Text("Create password").foregroundStyle(.gray))
                        .autocapitalization(.none)
                        .textContentType(.newPassword)
                        .submitLabel(.next)
                } else {
                    SecureField("", text: $password, prompt: Text("Create password").foregroundStyle(.gray))
                        .textContentType(.newPassword)
                        .submitLabel(.next)
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
                    .stroke(isPasswordValid ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
            )
            
            if !isPasswordValid && !password.isEmpty {
                Text(password.passwordStrength().message)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private var confirmPasswordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Confirm Password")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("PrimaryText"))
            
            HStack {
                if isShowingConfirmPassword {
                    TextField("", text: $confirmPassword, prompt: Text("Confirm password").foregroundStyle(.gray))
                        .autocapitalization(.none)
                        .textContentType(.newPassword)
                        .submitLabel(.done)
                } else {
                    SecureField("", text: $confirmPassword, prompt: Text("Confirm password").foregroundStyle(.gray))
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
    }
    
    private var createAccountButton: some View {
        Button(action: handleSignUp) {
            ZStack {
                Text("Create Account")
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
    }
    
    private var loginOption: some View {
        HStack {
            Text("Already have an account?")
                .font(.system(size: 16))
                .foregroundColor(Color("SecondaryText"))
            
            Button(action: onBackToLogin) {
                Text("Sign In")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Validation Logic
    
    private var isFormValid: Bool {
        let fieldsNotEmpty = !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
        let validations = isNameValid && isEmailValid && isPasswordValid && isPasswordMatching && isAgeValid
        let passwordValid = password.isValidPassword
        return fieldsNotEmpty && validations && passwordValid
    }
    
    private func updatePasswordValidation() {
        isPasswordValid = password.isEmpty || password.isValidPassword
        isPasswordMatching = password == confirmPassword
    }
    
    // MARK: - Actions
    
    private func handleSignUp() {
        isLoading = true
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Check if email already exists (in a real app, this would check with Supabase)
        if existingEmails.contains(email.lowercased()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
                rotationAngle = 0
                onSignUpError("An account with this email already exists")
            }
            return
        }
        
        // In a real implementation, we would also verify the email is valid/exists via API
        
        // Simulate backend call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            rotationAngle = 0
            
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
                // With Supabase, we would create the user in the database here
                onSignUpSuccess(user)
            } catch {
                onSignUpError(error.localizedDescription)
            }
        }
    }
}



struct PasswordRequirementRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color("AccentColor"))
            Text(text)
                .foregroundColor(Color("PrimaryText"))
            Spacer()
        }
    }
}

#Preview {
    SignUpView(
        onBackToLogin: {},
        onSignUpSuccess: { _ in },
        onSignUpError: { _ in }
    )
    .padding()
}
