//
//  OTPVerificationView.swift
//  RefreshX
//
//  Created by student-2 on 26/03/25.
//

import SwiftUI

struct OTPVerificationView: View {
    let email: String
    var onBackToForgotPassword: () -> Void
    var onVerificationSuccess: (String) -> Void
    var onVerificationError: (String) -> Void
    
    @State private var otpFields: [String] = Array(repeating: "", count: 6)
    @State private var isLoading = false
    @State private var rotationAngle: Double = 0
    @State private var activeFieldIndex = 0
    @State private var remainingTime = 60
    @State private var isResending = false
    @State private var timer: Timer?
    
    private let correctOTP = "123456"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Email")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(Color("PrimaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("We've sent a 6-digit code to\n\(email)")
                .font(.system(size: 16))
                .foregroundColor(Color("SecondaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // OTP input fields
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    OTPTextField(
                        text: $otpFields[index],
                        isFirstResponder: activeFieldIndex == index
                    )
                    .onChange(of: otpFields[index]) { newValue in
                        if newValue.count == 1 && index < 5 {
                            activeFieldIndex = index + 1
                        }
                    }
                }
            }
            
            // Countdown timer / Resend button
            HStack {
                if remainingTime > 0 {
                    Text("Resend code in \(timeFormatted(remainingTime))")
                        .font(.system(size: 14))
                        .foregroundColor(Color("SecondaryText"))
                } else {
                    Button(action: resendCode) {
                        ZStack {
                            Text("Resend Code")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("AccentColor"))
                                .opacity(isResending ? 0 : 1)
                            
                            if isResending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color("AccentColor")))
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isResending)
                }
                Spacer()
            }
            
            // Verify button
            Button(action: verifyOTP) {
                ZStack {
                    Text("Verify")
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
            
            // Back button
            Button(action: onBackToForgotPassword) {
                HStack {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14))
                    Text("Back")
                        .font(.system(size: 16))
                }
                .foregroundColor(Color("AccentColor"))
            }
            .padding(.top, 20)
        }
        .onAppear(perform: startTimer)
        .onDisappear { timer?.invalidate() }
    }
    
    private var isFormValid: Bool {
        !otpFields.contains(where: { $0.isEmpty })
    }
    
    private func startTimer() {
        timer?.invalidate()
        remainingTime = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    private func timeFormatted(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secondsRemaining = seconds % 60
        return String(format: "%d:%02d", minutes, secondsRemaining)
    }
    
    private func resendCode() {
        isResending = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isResending = false
            startTimer()
        }
    }
    
    private func verifyOTP() {
        let enteredOTP = otpFields.joined()
        isLoading = true
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Simulate backend verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            rotationAngle = 0
            
            if enteredOTP == correctOTP {
                onVerificationSuccess(enteredOTP)
            } else {
                onVerificationError("Invalid verification code")
            }
        }
    }
}

struct OTPTextField: View {
    @Binding var text: String
    var isFirstResponder: Bool
    
    @State private var isFocused = false
    @FocusState private var fieldFocus: Bool
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .focused($fieldFocus)
            .multilineTextAlignment(.center)
            .frame(width: 45, height: 55)
            .background(Color("FieldBackground"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color("AccentColor") : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .onChange(of: isFirstResponder) { if $0 { fieldFocus = true } }
            .onChange(of: fieldFocus) { isFocused = $0 }
            .onChange(of: text) { if $0.count > 1 { text = String($0.prefix(1)) } }
            .onAppear { if isFirstResponder { fieldFocus = true } }
    }
}
