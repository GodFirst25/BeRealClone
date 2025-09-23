//
//  MainFeedView.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import SwiftUI

struct MainFeedView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var posts: [Post] = []
    @State private var showingCreatePost = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with welcome and logout
                HStack {
                    VStack(alignment: .leading) {
                        Text("📸 BeReal Clone")
                            .font(.title2)
                            .bold()
                        
                        if let currentUser = AppUser.current {
                            Text("Welcome, \(currentUser.username ?? "User")!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Logout") {
                        logout()
                    }
                    .foregroundColor(.red)
                }
                .padding()
                
                // Feed content
                if isLoading {
                    Spacer()
                    ProgressView("Loading posts...")
                    Spacer()
                } else if posts.isEmpty {
                    // Empty state
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No posts yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Be the first to share a moment!")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("Create First Post") {
                            showingCreatePost = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    Spacer()
                } else {
                    // Posts feed
                    FeedView(posts: $posts)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                fetchPosts()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView(onPostCreated: {
                    fetchPosts() // Refresh feed after new post
                })
            }
        }
    }
    
    // Fetch posts from Back4App
    func fetchPosts() {
        isLoading = true
        
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")]) // Show newest posts first
            .limit(20) // Limit to 20 most recent posts
        
        query.find { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedPosts):
                    self.posts = fetchedPosts
                    print("✅ Fetched \(fetchedPosts.count) posts")
                case .failure(let error):
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func logout() {
        AppUser.logout { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Logged out")
                    self.isLoggedIn = false
                case .failure(let error):
                    print("❌ Logout error: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct FeedView: View {
    @Binding var posts: [Post]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(posts, id: \.objectId) { post in
                    PostCell(post: post)
                }
            }
            .padding()
        }
    }
}

struct PostCell: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info header
            HStack {
                // Profile picture placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(post.user?.username?.first?.uppercased() ?? "?"))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.user?.username ?? "Anonymous")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let createdAt = post.createdAt {
                        Text(timeAgoString(from: createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Post image
            if let imageFile = post.imageFile, let imageURL = imageFile.url {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(
                                ProgressView()
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 400)
                            .clipped()
                            .cornerRadius(12)
                    case .failure(_):
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                    Text("Failed to load image")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                            .cornerRadius(12)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // Caption
            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    // Helper function to format time ago
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    MainFeedView()
}
