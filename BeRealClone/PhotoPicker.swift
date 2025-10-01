//
//  PhotoPicker.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import SwiftUI
import PhotosUI
import ParseSwift
import CoreLocation

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    @State private var isUploading = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSourcePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var location: CLLocation?
    @State private var locationString: String?
    @StateObject private var locationManager = LocationManager()
    
    var onPostCreated: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Image preview
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 300)
                        .clipped()
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    // Placeholder
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No photo selected")
                            .foregroundColor(.secondary)
                        
                        Button("Select Photo") {
                            showSourcePicker = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Location display
                if let locationStr = locationString {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text(locationStr)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                // Caption input
                TextField("Write a caption...", text: $caption)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .frame(height: 40)
                
                Spacer()
                
                // Post button
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
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Choose Photo Source", isPresented: $showSourcePicker) {
                Button("Camera") {
                    showCamera = true
                }
                Button("Photo Library") {
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showCamera) {
                CameraView(selectedImage: $selectedImage, location: $location)
                    .onDisappear {
                        if selectedImage != nil {
                            requestLocation()
                        }
                    }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil {
                            requestLocation()
                        }
                    }
            }
            .alert("Post Status", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        onPostCreated?()
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // PART 2: Request location after image selection
    private func requestLocation() {
        locationManager.requestLocation { loc in
            self.location = loc
            if let loc = loc {
                reverseGeocode(location: loc)
            }
        }
    }
    
    // PART 2: Convert coordinates to readable address
    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                var components: [String] = []
                
                if let locality = placemark.locality {
                    components.append(locality)
                }
                if let administrativeArea = placemark.administrativeArea {
                    components.append(administrativeArea)
                }
                if let country = placemark.country {
                    components.append(country)
                }
                
                locationString = components.isEmpty ? "Unknown Location" : components.joined(separator: ", ")
            }
        }
    }
    
    // Upload post with WORKING file upload solution
    func uploadPost() {
        guard let selectedImage = selectedImage else { return }
        
        isUploading = true
        
        // Resize image to reduce file size (THIS IS WHAT MADE IT WORK!)
        let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 800, height: 800))
        
        // Convert UIImage to Data with lower compression (0.3 quality)
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.3) else {
            showError("Failed to process image")
            return
        }
        
        // Create Parse file with simple name (UUID + .jpg)
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
    
    // Helper function to resize image (THIS IS KEY!)
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
        var post = Post()
        post.caption = caption.isEmpty ? nil : caption
        post.imageFile = imageFile
        post.user = AppUser.current
        
        // PART 2: Add location data
        if let location = location {
            post.latitude = location.coordinate.latitude
            post.longitude = location.coordinate.longitude
            post.location = locationString
        }
        
        post.save { result in
            DispatchQueue.main.async {
                self.isUploading = false
                
                switch result {
                case .success(let savedPost):
                    print("✅ Post uploaded successfully: \(savedPost.objectId ?? "")")
                    
                    // PART 2: Update user's last post date
                    self.updateUserLastPostDate()
                    
                    // PART 2: Schedule notification
                    NotificationManager.shared.scheduleNotification()
                    
                    self.alertMessage = "Post shared successfully!"
                    self.showingAlert = true
                    
                case .failure(let error):
                    print("❌ Error uploading post: \(error.localizedDescription)")
                    self.showError("Failed to save post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // PART 2: Update user's lastPostDate
    private func updateUserLastPostDate() {
        guard var user = AppUser.current else { return }
        
        user.lastPostDate = Date()
        user.save { result in
            switch result {
            case .success(let updatedUser):
                print("✅ Updated user lastPostDate")
            case .failure(let error):
                print("❌ Error updating user: \(error)")
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

// Camera View
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var location: CLLocation?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraDevice = .rear // PART 2: Use back camera as required
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

// Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var completion: ((CLLocation?) -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion
        
        if CLLocationManager.locationServicesEnabled() {
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        } else {
            completion(nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completion?(locations.first)
        completion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error)")
        completion?(nil)
        completion = nil
    }
}
