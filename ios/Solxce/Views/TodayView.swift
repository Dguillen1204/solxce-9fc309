// Views/TodayView.swift
import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var macroTargets: [MacroTarget]
    @Query(sort: \FoodEntry.date, order: .reverse) private var allFoods: [FoodEntry]
    @Query(sort: \WorkoutSession.date, order: .reverse) private var workoutSessions: [WorkoutSession]
    @Query(sort: \RunEntry.date, order: .reverse) private var runEntries: [RunEntry]
    @Query private var plannerDays: [PlannerDay]

    @State private var showingWorkoutLogger = false
    @State private var showingRunLogger = false
    @State private var showingFoodLogger = false
    @Binding var selectedTab: Int

    var todayPlannerDay: PlannerDay? {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return plannerDays.first { $0.dayOfWeek == weekday }
    }

    var todayFoods: [FoodEntry] {
        let calendar = Calendar.current
        return allFoods.filter { calendar.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Header with Date & App Name
                    headerSection

                    // Scheduled Split Hero Card
                    todaySplitCard

                    // Macro Nutrition Glance Card
                    MacroRingsCard(
                        target: macroTargets.first,
                        todayFoods: todayFoods,
                        onFoodLogTap: { showingFoodLogger = true }
                    )

                    // Quick Log Actions Cluster
                    quickActionsGrid

                    // Recent Activity Stream
                    recentActivitySection
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, AppTheme.Spacing.xs)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .sheet(isPresented: $showingWorkoutLogger) {
                WorkoutLoggerView()
            }
            .sheet(isPresented: $showingRunLogger) {
                RunLogView()
            }
            .sheet(isPresented: $showingFoodLogger) {
                FoodLogView()
            }
        }
    }

    // MARK: - Subviews
    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Date().formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(AppTheme.eyebrowFont)
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.primary)

                Text("SOLXCE")
                    .font(AppTheme.displayFont)
                    .foregroundStyle(AppTheme.text)
            }

            Spacer()

            Button(action: { selectedTab = 3 }) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(AppTheme.text)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile")
        }
    }

    private var todaySplitCard: some View {
        Button(action: { selectedTab = 1 }) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(todayPlannerDay?.isRestDay == true ? AppTheme.accent : AppTheme.primary)
                            .frame(width: 8, height: 8)
                        Text(todayPlannerDay?.isRestDay == true ? "SCHEDULED REST" : "TODAY'S SPLIT")
                            .font(AppTheme.eyebrowFont)
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Planner")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.primary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppTheme.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(todayPlannerDay?.focusBodyPart ?? "Chest & Triceps")
                        .font(AppTheme.largeTitleFont)
                        .foregroundStyle(AppTheme.text)
                        .lineLimit(1)

                    if let desc = todayPlannerDay?.targetExercisesDescription, !desc.isEmpty {
                        Text(desc)
                            .font(AppTheme.subheadlineFont)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                    .strokeBorder(AppTheme.primary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("QUICK LOG")
                .font(AppTheme.eyebrowFont)
                .tracking(1.5)
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: AppTheme.Spacing.xs) {
                actionTile(
                    title: "Log Workout",
                    icon: "dumbbell.fill",
                    color: AppTheme.primary,
                    action: { showingWorkoutLogger = true }
                )
                actionTile(
                    title: "Log Run",
                    icon: "figure.run",
                    color: AppTheme.carbsColor,
                    action: { showingRunLogger = true }
                )
                actionTile(
                    title: "Log Food",
                    icon: "fork.knife",
                    color: AppTheme.proteinColor,
                    action: { showingFoodLogger = true }
                )
            }
        }
    }

    private func actionTile(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(AppTheme.captionFont)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.text)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                    .strokeBorder(AppTheme.hairline)
            )
        }
        .buttonStyle(.plain)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("RECENT SESSIONS")
                    .font(AppTheme.eyebrowFont)
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
            }

            if workoutSessions.isEmpty && runEntries.isEmpty {
                VStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "flame")
                        .font(.system(size: 32))
                        .foregroundStyle(AppTheme.textMuted)
                    Text("No sessions recorded yet")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("Log your first workout or run using the quick buttons above.")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.Spacing.xl)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
            } else {
                VStack(spacing: AppTheme.Spacing.xs) {
                    ForEach(workoutSessions.prefix(3)) { session in
                        HStack(spacing: AppTheme.Spacing.sm) {
                            ZStack {
                                RoundedRectangle(cornerRadius: AppTheme.Radii.tag)
                                    .fill(AppTheme.primary.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(AppTheme.primary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.title)
                                    .font(AppTheme.headlineFont)
                                    .foregroundStyle(AppTheme.text)
                                Text("\(session.exercises.count) exercises · \(session.totalSets) sets · \(Int(session.totalVolumeLbs)) lbs")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(session.durationMinutes) min")
                                    .font(AppTheme.captionFont)
                                    .bold()
                                    .foregroundStyle(AppTheme.text)
                                Text(session.date.formatted(.dateTime.month().day()))
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.textMuted)
                            }
                        }
                        .padding(AppTheme.Spacing.sm)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    }

                    ForEach(runEntries.prefix(2)) { run in
                        HStack(spacing: AppTheme.Spacing.sm) {
                            ZStack {
                                RoundedRectangle(cornerRadius: AppTheme.Radii.tag)
                                    .fill(AppTheme.carbsColor.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "figure.run")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(AppTheme.carbsColor)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(run.title)
                                    .font(AppTheme.headlineFont)
                                    .foregroundStyle(AppTheme.text)
                                Text("\(String(format: "%.2f", run.distanceMiles)) mi · Pace \(run.formattedPace)")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(run.formattedDuration)
                                    .font(AppTheme.captionFont)
                                    .bold()
                                    .foregroundStyle(AppTheme.text)
                                Text(run.date.formatted(.dateTime.month().day()))
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.textMuted)
                            }
                        }
                        .padding(AppTheme.Spacing.sm)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    }
                }
            }
        }
    }
}
