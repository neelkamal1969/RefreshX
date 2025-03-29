//
//  AppInfoSection.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//

import SwiftUI

struct AppInfoSection: View {
    @State private var showAboutSheet = false
    @State private var showPrivacySheet = false
    @State private var showContactSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text("App Information")
                .font(.headline)
                .foregroundColor(Color("PrimaryText"))
            
            Divider()
            
            // About
            Button(action: { showAboutSheet = true }) {
                InfoButtonRow(icon: "info.circle.fill", title: "About RefreshX")
            }
            
            // Privacy Policy
            Button(action: { showPrivacySheet = true }) {
                InfoButtonRow(icon: "lock.shield.fill", title: "Privacy Policy")
            }
            
            // Contact Support
            Button(action: { showContactSheet = true }) {
                InfoButtonRow(icon: "envelope.fill", title: "Contact Support")
            }
            
            // Version
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Color("AccentColor"))
                    .frame(width: 24)
                
                Text("Version")
                    .font(.subheadline)
                
                Spacer()
                
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .padding()
        .background(Color("FieldBackground"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showAboutSheet) {
            AboutAppView()
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showContactSheet) {
            ContactSupportView()
        }
    }
}

struct InfoButtonRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("AccentColor"))
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color("PrimaryText"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct AboutAppView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App logo
                    Image("appImage") // Replace with your actual app logo
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(24)
                        .padding(.top, 20)
                    
                    Text("RefreshX")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        AboutSection(
                            title: "Take Better Breaks",
                            content: "RefreshX helps you take healthier breaks from screen time with guided exercises for your eyes, back, and wrists."
                        )
                        
                        AboutSection(
                            title: "Track Your Progress",
                            content: "Monitor your daily and weekly progress, build streaks, and see the positive impact on your physical wellbeing."
                        )
                        
                        AboutSection(
                            title: "Learn Healthy Habits",
                            content: "Discover articles and tips to improve your workday health and reduce the negative impacts of prolonged screen use."
                        )
                    }
                    .padding()
                    .background(Color("FieldBackground"))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Text("© 2025 RefreshX Team")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationTitle("About RefreshX")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}

struct AboutSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Group {
                        PolicySection(
                            title: "Information We Collect",
                            content: "RefreshX collects basic profile information, exercise and break history, and app usage data to provide and improve our services."
                        )
                        
                        PolicySection(
                            title: "How We Use Your Information",
                            content: "We use your information to provide the app's core functionality, personalize your experience, and improve our services. We do not sell your personal information to third parties."
                        )
                        
                        PolicySection(
                            title: "Data Storage",
                            content: "Your data is stored securely using industry-standard encryption. You can request deletion of your account and associated data at any time."
                        )
                        
                        PolicySection(
                            title: "Permissions",
                            content: "RefreshX requests notification permissions to provide timely break reminders and updates. No other system permissions are required."
                        )
                        
                        PolicySection(
                            title: "Changes to This Policy",
                            content: "We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the app."
                        )
                        
                        PolicySection(
                            title: "Contact Us",
                            content: "If you have any questions about this privacy policy, please contact us at support@refreshx.app."
                        )
                    }
                    
                    Text("Last updated: March 25, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }
        }
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 10)
    }
}

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var showEmailAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    Button(action: {
                        openEmail()
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(Color("AccentColor"))
                            Text("support@refreshx.app")
                                .foregroundColor(Color("PrimaryText"))
                        }
                    }
                    
                    Button(action: {
                        callPhone()
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(Color("AccentColor"))
                            Text("+1 (555) 123-4567")
                                .foregroundColor(Color("PrimaryText"))
                        }
                    }
                }
                
                Section(header: Text("Send Message")) {
                    TextField("Subject", text: $subject)
                    
                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Describe your issue or question...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $message)
                            .frame(minHeight: 150)
                            .padding(.horizontal, -4)
                    }
                    
                    Button(action: {
                        sendEmail()
                    }) {
                        Text("Send Message")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .disabled(subject.isEmpty || message.isEmpty)
                }
                
                Section(header: Text("Help Center")) {
                    Link(destination: URL(string: "https://refreshx.app/help")!) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(Color("AccentColor"))
                            Text("Visit Help Center")
                                .foregroundColor(Color("PrimaryText"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Link(destination: URL(string: "https://refreshx.app/faq")!) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(Color("AccentColor"))
                            Text("Frequently Asked Questions")
                                .foregroundColor(Color("PrimaryText"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Done")
                    }
                }
            }
            .alert(isPresented: $showEmailAlert) {
                Alert(
                    title: Text("Email Not Configured"),
                    message: Text("Please set up an email account on your device or contact us at support@refreshx.app."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func openEmail() {
        let emailURL = URL(string: "mailto:support@refreshx.app")!
        if UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL)
        } else {
            showEmailAlert = true
        }
    }
    
    private func callPhone() {
        let phoneURL = URL(string: "tel:+15551234567")!
        if UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL)
        }
    }
    
    private func sendEmail() {
        guard !subject.isEmpty && !message.isEmpty else { return }
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let emailURL = URL(string: "mailto:support@refreshx.app?subject=\(encodedSubject)&body=\(encodedMessage)")!
        
        if UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL)
        } else {
            showEmailAlert = true
        }
    }
}

struct AppInfoSection_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoSection()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
