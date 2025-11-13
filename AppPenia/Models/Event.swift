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
    var host: User?
    var cook: User?
    var dishwasher: User?

    @Relationship(deleteRule: .cascade, inverse: \Attendance.event)
    var attendances: [Attendance]?

    init(date: Date, notes: String = "", host: User? = nil, cook: User? = nil, dishwasher: User? = nil) {
        self.id = UUID()
        self.date = date
        self.notes = notes
        self.host = host
        self.cook = cook
        self.dishwasher = dishwasher
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

    var hostAddress: String? {
        guard let host = host, host.hasSede else { return nil }
        return host.address.isEmpty ? nil : host.address
    }
}
