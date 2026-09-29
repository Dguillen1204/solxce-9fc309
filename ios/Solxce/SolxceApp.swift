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
    @State private var showAICoachSheet: Bool = false

    init() {
        // Customize TabBar appearance for Athletic Volt theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.086, green: 0.086, blue: 0.086, alpha: 1.0)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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

            // Floating AI Assistant Circle Button (Bottom Right)
            floatingAIButton
                .padding(.trailing, 16)
                .padding(.bottom, 62) // Positioned nicely above the TabBar
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAICoachSheet) {
            AICoachChatView()
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            SeedDataManager.seedIfNeeded(context: modelContext)
        }
    }

    // MARK: - Floating AI Circle Button
    private var floatingAIButton: some View {
        Button {
            showAICoachSheet = true
        } label: {
            ZStack {
                // Outer glow shadow ring
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.primary,
                                AppTheme.primary.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .shadow(color: AppTheme.primary.opacity(0.45), radius: 10, x: 0, y: 4)

                // Sparkle / AI icon with pulse badge
                VStack(spacing: 0) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(AppTheme.onPrimary)
                }

                // AI small sub-badge
                VStack {
                    HStack {
                        Spacer()
                        Text("AI")
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundStyle(AppTheme.text)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1.5)
                            .background(Color.black)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(AppTheme.primary, lineWidth: 1)
                            )
                            .offset(x: 4, y: -4)
                    }
                    Spacer()
                }
                .frame(width: 52, height: 52)
            }
        }
        .buttonStyle(ScaleBounceButtonStyle())
        .accessibilityLabel("Ask Solxce AI Coach")
        .accessibilityHint("Opens AI chat for workout, food, and training questions")
    }
}

// MARK: - Scale Bounce Button Style
struct ScaleBounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
