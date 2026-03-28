//
//  Models.swift
//  WorkHive
//
//  Created by SAIL on 09/01/26.
//

// HrUser.swift

import Foundation

struct HrUser: Identifiable, Codable {
    let id: Int
    let full_name: String
    let email: String
    let phone: String
    let role: String
    let profile_image: String?
    let is_active: Int
    let created_at: String
    let status_text: String
}

struct ProfileListResponse: Codable {
    let success: Bool
    let type: String
    let count: Int?
    let data: [HrUser]
}

struct ProfileSingleResponse: Codable {
    let success: Bool
    let type: String
    let data: HrUser
}
