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
            }
            .padding()
        }
        .navigationBarTitle("帖子详情", displayMode: .inline)
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
        let samplePost = Post(id: "1", title: "示例帖子", content: "这是一个示例帖子的内容。", imageUrl: "https://example.com/image.jpg", date: "2024-04-03T12:30:00.000Z", author: "示例作者")
        return PostDetailView(post: samplePost).environmentObject(UserAuth())
    }
}
