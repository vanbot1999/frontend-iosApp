//
//  HomePageView.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var userAuth: UserAuth
    @State private var posts = [Post]() // 使用 Post 类型
    
    // 使用两列布局，每列内容独立排列
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostView(post: post) // 引用 PostView
                                .padding(8) // 添加点击区域
                                .background(Color.clear) // 清除背景色
                                .cornerRadius(8) // 圆角
                        }
                        .buttonStyle(PlainButtonStyle()) // 使用 PlainButtonStyle 隐藏默认样式
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("发现", displayMode: .inline)
            .onAppear {
                loadPosts()
            }
        }
    }
    
    func loadPosts() {
        print("当前用户登录状态: \(userAuth.isLoggedIn), 用户名: \(String(describing: userAuth.username))")
        guard let username = userAuth.username?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("用户名未设置")
            return
        }
        
        let urlString = "http://localhost:3000/api/posts?excludeAuthor=\(username)"
        
        guard let url = URL(string: urlString) else {
            print("无效的URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("请求失败: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("无法获取HTTP响应")
                return
            }
            print("HTTP状态码: \(httpResponse.statusCode)")
            guard let data = data else {
                print("没有接收到数据")
                return
            }
            print("接收到的原始数据: \(String(data: data, encoding: .utf8) ?? "无法解码")")
            
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
        }.resume()
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView().environmentObject(UserAuth())
    }
}
