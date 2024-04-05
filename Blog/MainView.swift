//
//  MainView.swift
//  Blog
//
//  Created by wyf on 02/04/2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userAuth: UserAuth // 获取 UserAuth 环境对象

    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Label("主页", systemImage: "house.fill")
                }
            
//            ShoppingPageView()
//                .tabItem {
//                    Label("商城", systemImage: "cart.fill")
//                }
            
            PublishPageView()
                .tabItem {
                    Label("发布", systemImage: "plus.square.fill")
                }

//            MessagesPageView()
//                .tabItem {
//                    Label("消息", systemImage: "message.fill")
//                }

            ProfilePageView()
                .tabItem {
                    Label("我", systemImage: "person.fill")
                }
        }
    }
}
