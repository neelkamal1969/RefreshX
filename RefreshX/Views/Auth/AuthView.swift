//
//  AuthView.swift
//  RefreshX
//
//  Created by student-2 on 25/03/25.
//

import SwiftUI

struct AuthView: View {
    @State private var authState: AuthState = .login
    @State private var alertItem: AlertItem?
    @State private var showAlert = false
    
    @EnvironmentObject var dataManager: DataManager
    
    enum AuthState: Equatable {  // Added Equatable conformance
        case login
        case signup
        case forgotPassword
        case otpVerification(email: String)
        case resetPassword(email: String, otp: String)
        
        // Implement Equatable conformance
        static func == (lhs: AuthState, rhs: AuthState) -> Bool {
            switch (lhs, rhs) {
            case (.login, .login),
                 (.signup, .signup),
                 (.forgotPassword, .forgotPassword):
                return true
            case (.otpVerification(let email1), .otpVerification(let email2)):
                return email1 == email2
            case (.resetPassword(let email1, let otp1), .resetPassword(let email2, let otp2)):
                return email1 == email2 && otp1 == otp2
            default:
                return false
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 60)
                    
                    VStack(spacing: 20) {
                        Group {
                            switch authState {
                            case .login:
                                LoginView(
                                    onSignUp: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .signup
                                        }
                                    },
                                    onForgotPassword: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .forgotPassword
                                        }
                                    },
                                    onLoginSuccess: { user in
                                        dataManager.setCurrentUser(user)
                                    },
                                    onLoginError: { error in
                                        alertItem = AlertItem(title: "Login Failed", message: error, buttonText: "OK")
                                        showAlert = true
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .scale(scale: 1.2).combined(with: .opacity)
                                ))
                                
                            case .signup:
                                SignUpView(
                                    onBackToLogin: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .login
                                        }
                                    },
                                    onSignUpSuccess: { user in
                                        dataManager.setCurrentUser(user)
                                        alertItem = AlertItem(title: "Success", message: "Account created successfully!", buttonText: "Continue")
                                        showAlert = true
                                    },
                                    onSignUpError: { error in
                                        alertItem = AlertItem(title: "Sign Up Failed", message: error, buttonText: "OK")
                                        showAlert = true
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                
                            case .forgotPassword:
                                ForgotPasswordView(
                                    onBackToLogin: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .login
                                        }
                                    },
                                    onSendCodeSuccess: { email in
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .otpVerification(email: email)
                                        }
                                    },
                                    onSendCodeError: { error in
                                        alertItem = AlertItem(title: "Error", message: error, buttonText: "OK")
                                        showAlert = true
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                
                            case .otpVerification(let email):
                                OTPVerificationView(
                                    email: email,
                                    onBackToForgotPassword: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .forgotPassword
                                        }
                                    },
                                    onVerificationSuccess: { otp in
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .resetPassword(email: email, otp: otp)
                                        }
                                    },
                                    onVerificationError: { error in
                                        alertItem = AlertItem(title: "Verification Failed", message: error, buttonText: "OK")
                                        showAlert = true
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                
                            case .resetPassword(let email, let otp):
                                ResetPasswordView(
                                    email: email,
                                    otp: otp,
                                    onBackToLogin: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .login
                                        }
                                    },
                                    onResetSuccess: {
                                        alertItem = AlertItem(title: "Success", message: "Password reset successfully!", buttonText: "Login")
                                        showAlert = true
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            authState = .login
                                        }
                                    },
                                    onResetError: { error in
                                        alertItem = AlertItem(title: "Reset Failed", message: error, buttonText: "OK")
                                        showAlert = true
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: authState)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertItem?.title ?? ""),
                    message: Text(alertItem?.message ?? ""),
                    dismissButton: .default(Text(alertItem?.buttonText ?? "OK"))
                )
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

struct AlertItem {
    var title: String
    var message: String
    var buttonText: String
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(DataManager.shared)
    }
}
