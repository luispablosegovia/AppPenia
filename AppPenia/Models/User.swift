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
    var id: UUID
    var name: String
    var createdAt: Date
    var birthday: Date?
    var hasSede: Bool
    var address: String
    var photoData: Data?

    @Relationship(deleteRule: .cascade, inverse: \Attendance.user)
    var attendances: [Attendance]?

    init(name: String, birthday: Date? = nil, hasSede: Bool = false, address: String = "", photoData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.birthday = birthday
        self.hasSede = hasSede
        self.address = address
        self.photoData = photoData
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
        birthday?.formatted(
            Date.FormatStyle()
                .day(.defaultDigits)
                .month(.wide)
                .locale(Locale(identifier: "es_ES"))
        )
    }
}
