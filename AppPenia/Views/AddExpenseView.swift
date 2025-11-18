//
//  AddExpenseView.swift
//  AppPenia
//
//  Modal view for adding expense to a gathering
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let event: Event

    @State private var totalAmountText: String = ""
    @State private var selectedPayers: Set<UUID> = []
    @State private var payerAmounts: [UUID: String] = [:]
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    private var attendees: [User] {
        event.attendances?.compactMap { $0.user } ?? []
    }

    private var totalAmount: Decimal? {
        Decimal(string: totalAmountText.replacingOccurrences(of: ",", with: "."))
    }

    private var totalPaid: Decimal {
        selectedPayers.compactMap { payerId in
            guard let amountText = payerAmounts[payerId] else { return nil }
            return Decimal(string: amountText.replacingOccurrences(of: ",", with: "."))
        }.reduce(Decimal(0), +)
    }

    private var isValid: Bool {
        guard let total = totalAmount,
              total > 0,
              !selectedPayers.isEmpty else {
            return false
        }

        // Check that all payers have valid amounts
        for payerId in selectedPayers {
            guard let amountText = payerAmounts[payerId],
                  let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")),
                  amount > 0 else {
                return false
            }
        }

        // Check that total paid equals total amount
        return totalPaid == total
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                Form {
                    // Total Amount Section
                    Section {
                        HStack {
                            Text("Gasto Total")
                                .foregroundStyle(.primary)
                            Spacer()
                            TextField("0", text: $totalAmountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: 150)
                        }

                        if let total = totalAmount, total > 0 {
                            HStack {
                                Text("Por persona")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(formatCurrency(total / Decimal(attendees.count)))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Text("Monto")
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.white.opacity(0.1))

                    // Payers Section
                    Section {
                        if attendees.isEmpty {
                            Text("No hay asistentes registrados")
                                .foregroundStyle(.secondary)
                                .italic()
                        } else {
                            ForEach(attendees, id: \.id) { user in
                                PayerRow(
                                    user: user,
                                    isSelected: selectedPayers.contains(user.id),
                                    amountText: Binding(
                                        get: { payerAmounts[user.id] ?? "" },
                                        set: { payerAmounts[user.id] = $0 }
                                    ),
                                    onToggle: {
                                        if selectedPayers.contains(user.id) {
                                            selectedPayers.remove(user.id)
                                            payerAmounts[user.id] = nil
                                        } else {
                                            selectedPayers.insert(user.id)
                                        }
                                    }
                                )
                            }
                        }
                    } header: {
                        Text("¿Quién puso dinero?")
                            .foregroundStyle(.secondary)
                    } footer: {
                        if let total = totalAmount, total > 0 {
                            HStack {
                                Text("Total pagado:")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(formatCurrency(totalPaid))
                                    .foregroundStyle(totalPaid == total ? .green : .red)
                                    .bold()
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Agregar Gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(.primary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveExpense()
                    }
                    .foregroundStyle(.primary)
                    .disabled(!isValid)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveExpense() {
        guard let total = totalAmount else {
            showErrorAlert("Monto total inválido")
            return
        }

        // Create expense
        let expense = Expense(totalAmount: total, event: event)
        modelContext.insert(expense)

        // Create payments
        for payerId in selectedPayers {
            guard let amountText = payerAmounts[payerId],
                  let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")),
                  let user = attendees.first(where: { $0.id == payerId }) else {
                continue
            }

            let payment = Payment(amount: amount, user: user, expense: expense)
            modelContext.insert(payment)
        }

        // Associate expense with event
        event.expense = expense

        // Save
        do {
            try modelContext.save()
            dismiss()
        } catch {
            showErrorAlert("Error al guardar: \(error.localizedDescription)")
        }
    }

    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_AR")
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Payer Row

struct PayerRow: View {
    let user: User
    let isSelected: Bool
    @Binding var amountText: String
    let onToggle: () -> Void

    var body: some View {
        HStack {
            // Avatar and name
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? .green : .secondary)
                        .font(.title3)

                    ProfilePhotoView(photoData: user.photoData, size: .small)

                    Text(user.name)
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Amount field (only show if selected)
            if isSelected {
                TextField("Monto", text: $amountText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: 100)
            }
        }
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
    container.mainContext.insert(user1)
    container.mainContext.insert(user2)

    let event = Event(date: Date(), notes: "Juntada de prueba", host: user1)
    container.mainContext.insert(event)

    let att1 = Attendance(user: user1, event: event)
    let att2 = Attendance(user: user2, event: event)
    container.mainContext.insert(att1)
    container.mainContext.insert(att2)

    return AddExpenseView(event: event)
        .modelContainer(container)
}
