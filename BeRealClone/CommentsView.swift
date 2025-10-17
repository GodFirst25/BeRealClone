//
//  CommentsView.swift
//  BeRealClone
//
//  Created by olamide mercy oduntan on 10/1/25.
//


import SwiftUI
import ParseSwift

struct CommentsView: View {
    let post: Post
    
    @State private var comments: [Comment] = []
    @State private var newCommentText: String = ""
    @State private var isLoading = false
    @State private var isSending = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView("Loading comments...")
                Spacer()
            } else if comments.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No comments yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Be the first to comment!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(comments, id: \.objectId) { comment in
                                CommentCell(comment: comment)
                                    .id(comment.objectId)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: comments.count) { _ in
                        if let lastComment = comments.last {
                            withAnimation {
                                proxy.scrollTo(lastComment.objectId, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("Add a comment...", text: $newCommentText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
                
                Button(action: sendComment) {
                    if isSending {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                }
                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchComments()
        }
    }
    
    private func fetchComments() {
        isLoading = true
        
        do {
            let query = try Comment.query()
                .where("post" == post)
                .include("user")
                .order([.ascending("createdAt")])
            
            query.find { result in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    switch result {
                    case .success(let fetchedComments):
                        self.comments = fetchedComments
                        print("✅ Fetched \(fetchedComments.count) comments")
                    case .failure(let error):
                        print("❌ Error fetching comments: \(error)")
                    }
                }
            }
        } catch {
            print("❌ Error creating query: \(error)")
            isLoading = false
        }
    }
    
    private func sendComment() {
        let text = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        isSending = true
        
        var comment = Comment()
        comment.text = text
        comment.user = AppUser.current
        comment.post = post
        
        comment.save { result in
            DispatchQueue.main.async {
                isSending = false
                
                switch result {
                case .success:
                    newCommentText = ""
                    isTextFieldFocused = false
                    fetchComments()
                    print("✅ Comment posted")
                    
                case .failure(let error):
                    print("❌ Error posting comment: \(error)")
                }
            }
        }
    }
}

struct CommentCell: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(comment.user?.username?.first?.uppercased() ?? "?"))
                        .font(.caption)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.user?.username ?? "Anonymous")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if let createdAt = comment.createdAt {
                        Text(timeAgoString(from: createdAt))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(comment.text ?? "")
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: date, to: now)
        
        if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}
