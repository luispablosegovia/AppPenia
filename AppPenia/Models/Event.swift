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
    var photoData: Data?

    @Relationship(deleteRule: .cascade, inverse: \Attendance.event)
    var attendances: [Attendance]?

    @Relationship(deleteRule: .cascade, inverse: \Expense.event)
    var expense: Expense?

    init(date: Date, notes: String = "", host: User? = nil, cook: User? = nil, dishwasher: User? = nil, photoData: Data? = nil) {
        self.id = UUID()
        self.date = date
        self.notes = notes
        self.host = host
        self.cook = cook
        self.dishwasher = dishwasher
        self.photoData = photoData
        self.attendances = []
        self.expense = nil
    }

    var attendeeCount: Int {
        attendances?.count ?? 0
    }

    var formattedDate: String {
        date.formatted(
            Date.FormatStyle(date: .abbreviated, time: .omitted)
                .locale(Locale(identifier: "es_ES"))
        )
    }

    var hostAddress: String? {
        guard let host = host, host.hasSede else { return nil }
        return host.address.isEmpty ? nil : host.address
    }

    var hasExpense: Bool {
        expense != nil
    }
}
