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
        BlogService.fetchBlogs(excludeAuthor: userAuth.username) { fetchedPosts in
            // 按发布时间倒序排序
            var decodedPosts = fetchedPosts.sorted { $0.date > $1.date }
            
            // 处理图片URL
            decodedPosts = decodedPosts.map { post -> Post in
                var updatedPost = post
                let fullImageUrl = "http://localhost:3000/\(post.imageUrl)" // 将相对路径转换为完整的URL
                updatedPost.imageUrl = fullImageUrl
                return updatedPost
            }
            
            DispatchQueue.main.async {
                self.posts = decodedPosts
            }
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView().environmentObject(UserAuth())
    }
}
