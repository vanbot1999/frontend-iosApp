//
//  ContentView.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LoginView()
                .tabItem {
                    Label("登录", systemImage: "person.fill")
                }
            RegisterView()
                .tabItem {
                    Label("注册", systemImage: "person.badge.plus")
                }
            HomePageView()
                .tabItem {
                    Label("主页", systemImage: "house.fill")
                }
            
            ShoppingPageView()
                .tabItem {
                    Label("商城", systemImage: "cart.fill")
                }
            
            PublishPageView()
                .tabItem {
                    Label("发布", systemImage: "plus.square.fill")
                }

            MessagesPageView()
                .tabItem {
                    Label("消息", systemImage: "message.fill")
                }

            ProfilePageView()
                .tabItem {
                    Label("我", systemImage: "person.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
