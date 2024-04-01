//
//  HomePageView.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import SwiftUI

struct HomePageView: View {
    @State private var blogPosts = [BlogPost]()

    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(blogPosts) { blog in
                        BlogPostView(blog: blog)
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("发现", displayMode: .inline)
            .onAppear {
                BlogService.fetchBlogs { blogs in
                    self.blogPosts = blogs
                }
            }
        }
    }
}

struct BlogPostView: View {
    let blog: BlogPost

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: blog.imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable() // Displays the loaded image.
                } else if phase.error != nil {
                    Color.red // Indicates an error.
                } else {
                    ProgressView() // Acts as a placeholder.
                }
            }
            .aspectRatio(1, contentMode: .fit) // Adjust the aspect ratio accordingly
            
            VStack(alignment: .leading, spacing: 8) {
                Text(blog.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(blog.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
