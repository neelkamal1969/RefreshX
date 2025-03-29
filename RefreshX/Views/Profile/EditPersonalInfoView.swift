//
//  EditPersonalInfoView.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//
import SwiftUI

struct EditPersonalInfoView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    @State private var name: String
    @State private var dateOfBirth: Date
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    
    // Validation states
    @State private var nameIsValid = true
    @State private var ageIsValid = true
    
    // Initialize the state from the user
    init(user: User) {
        self.user = user
        _name = State(initialValue: user.name)
        _dateOfBirth = State(initialValue: user.dateOfBirth)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Full Name", text: $name)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .onChange(of: name) { oldValue, newValue in
                                validateName()
                            }
                        
                        if !nameIsValid {
                            Text("Name must be at least 3 characters")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        DatePicker("Date of Birth", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                            .onChange(of: dateOfBirth) { oldValue, newValue in
                                validateAge()
                            }
                        
                        if !ageIsValid {
                            Text("Please enter a valid date of birth")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(user.email)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                } footer: {
                    Text("Email cannot be changed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveChanges) {
                        Text("Save")
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            validateName()
            validateAge()
        }
    }
    
    private var isFormValid: Bool {
        nameIsValid && ageIsValid
    }
    
    private func validateName() {
        nameIsValid = !name.isEmpty && name.count >= 3
    }
    
    private func validateAge() {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        ageIsValid = (ageComponents.year ?? 0) >= 3
    }
    
    private func saveChanges() {
        guard isFormValid else {
            errorMessage = "Please ensure all fields are valid"
            showAlert = true
            return
        }
        
        // Set loading state but don't show overlay
        isLoading = true
        
        do {
            // Update user profile directly
            try dataManager.updateUserProfile(name: name, dateOfBirth: dateOfBirth)
            
            // Dismiss immediately
            dismiss()
            
        } catch {
            // Handle validation errors
            isLoading = false
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }
}
