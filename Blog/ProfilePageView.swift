//
//  ProfilePageView.swift
//  Blog
//
//  Created by wyf on 01/04/2024.
//

import SwiftUI

struct ProfilePageView: View {
    @EnvironmentObject var userAuth: UserAuth // 通过环境对象获取 UserAuth 实例
    
    var body: some View {
        VStack {
            if let username = userAuth.username {
                Text("\(username)")
                    .padding()
            } else {
                Text("未能获取到用户名")
                    .padding()
            }
            
            Button(action: logout) {
                Text("登出")
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(40)
            }
            .padding()
        }
    }
    
    func logout() {
        userAuth.isLoggedIn = false
        userAuth.username = nil
    }
}

struct ProfilePageView_Previews: PreviewProvider {
    static var previews: some View {
        let userAuth = UserAuth()
        userAuth.username = "预览用户名"
        return ProfilePageView().environmentObject(userAuth)
    }
}
