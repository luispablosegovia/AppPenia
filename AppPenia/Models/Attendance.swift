//
//  Attendance.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import Foundation
import SwiftData

@Model
final class Attendance {
    var id: UUID
    var createdAt: Date

    var user: User?
    var event: Event?

    init(user: User, event: Event) {
        self.id = UUID()
        self.createdAt = Date()
        self.user = user
        self.event = event
    }
}
