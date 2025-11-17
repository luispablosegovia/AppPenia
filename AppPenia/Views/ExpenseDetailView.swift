//
//  ExpenseDetailView.swift
//  AppPenia
//
//  Displays expense details and calculated debts between attendees
//

import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: Event

    @State private var showDeleteAlert = false
    @State private var showEditSheet = false

    private var expense: Expense? {
        event.expense
    }

    private var debts: [Debt] {
        expense?.calculateDebts() ?? []
    }

    var body: some View {
        ZStack {
            GlassBackground()

            if let expense = expense {
                List {
                    // Summary Section
                    Section {
                        HStack {
                            Text("Gasto Total")
                                .foregroundStyle(.white)
                            Spacer()
                            Text(formatCurrency(expense.totalAmount))
                                .foregroundStyle(.white)
                                .bold()
                        }

                        HStack {
                            Text("Por Persona")
                                .foregroundStyle(.white.opacity(0.7))
                            Spacer()
                            Text(formatCurrency(expense.amountPerPerson))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        HStack {
                            Text("Asistentes")
                                .foregroundStyle(.white.opacity(0.7))
                            Spacer()
                            Text("\(event.attendeeCount)")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    } header: {
                        Text("Resumen")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .listRowBackground(Color.white.opacity(0.1))

                    // Who Paid Section
                    Section {
                        if let payments = expense.payments, !payments.isEmpty {
                            ForEach(payments, id: \.id) { payment in
                                if let user = payment.user {
                                    HStack {
                                        ProfilePhotoView(photoData: user.photoData, size: .small)
                                        Text(user.name)
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text(formatCurrency(payment.amount))
                                            .foregroundStyle(.green)
                                            .bold()
                                    }
                                }
                            }
                        } else {
                            Text("No hay pagos registrados")
                                .foregroundStyle(.white.opacity(0.5))
                                .italic()
                        }
                    } header: {
                        Text("Quién puso dinero")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .listRowBackground(Color.white.opacity(0.1))

                    // Debts Section - Who owes whom
                    Section {
                        if debts.isEmpty {
                            if expense.isBalanced {
                                Label("Las cuentas están cuadradas", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Text("No se pueden calcular las deudas")
                                    .foregroundStyle(.orange)
                                    .italic()
                            }
                        } else {
                            ForEach(debts) { debt in
                                DebtRow(debt: debt)
                            }
                        }
                    } header: {
                        Text("Quién paga a quién")
                            .foregroundStyle(.white.opacity(0.7))
                    } footer: {
                        if !debts.isEmpty {
                            Text("Transferencias optimizadas para minimizar pagos")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
            } else {
                ContentUnavailableView(
                    "Sin Gasto",
                    systemImage: "dollarsign.circle",
                    description: Text("Este evento no tiene un gasto registrado")
                )
            }
        }
        .navigationTitle("Detalle del Gasto")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if expense != nil {
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .alert("Eliminar Gasto", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                deleteExpense()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar este gasto? Esta acción no se puede deshacer.")
        }
    }

    private func deleteExpense() {
        guard let expense = expense else { return }

        // Delete payments first (should cascade, but being explicit)
        if let payments = expense.payments {
            for payment in payments {
                modelContext.delete(payment)
            }
        }

        // Delete expense
        modelContext.delete(expense)
        event.expense = nil

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting expense: \(error)")
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_CL")
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Debt Row

struct DebtRow: View {
    let debt: Debt

    var body: some View {
        HStack(spacing: 12) {
            // Debtor
            HStack(spacing: 8) {
                ProfilePhotoView(photoData: debt.from.photoData, size: .small)
                Text(debt.from.name)
                    .foregroundStyle(.white)
            }

            // Arrow
            Image(systemName: "arrow.right")
                .foregroundStyle(.white.opacity(0.5))
                .font(.caption)

            // Creditor
            HStack(spacing: 8) {
                ProfilePhotoView(photoData: debt.to.photoData, size: .small)
                Text(debt.to.name)
                    .foregroundStyle(.white)
            }

            Spacer()

            // Amount
            Text(formatCurrency(debt.amount))
                .foregroundStyle(.cyan)
                .bold()
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_CL")
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

    let event = Event(date: Date(), notes: "Juntada de prueba", host: user1)
    container.mainContext.insert(event)

    let att1 = Attendance(user: user1, event: event)
    let att2 = Attendance(user: user2, event: event)
    let att3 = Attendance(user: user3, event: event)
    container.mainContext.insert(att1)
    container.mainContext.insert(att2)
    container.mainContext.insert(att3)

    let expense = Expense(totalAmount: 30000, event: event)
    container.mainContext.insert(expense)
    event.expense = expense

    let payment1 = Payment(amount: 20000, user: user1, expense: expense)
    let payment2 = Payment(amount: 10000, user: user2, expense: expense)
    container.mainContext.insert(payment1)
    container.mainContext.insert(payment2)

    return NavigationStack {
        ExpenseDetailView(event: event)
    }
    .modelContainer(container)
}
