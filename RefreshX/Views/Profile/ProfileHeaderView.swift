
//  ProfileHeaderView.swift
//  RefreshX
//
//  Created by student-2 on 29/03/25.
//
import SwiftUI

struct ProfileHeaderView: View {
    let user: User
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showImageSource = false
    @State private var inputImage: UIImage?
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .shadow(radius: 3)
                
                if let profileImageName = user.profileImageName,
                   let uiImage = loadProfileImage(named: profileImageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                }
                
                // Edit button
                ZStack {
                    Circle()
                        .fill(Color("AccentColor"))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .offset(x: 35, y: 35)
                .onTapGesture {
                    showImageSource = true
                }
            }
            .padding(.top, 20)
            
            // User name
            Text(user.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            // User email
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .actionSheet(isPresented: $showImageSource) {
            ActionSheet(
                title: Text("Change Profile Picture"),
                message: Text("Choose a photo source"),
                buttons: [
                    .default(Text("Take Photo")) {
                        showCamera = true
                    },
                    .default(Text("Choose From Library")) {
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showCamera) {
            CameraImagePicker(image: $inputImage)
                .ignoresSafeArea()
        }
        .onChange(of: inputImage) { oldValue,newImage in
            if let newImage = newImage {
                uploadProfileImage(newImage)
            }
        }
    }
    
    private func loadProfileImage(named: String) -> UIImage? {
        // First try to load from asset catalog
        if let uiImage = UIImage(named: named) {
            return uiImage
        }
        
        // Try to load from documents directory if not in asset catalog
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(named)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        
        return nil
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        // Save the image to documents directory with unique filename
        if dataManager.saveProfileImage(image, for: user.id) != nil {
            // Update UI with new image
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Trigger UI refresh by forcing a redraw
                dataManager.objectWillChange.send()
            }
        }
        
        // Reset the input image
        self.inputImage = nil
    }
}
