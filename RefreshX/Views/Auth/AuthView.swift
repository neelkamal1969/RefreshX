////
////  AuthView.swift
////  RefreshX
////
////  Created by student-2 on 25/03/25.
////

import SwiftUI

struct AuthView: View {
    @State private var authState: AuthState = .login
    @State private var alertItem: AlertItem?
    @State private var showAlert = false
    
    @EnvironmentObject var dataManager: DataManager
    
    enum AuthState {
        case login
        case signup
        case forgotPassword
        case otpVerification(email: String)
        case resetPassword(email: String, otp: String)
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Removed app image and name, using padding for top spacing
                VStack(spacing: 20) {
                    switch authState {
                    case .login:
                        LoginView(
                            onSignUp: { authState = .signup },
                            onForgotPassword: { authState = .forgotPassword },
                            onLoginSuccess: { user in
                                dataManager.setCurrentUser(user)
                            },
                            onLoginError: { error in
                                alertItem = AlertItem(title: "Login Failed", message: error, buttonText: "OK")
                                showAlert = true
                            }
                        )
                    case .signup:
                        SignUpView(
                            onBackToLogin: { authState = .login },
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
                    case .forgotPassword:
                        ForgotPasswordView(
                            onBackToLogin: { authState = .login },
                            onSendCodeSuccess: { email in
                                authState = .otpVerification(email: email)
                            },
                            onSendCodeError: { error in
                                alertItem = AlertItem(title: "Error", message: error, buttonText: "OK")
                                showAlert = true
                            }
                        )
                    case .otpVerification(let email):
                        OTPVerificationView(
                            email: email,
                            onBackToForgotPassword: { authState = .forgotPassword },
                            onVerificationSuccess: { otp in
                                authState = .resetPassword(email: email, otp: otp)
                            },
                            onVerificationError: { error in
                                alertItem = AlertItem(title: "Verification Failed", message: error, buttonText: "OK")
                                showAlert = true
                            }
                        )
                    case .resetPassword(let email, let otp):
                        ResetPasswordView(
                            email: email,
                            otp: otp,
                            onBackToLogin: { authState = .login },
                            onResetSuccess: {
                                alertItem = AlertItem(title: "Success", message: "Password reset successfully!", buttonText: "Login")
                                showAlert = true
                                authState = .login
                            },
                            onResetError: { error in
                                alertItem = AlertItem(title: "Reset Failed", message: error, buttonText: "OK")
                                showAlert = true
                            }
                        )
                    }
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
