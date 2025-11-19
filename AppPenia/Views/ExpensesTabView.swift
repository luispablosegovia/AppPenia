//
//  ExpensesTabView.swift
//  AppPenia
//
//  Tab view showing all events with expenses
//

import SwiftUI
import SwiftData

struct ExpensesTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Event.date, order: .reverse) private var allEvents: [Event]

    private var eventsWithExpenses: [Event] {
        allEvents.filter { $0.expense != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                if eventsWithExpenses.isEmpty {
                    ContentUnavailableView(
                        "Sin Gastos Registrados",
                        systemImage: "dollarsign.circle",
                        description: Text("Los gastos de las juntadas aparecerán aquí")
                    )
                } else {
                    List {
                        ForEach(eventsWithExpenses) { event in
                            if let expense = event.expense {
                                NavigationLink(destination: ExpenseDetailView(event: event)) {
                                    ExpenseEventRow(event: event, expense: expense)
                                }
                                .listRowBackground(Color(.secondarySystemBackground).opacity(0.3))
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Gastos")
        }
    }
}

// MARK: - Expense Event Row

struct ExpenseEventRow: View {
    let event: Event
    let expense: Expense

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date
            Text(event.formattedDate)
                .font(.headline)

            // Amount summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(expense.totalAmount))
                        .font(.title3)
                        .bold()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Por Persona")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(expense.amountPerPerson))
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }

            // Attendee count
            HStack {
                Image(systemName: "person.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(event.attendeeCount) asistentes")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Balance indicator
                if expense.isBalanced {
                    Label("Balanceado", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Label("Desbalanceado", systemImage: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            // Debts summary
            let debts = expense.calculateDebts()
            if !debts.isEmpty {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(debts.count) transacciones")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_AR")
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: Event.self, User.self, Attendance.self, Expense.self, Payment.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let user1 = User(name: "Juan", hasSede: true, address: "Calle Falsa 123")
    let user2 = User(name: "María", hasSede: false, address: "")
    let user3 = User(name: "Pedro", hasSede: false, address: "")
    container.mainContext.insert(user1)
    container.mainContext.insert(user2)
    container.mainContext.insert(user3)

    // Event with expense
    let event1 = Event(date: Date(), notes: "Juntada con gasto", host: user1)
    container.mainContext.insert(event1)

    let att1 = Attendance(user: user1, event: event1)
    let att2 = Attendance(user: user2, event: event1)
    let att3 = Attendance(user: user3, event: event1)
    container.mainContext.insert(att1)
    container.mainContext.insert(att2)
    container.mainContext.insert(att3)

    let expense = Expense(totalAmount: 30000, event: event1)
    container.mainContext.insert(expense)
    event1.expense = expense

    let payment1 = Payment(amount: 20000, user: user1, expense: expense)
    let payment2 = Payment(amount: 10000, user: user2, expense: expense)
    container.mainContext.insert(payment1)
    container.mainContext.insert(payment2)

    // Event without expense
    let event2 = Event(date: Date().addingTimeInterval(-86400 * 7), notes: "Juntada sin gasto", host: user2)
    container.mainContext.insert(event2)

    return ExpensesTabView()
        .modelContainer(container)
}
