//
//  UserAuth.swift
//  Blog
//  用户认证状态管理
//  Created by wyf on 02/04/2024.
//

import SwiftUI
import Combine

class UserAuth: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username: String? // 存储当前登录的用户名
}
