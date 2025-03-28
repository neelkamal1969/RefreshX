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
    
    @State private var otp = "" // Single string for OTP
    @State private var isLoading = false
    @State private var rotationAngle: Double = 0
    @State private var remainingTime = 60
    @State private var isResending = false
    @State private var timer: Timer?
    @State private var showResendPrompt = false // For "OTP sent" message
    
    private let correctOTP = "123456" // For demo; replace with backend
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Verify Your Email")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(Color("PrimaryText"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("We've sent a 6-digit code to")
                    .font(.system(size: 16))
                    .foregroundColor(Color("SecondaryText"))
                
                Text(email)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("PrimaryText"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // OTP input
            VStack(spacing: 16) {
                OTPInputField(otp: $otp)
                
                // Resend timer or button
                HStack {
                    if remainingTime > 0 {
                        Text("Resend code in \(timeFormatted(remainingTime))")
                            .font(.system(size: 14))
                            .foregroundColor(Color("SecondaryText"))
                    } else {
                        Button(action: resendCode) {
                            Text("Resend Code")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(isResending ? .gray : Color("AccentColor"))
                        }
                        .disabled(isResending)
                    }
                    Spacer()
                }
            }
            
            // Verify button
            Button(action: verifyOTP) {
                Text("Verify")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isFormValid ? Color("AccentColor") : Color("AccentColor").opacity(0.5))
                    .cornerRadius(12)
                    .overlay(
                        Group {
                            if isLoading {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(rotationAngle))
                            }
                        }
                    )
            }
            .disabled(!isFormValid || isLoading)
            .padding(.top, 12)
            
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
            
            Spacer()
        }
        .padding(.horizontal, 16) // Match the padding from AuthView
        .onAppear(perform: startTimer)
        .onDisappear { timer?.invalidate() }
        .overlay(
            Group {
                if showResendPrompt {
                    Text("OTP sent, check your email!")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("AccentColor"))
                        .padding()
                        .background(Color("FieldBackground"))
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .transition(.opacity)
                        .position(x: UIScreen.main.bounds.width / 2, y: 100) // Top center
                }
            }
        )
    }
    
    private var isFormValid: Bool {
        otp.count == 6
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
        return String(format: "%01d:%02d", minutes, secondsRemaining)
    }
    
    private func resendCode() {
        isResending = true
        otp = "" // Clear OTP field
        
        // Simulate resending OTP (replace with AuthService call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isResending = false
            startTimer()
            withAnimation {
                showResendPrompt = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showResendPrompt = false
                }
            }
        }
    }
    
    private func verifyOTP() {
        isLoading = true
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Simulate verification (replace with AuthService.verifyOTP)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            rotationAngle = 0
            
            if otp == correctOTP {
                onVerificationSuccess(otp)
            } else {
                onVerificationError("Invalid verification code. Please try again.")
                otp = "" // Clear OTP on failure
            }
        }
    }
}

// Custom OTP Input Field
struct OTPInputField: View {
    @Binding var otp: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // Hidden TextField for input
            TextField("", text: $otp)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .opacity(0) // Hide the actual TextField
                .focused($isFocused)
                .onChange(of: otp) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    otp = String(filtered.prefix(6))
                    if otp.count == 6 {
                        isFocused = false // Dismiss keyboard when complete
                    }
                }
            
            // Visual representation of OTP digits
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("FieldBackground"))
                            .frame(width: 45, height: 55)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isFocused ? Color("AccentColor") : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        if index < otp.count {
                            Text(String(otp[otp.index(otp.startIndex, offsetBy: index)]))
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color("PrimaryText"))
                        }
                    }
                }
            }
        }
        .onTapGesture {
            isFocused = true // Focus the hidden TextField when tapping the visual boxes
        }
    }
}

#Preview {
    OTPVerificationView(
        email: "user@example.com",
        onBackToForgotPassword: {},
        onVerificationSuccess: { _ in },
        onVerificationError: { _ in }
    )
    .padding()
}
