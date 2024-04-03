//
//  ProfilePageView.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import SwiftUI

struct ProfilePageView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var posts: [Post] = []
    @State private var showingLogoutAlert = false
    
    // 使用两列布局，每列内容独立排列
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if let username = userAuth.username {
                Text("\(username)")
                    .padding()
                
                // 使用 LazyVGrid 来实现瀑布流布局
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(posts) { post in
                            PostView(post: post)
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    loadPosts(for: username)
                }
            } else {
                Text("未能获取到用户名")
                    .padding()
            }
            
            logoutButton
        }
        .alert(isPresented: $showingLogoutAlert) {
            Alert(
                title: Text("确认登出"),
                message: Text("您确定要登出吗？"),
                primaryButton: .destructive(Text("确认"), action: logout),
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
    
    var logoutButton: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            Text("登出")
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(40)
        }
        .padding()
    }
    
    func logout() {
        userAuth.isLoggedIn = false
        userAuth.username = nil
    }
    func loadPosts(for username: String) {
        guard let url = URL(string: "http://localhost:3000/api/posts/\(username)") else {
            print("无效URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("请求错误: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("无效的响应")
                    return
                }
                
                guard let data = data else {
                    print("无数据返回")
                    return
                }
                
                do {
                    var decodedPosts = try JSONDecoder().decode([Post].self, from: data)
                    // 按发布时间倒序排序
                    decodedPosts.sort { $0.date > $1.date }
                    // 处理图片URL
                    let updatedPosts = decodedPosts.map { post -> Post in
                        var updatedPost = post
                        let fullImageUrl = "http://localhost:3000/\(post.imageUrl)" // 将相对路径转换为完整的URL
                        updatedPost.imageUrl = fullImageUrl
                        return updatedPost
                    }
                    self.posts = updatedPosts
                } catch {
                    print("解码错误: \(error)")
                }
            }
        }.resume()
    }
}

// 独立的 PostView 用于展示每个帖子
struct PostView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 用自然高度的 AsyncImage
            AsyncImage(url: URL(string: post.imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable() // 允许图片尺寸调整
                        .scaledToFit() // 图片会缩放以适应视图的宽度
                } else if phase.error != nil {
                    Color.red // 出错显示红色区域
                } else {
                    ProgressView() // 正在加载时显示加载指示器
                }
            }
            
            Text(post.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(post.author)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .background(Color.white)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding(.bottom, 8) // 为每个帖子增加底部间隔
    }
}

struct ProfilePageView_Previews: PreviewProvider {
    static var previews: some View {
        let userAuth = UserAuth()
        userAuth.username = "预览用户名"
        return ProfilePageView().environmentObject(userAuth)
    }
}
