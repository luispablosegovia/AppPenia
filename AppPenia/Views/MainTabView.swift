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
            EventsListView()
                .tabItem {
                    Label("Juntadas", systemImage: "calendar")
                }

            UsersListView()
                .tabItem {
                    Label("Miembros", systemImage: "person.2")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
