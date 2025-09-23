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
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📸 Welcome to BeReal Clone")
                .font(.title)
                .bold()
            
            Button(action: {
                AppUser.logout { result in
                    switch result {
                    case .success:
                        print("✅ Logged out")
                    case .failure(let error):
                        print("❌ Logout error: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear() {
            fetchPosts()
        }
    }
    
    // Fetch posts from Back4App
    func fetchPosts() {
        let query = Post.query()
            .include("user")
        query.find { result in
            switch result {
            case .success(let fetchedPosts):
                self.posts = fetchedPosts
            case .failure(let error):
                print("Error fetching posts: \(error.localizedDescription)")
            }
        }
    }
}

struct FeedView: View {
    @Binding var posts: [Post]

    var body: some View {
        List(posts) { post in
            VStack(alignment: .leading) {
                // Show user info (username)
                if let user = post.user {
                    Text(user.username ?? "Anonymous")
                        .font(.headline)
                }
                
                // Display image if available
                if let imageFile = post.imageFile, let imageURL = imageFile.url {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                // Caption
                Text(post.caption ?? "No caption")
                    .padding(.top, 8)
            }
            .padding()
        }
        .onAppear {
            // You can call fetchPosts here if you want to fetch posts when the feed loads.
        }
    }
}

#Preview {
    MainFeedView()
}
