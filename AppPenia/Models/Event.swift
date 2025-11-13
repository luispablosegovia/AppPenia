//
//  Event.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import Foundation
import SwiftData

@Model
final class Event {
    @Attribute(.unique) var id: UUID
    var date: Date
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \Attendance.event)
    var attendances: [Attendance]?

    init(date: Date, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.notes = notes
        self.attendances = []
    }

    var attendeeCount: Int {
        attendances?.count ?? 0
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}
