//
//  ContentView.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var userAuth = UserAuth()
    @State private var activeView: ActiveView = .login

    var body: some View {
        VStack {
            if userAuth.isLoggedIn {
                MainView().environmentObject(userAuth) // 提供 UserAuth 环境对象
            } else {
                if activeView == .login {
                    LoginView(activeView: $activeView)
                } else {
                    RegisterView(activeView: $activeView)
                }
            }
        }
        .environmentObject(userAuth)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserAuth())
    }
}
