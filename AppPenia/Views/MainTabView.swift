//
//  MainTabView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    init() {
        // Configurar apariencia del TabBar con efecto glass
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            EventsListView()
                .tabItem {
                    Label("Juntadas", systemImage: "calendar")
                }

            UsersListView()
                .tabItem {
                    Label("Miembros", systemImage: "person.2")
                }

            ExpensesTabView()
                .tabItem {
                    Label("Gastos", systemImage: "dollarsign.circle")
                }

            StatisticsView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
