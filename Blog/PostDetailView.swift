//
//  PostDetailView.swift
//  Blog
//
//  Created by wyf on 03/04/2024.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var userAuth: UserAuth
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    @State private var newComment: String = ""
    @State private var comments: [Comment] = [] // 添加一个State属性来存储评论
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 帖子图片
                AsyncImage(url: URL(string: post.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .padding(.top, 16)
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .padding(.top, 16)
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView()
                            .padding(.top, 16)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // 帖子标题
                Text(post.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                // 帖子内容
                Text(post.content)
                    .font(.body)
                    .lineLimit(nil) // 取消行数限制，显示所有文本内容
                
                // 帖子作者和日期
                HStack {
                    Text("作者：\(post.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("日期：\(formatDate(post.date))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                // 删除按钮，只有帖子作者可以看到并操作
                if post.author == userAuth.username {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Text("删除帖子")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("确认删除"),
                            message: Text("您确定要删除此帖子吗？"),
                            primaryButton: .destructive(Text("删除"), action: deletePost),
                            secondaryButton: .cancel(Text("取消"))
                        )
                    }
                }
                Text("评论")
                    .font(.headline)
                
                // 添加新评论
                HStack {
                    TextField("写下你的评论...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !newComment.isEmpty {  // 当newComment不为空时，显示发送按钮
                        Button(action: addComment) {
                            Text("发送")
                                .fontWeight(.semibold)
                                .frame(width: 60, height: 30)  // 设置按钮的大小为方形
                                .background(Color.blue)  // 设置按钮背景颜色
                                .foregroundColor(.white)  // 设置按钮文字颜色
                                .cornerRadius(5)  // 设置按钮圆角
                        }
                    }
                }
                
                // 评论列表
                ForEach(comments) { comment in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(comment.content)
                                .font(.body)
                            Text("— \(comment.author), \(formatDate(comment.date))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer() // 占据剩余的水平空间
                        
                        if comment.author == userAuth.username {
                            Button(action: {
                                // 删除评论
                                deleteCommentAlert(comment)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.bottom, 5)
                }
            }
            .padding()
        }
        .navigationBarTitle("帖子详情", displayMode: .inline)
        .onAppear {
            loadPostDetails()
        }
    }
    
    // 删除评论函数
    func deleteComment(_ comment: Comment) {
        // 检查评论作者是否与当前登录用户的用户名匹配
        guard comment.author == userAuth.username else {
            // 如果不匹配，不执行删除操作
            return
        }
        
        // 执行删除操作
        guard let url = URL(string: "http://localhost:3000/api/posts/\(post.id)/comments/\(comment.id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting comment: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // 成功删除评论后更新UI
                    DispatchQueue.main.async {
                        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                            comments.remove(at: index)
                        }
                    }
                } else {
                    // 处理删除失败的情况
                }
            }
        }.resume()
    }
    
    func loadPostDetails() {
        guard let url = URL(string: "http://localhost:3000/api/posts/\(post.id)/details") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading post details: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Unexpected response status code: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedPost = try JSONDecoder().decode(Post.self, from: data)
                DispatchQueue.main.async {
                    self.comments = decodedPost.comments
                }
            } catch {
                print("Error decoding post details: \(error)")
            }
        }.resume()
    }
    
    // 删除评论的提示框
    func deleteCommentAlert(_ comment: Comment) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let alert = UIAlertController(title: "确认删除", message: "您确定要删除此评论吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { _ in
            deleteComment(comment)
        }))
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func addComment() {
        guard let url = URL(string: "http://localhost:3000/api/posts/\(post.id)/comments") else { return }
        
        guard let userName = userAuth.username else {
            print("Username is nil")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let commentData = CommentData(content: newComment, author: userName)
        guard let encodedComment = try? JSONEncoder().encode(commentData) else { return }
        
        request.httpBody = encodedComment
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error posting comment: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                print("Response body: \(responseBody)")
            }
            
            // 成功添加评论后的操作，例如更新UI或评论列表
            DispatchQueue.main.async {
                self.newComment = "" // 清空评论输入框
                loadPostDetails() // 重新加载帖子详情和评论，以获取最新数据
            }
            
        }.resume()
    }
    
    struct CommentData: Encodable {
        let content: String
        let author: String
    }
    
    // 删除帖子的函数
    func deletePost() {
        BlogService.deletePost(postId: post.id) { success in
            if success {
                // 删除成功后返回上一页
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                // 处理删除失败的情况
            }
        }
    }
    
    // 格式化日期
    private func formatDate(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let formattedDate = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return dateFormatter.string(from: formattedDate)
        } else {
            return ""
        }
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePost = Post(id: "1", title: "示例帖子", content: "这是一个示例帖子的内容。", imageUrl: "https://example.com/image.jpg", date: "2024-04-03T12:30:00.000Z", author: "示例作者", comments: [])
        
        return PostDetailView(post: samplePost).environmentObject(UserAuth())
    }
}
