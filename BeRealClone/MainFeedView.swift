//
//  MainFeedView.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import SwiftUI
import ParseSwift

struct MainFeedView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var posts: [Post] = []
    @State private var showingCreatePost = false
    @State private var isLoading = false
    @State private var currentUser: AppUser?
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("📸 BeReal Clone")
                            .font(.title2)
                            .bold()
                        
                        if let user = currentUser {
                            Text("Welcome, \(user.username ?? "User")!")
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
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text(currentUser?.lastPostDate == nil ? "No posts yet" : "No visible posts")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text(currentUser?.lastPostDate == nil ? "Post a photo to see others' posts!" : "Be the first to share a moment!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Create Post") {
                            showingCreatePost = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    Spacer()
                } else {
                    FeedView(posts: $posts, currentUser: currentUser)
                }
            }
            .navigationBarHidden(false)
            .onAppear {
                loadCurrentUser()
                fetchPosts()
                NotificationManager.shared.requestPermission()
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
                    fetchPosts()
                    loadCurrentUser()
                })
            }
        }
    }
    
    func loadCurrentUser() {
        currentUser = AppUser.current
    }
    
    func fetchPosts() {
        isLoading = true
        
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .limit(10)
        
        query.find { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let fetchedPosts):
                    self.posts = filterVisiblePosts(fetchedPosts)
                    print("✅ Fetched \(fetchedPosts.count) posts, showing \(self.posts.count)")
                case .failure(let error):
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func filterVisiblePosts(_ posts: [Post]) -> [Post] {
        guard let currentUser = currentUser else {
            return []
        }
        
        guard let userLastPost = currentUser.lastPostDate else {
            return []
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        return posts.filter { post in
            if post.user?.objectId == currentUser.objectId {
                return true
            }
            
            guard let postDate = post.createdAt else { return false }
            
            let hoursSincePost = calendar.dateComponents([.hour], from: postDate, to: now).hour ?? 0
            let hoursSinceUserPost = calendar.dateComponents([.hour], from: userLastPost, to: now).hour ?? 0
            
            return hoursSincePost <= 24 && hoursSinceUserPost <= 24
        }
    }
    
    private func logout() {
        NotificationManager.shared.cancelAllNotifications()
        
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
    let currentUser: AppUser?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(posts, id: \.objectId) { post in
                    NavigationLink(destination: CommentsView(post: post)) {
                        PostCell(post: post, currentUser: currentUser)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

struct PostCell: View {
    let post: Post
    let currentUser: AppUser?
    
    private var shouldBlur: Bool {
        guard let currentUser = currentUser, post.user?.objectId != currentUser.objectId else {
            return false
        }
        
        guard let userLastPost = currentUser.lastPostDate else {
            return true
        }
        
        let calendar = Calendar.current
        let now = Date()
        let hoursSinceUserPost = calendar.dateComponents([.hour], from: userLastPost, to: now).hour ?? 0
        
        return hoursSinceUserPost > 24
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
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
            
            if let location = post.location {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let imageFile = post.imageFile, let imageURL = imageFile.url {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 400)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(
                                shouldBlur ?
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "lock.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(.white)
                                            Text("Post to see this")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                    )
                                : nil
                            )
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
            
            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            HStack {
                Image(systemName: "bubble.right")
                    .font(.caption)
                Text("View comments")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: date, to: now)
        
        if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}

#Preview {
    MainFeedView()
}
