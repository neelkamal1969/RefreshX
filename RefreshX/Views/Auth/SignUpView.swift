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
    
    private let minimumDate = Calendar.current.date(byAdding: .year, value: -3, to: Date()) ?? Date()
    
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
        .overlay(passwordInfoOverlay)
        .onChange(of: password) { _ in updatePasswordValidation() }
        .onChange(of: confirmPassword) { _ in isPasswordMatching = password == confirmPassword }
        // Dismiss password info when tapping outside
        .onTapGesture {
            showPasswordInfo = false
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
        VStack(alignment: .leading, spacing: 6) {
            Text("Full Name")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("PrimaryText"))
            
            TextField("", text: $name, prompt: Text("Enter your name").foregroundColor(.gray))
                .padding()
                .background(Color("FieldBackground"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isNameValid ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
                )
                .onChange(of: name) { isNameValid = name.count >= 3 }
            
            if !isNameValid && !name.isEmpty {
                Text("Name must be at least 3 characters")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
    }
    
    private var dateOfBirthField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 10) {
                Text("Date of Birth")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                    .frame(width: 120, alignment: .leading)
                
                DatePicker("", selection: $dateOfBirth, in: ...minimumDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color("FieldBackground"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isAgeValid ? Color.gray.opacity(0.2) : Color.red, lineWidth: 1)
                    )
            }
            .onChange(of: dateOfBirth) {
                let ageComponents = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date())
                isAgeValid = (ageComponents.year ?? 0) >= 3
            }
            
            if !isAgeValid {
                Text("You must be at least 3 years old")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.leading, 130) // Align error message with DatePicker
            }
        }
    }
    
    private var emailField: some View {
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
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Password")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
                
                Spacer()
                
                Button(action: { showPasswordInfo.toggle() }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                if isShowingPassword {
                    TextField("", text: $password, prompt: Text("Create password").foregroundColor(.gray))
                        .autocapitalization(.none)
                } else {
                    SecureField("", text: $password, prompt: Text("Create password").foregroundColor(.gray))
                }
                
                Button(action: { isShowingPassword.toggle() }) {
                    Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
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
            
            if !isPasswordValid && !password.isEmpty {
                Text(password.passwordStrength().message)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private var confirmPasswordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Confirm Password")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("PrimaryText"))
            
            HStack {
                if isShowingConfirmPassword {
                    TextField("", text: $confirmPassword, prompt: Text("Confirm password").foregroundColor(.gray))
                        .autocapitalization(.none)
                } else {
                    SecureField("", text: $confirmPassword, prompt: Text("Confirm password").foregroundColor(.gray))
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
    
    private var passwordInfoOverlay: some View {
        Group {
            if showPasswordInfo {
                PasswordInfoOverlay()
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 100) // Center it slightly above middle
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Validation Logic
    
    private var isFormValid: Bool {
        let fieldsNotEmpty = !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
        let validations = isNameValid && isEmailValid && isPasswordValid && isPasswordMatching && isAgeValid
        return fieldsNotEmpty && validations
    }
    
    private func updatePasswordValidation() {
        isPasswordValid = password.isValidPassword
        isPasswordMatching = password == confirmPassword
    }
    
    // MARK: - Actions
    
    private func handleSignUp() {
        isLoading = true
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
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
                onSignUpSuccess(user)
            } catch {
                onSignUpError(error.localizedDescription)
            }
        }
    }
}

struct PasswordInfoOverlay: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("Password Requirements")
                .font(.headline)
            Text("• At least 6 characters\n• 1 uppercase letter\n• 1 lowercase letter\n• 1 number\n• 1 special character")
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color("FieldBackground"))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(
            onBackToLogin: {},
            onSignUpSuccess: { _ in },
            onSignUpError: { _ in }
        )
    }
}
