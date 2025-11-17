//
//  Expense.swift
//  AppPenia
//
//  Manages expense tracking for gatherings with automatic debt simplification
//

import Foundation
import SwiftData

/// Represents a debt from one user to another
struct Debt: Identifiable {
    let id = UUID()
    let from: User
    let to: User
    let amount: Decimal
}

@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var totalAmount: Decimal
    var createdAt: Date

    // Relationships
    var event: Event?
    @Relationship(deleteRule: .cascade) var payments: [Payment]?

    init(totalAmount: Decimal, event: Event?) {
        self.id = UUID()
        self.totalAmount = totalAmount
        self.createdAt = Date()
        self.event = event
        self.payments = []
    }

    // MARK: - Computed Properties

    /// Amount each attendee should pay (total divided equally)
    var amountPerPerson: Decimal {
        guard let event = event,
              let attendanceCount = event.attendances?.count,
              attendanceCount > 0 else {
            return 0
        }
        return totalAmount / Decimal(attendanceCount)
    }

    /// Total amount actually paid
    var totalPaid: Decimal {
        payments?.reduce(Decimal(0)) { $0 + $1.amount } ?? 0
    }

    /// Whether the payments match the total amount
    var isBalanced: Bool {
        totalPaid == totalAmount
    }

    // MARK: - Debt Calculation with Simplification

    /// Calculates optimized debts between users to minimize number of transactions
    /// Uses a greedy algorithm to match creditors with debtors
    func calculateDebts() -> [Debt] {
        guard let event = event,
              let attendances = event.attendances,
              !attendances.isEmpty,
              isBalanced else {
            return []
        }

        let paymentsList = payments ?? []
        var debts: [Debt] = []

        // Step 1: Calculate net balance for each user
        var balances: [User: Decimal] = [:]

        // Everyone starts owing their share
        for attendance in attendances {
            if let user = attendance.user {
                balances[user] = -amountPerPerson
            }
        }

        // Add what each person paid
        for payment in paymentsList {
            if let user = payment.user {
                balances[user, default: 0] += payment.amount
            }
        }

        // Step 2: Separate into creditors (positive balance) and debtors (negative balance)
        var creditors: [(user: User, amount: Decimal)] = []
        var debtors: [(user: User, amount: Decimal)] = []

        for (user, balance) in balances {
            if balance > 0 {
                creditors.append((user, balance))
            } else if balance < 0 {
                debtors.append((user, -balance)) // Store as positive for easier calculation
            }
        }

        // Step 3: Match debtors with creditors to minimize transactions
        // Sort by amount descending for greedy optimization
        creditors.sort { $0.amount > $1.amount }
        debtors.sort { $0.amount > $1.amount }

        var creditorIndex = 0
        var debtorIndex = 0

        while creditorIndex < creditors.count && debtorIndex < debtors.count {
            let creditor = creditors[creditorIndex]
            let debtor = debtors[debtorIndex]

            let transferAmount = min(creditor.amount, debtor.amount)

            // Create debt record
            debts.append(Debt(
                from: debtor.user,
                to: creditor.user,
                amount: transferAmount
            ))

            // Update remaining amounts
            creditors[creditorIndex].amount -= transferAmount
            debtors[debtorIndex].amount -= transferAmount

            // Move to next creditor/debtor if current is settled
            if creditors[creditorIndex].amount == 0 {
                creditorIndex += 1
            }
            if debtors[debtorIndex].amount == 0 {
                debtorIndex += 1
            }
        }

        return debts
    }

    // MARK: - User-specific balances

    /// Get the net balance for a specific user (positive = they are owed, negative = they owe)
    func balanceFor(user: User) -> Decimal {
        guard let event = event,
              let attendances = event.attendances,
              attendances.contains(where: { $0.user?.id == user.id }) else {
            return 0
        }

        let paymentsList = payments ?? []

        // Start with what they owe
        var balance = -amountPerPerson

        // Add what they paid
        let userPayments = paymentsList.filter { $0.user?.id == user.id }
        balance += userPayments.reduce(Decimal(0)) { $0 + $1.amount }

        return balance
    }

    /// Get total amount a user paid
    func amountPaidBy(user: User) -> Decimal {
        let paymentsList = payments ?? []
        return paymentsList
            .filter { $0.user?.id == user.id }
            .reduce(Decimal(0)) { $0 + $1.amount }
    }
}
