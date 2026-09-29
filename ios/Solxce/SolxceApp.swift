// SolxceApp.swift
import SwiftUI
import SwiftData

@main
struct SolxceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            WorkoutSession.self,
            WorkoutExercise.self,
            ExerciseSet.self,
            RunEntry.self,
            FoodEntry.self,
            MacroTarget.self,
            PlannerDay.self
        ])
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Int = 0

    init() {
        // Customize TabBar appearance for Athletic Volt theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.086, green: 0.086, blue: 0.086, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Today", systemImage: "flame.fill")
                }
                .tag(0)

            PlannerView()
                .tabItem {
                    Label("Planner", systemImage: "calendar")
                }
                .tag(1)

            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "square.grid.2x2")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(AppTheme.primary)
        .preferredColorScheme(.dark)
        .onAppear {
            SeedDataManager.seedIfNeeded(context: modelContext)
        }
    }
}
