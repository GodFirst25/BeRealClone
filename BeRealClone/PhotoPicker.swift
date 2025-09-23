//
//  PhotoPicker.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import SwiftUI
import ParseSwift

struct CreatePostView: View {
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    @State private var isImagePickerPresented = false
    @State private var isUploading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) var dismiss
    var onPostCreated: (() -> Void)?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image selection area
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(12)
                        .onTapGesture {
                            isImagePickerPresented.toggle()
                        }
                } else {
                    Button("Select Photo") {
                        isImagePickerPresented.toggle()
                    }
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                }
                
                // Caption field
                TextField("Write a caption...", text: $caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                // Upload button
                Button(action: uploadPost) {
                    HStack {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isUploading ? "Posting..." : "Upload Post")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedImage != nil && !isUploading ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(selectedImage == nil || isUploading)
            }
            .padding()
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert("Post Status", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // Upload post to Back4App
    func uploadPost() {
        guard let selectedImage = selectedImage else { return }
        
        isUploading = true
        
        // Resize image to reduce file size
        let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 800, height: 800))
        
        // Convert UIImage to Data with lower compression
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.3) else {
            showError("Failed to process image")
            return
        }
        
        // Create Parse file with simple name
        let fileName = UUID().uuidString + ".jpg"
        let parseFile = ParseFile(name: fileName, data: imageData)
        
        // First upload the image file
        parseFile.save { result in
            switch result {
            case .success(let savedFile):
                self.savePost(with: savedFile)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showError("Failed to upload image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Helper function to resize image
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    private func savePost(with imageFile: ParseFile) {
        // Create a new Post object
        var post = Post()
        post.caption = caption.isEmpty ? nil : caption
        post.imageFile = imageFile
        post.user = AppUser.current // Use current logged-in user

        // Save post to Back4App
        post.save { result in
            DispatchQueue.main.async {
                self.isUploading = false
                
                switch result {
                case .success(let savedPost):
                    print("✅ Post uploaded successfully: \(savedPost.objectId ?? "")")
                    self.alertMessage = "Post shared successfully!"
                    self.showingAlert = true
                    self.onPostCreated?()
                    
                case .failure(let error):
                    print("❌ Error uploading post: \(error.localizedDescription)")
                    self.showError("Failed to save post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.isUploading = false
            self.alertMessage = message
            self.showingAlert = true
        }
    }
}

struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ImagePickerController(selectedImage: $selectedImage)
                .navigationTitle("Select Photo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct ImagePickerController: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var selectedImage: UIImage?
        
        init(selectedImage: Binding<UIImage?>) {
            _selectedImage = selectedImage
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Use edited image if available, otherwise use original
            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                selectedImage = originalImage
            }
            
            // Dismiss the picker
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
