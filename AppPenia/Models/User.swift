//
//  User.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Attendance.user)
    var attendances: [Attendance]?

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.attendances = []
    }

    var attendanceCount: Int {
        attendances?.count ?? 0
    }
}
