//
//  MainTabView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Juntadas", systemImage: "calendar") {
                EventsListView()
            }

            Tab("Miembros", systemImage: "person.2") {
                UsersListView()
            }

            Tab("Gastos", systemImage: "dollarsign.circle") {
                ExpensesTabView()
            }

            Tab("Estadísticas", systemImage: "chart.bar") {
                StatisticsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
