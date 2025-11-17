//
//  Payment.swift
//  AppPenia
//
//  Represents a payment made by a user towards an expense
//

import Foundation
import SwiftData

@Model
final class Payment {
    @Attribute(.unique) var id: UUID
    var amount: Decimal
    var createdAt: Date

    // Relationships
    var user: User?
    var expense: Expense?

    init(amount: Decimal, user: User?, expense: Expense?) {
        self.id = UUID()
        self.amount = amount
        self.createdAt = Date()
        self.user = user
        self.expense = expense
    }
}
