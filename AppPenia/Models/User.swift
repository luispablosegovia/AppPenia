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
    var birthday: Date?
    var hasSede: Bool
    var address: String

    @Relationship(deleteRule: .cascade, inverse: \Attendance.user)
    var attendances: [Attendance]?

    init(name: String, birthday: Date? = nil, hasSede: Bool = false, address: String = "") {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.birthday = birthday
        self.hasSede = hasSede
        self.address = address
        self.attendances = []
    }

    var attendanceCount: Int {
        attendances?.count ?? 0
    }

    var age: Int? {
        guard let birthday = birthday else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year
    }

    var formattedBirthday: String? {
        guard let birthday = birthday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "d 'de' MMMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: birthday)
    }
}
