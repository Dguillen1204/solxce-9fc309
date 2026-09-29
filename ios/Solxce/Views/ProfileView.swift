// Views/ProfileView.swift
import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workoutSessions: [WorkoutSession]
    @Query private var runEntries: [RunEntry]
    @Query private var macroTargets: [MacroTarget]
    @ObservedObject private var subManager = SubscriptionManager.shared

    @State private var showingEditGoals = false
    @State private var showingPaywall = false
    @State private var showingProgressReport = false
    @State private var showingFastingTracker = false

    var totalVolumeLbs: Double {
        workoutSessions.reduce(0) { $0 + $1.totalVolumeLbs }
    }

    var totalRunMiles: Double {
        runEntries.reduce(0) { $0 + $1.distanceMiles }
    }

    var totalSetsCompleted: Int {
        workoutSessions.reduce(0) { $0 + $1.totalSets }
    }

    var target: MacroTarget? {
        macroTargets.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Profile Header & Avatar
                    profileHeader

                    // Solxce Pro Membership Card
                    proMembershipCard

                    // In-Depth Analytics Shortcut
                    inDepthReportShortcut

                    // Aggregate Lifetime Stats
                    lifetimeStatsCard

                    // Nutrition Goals Config Card
                    nutritionGoalsCard

                    // Training Distribution
                    trainingHistoryCard
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Athlete Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditGoals) {
                if let currentTarget = target {
                    EditMacroGoalsSheet(target: currentTarget)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingProgressReport) {
                ProgressReportView()
            }
            .sheet(isPresented: $showingFastingTracker) {
                FastingTrackerView()
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(AppTheme.primary, lineWidth: 3)
                    .frame(width: 88, height: 88)

                Circle()
                    .fill(AppTheme.surfaceRaised)
                    .frame(width: 80, height: 80)

                Image(systemName: "figure.cross-training")
                    .font(.system(size: 34))
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Text("Athlete")
                        .font(AppTheme.largeTitleFont)
                        .foregroundStyle(AppTheme.text)

                    if subManager.isPro {
                        Text("PRO")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(AppTheme.onPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.primary)
                            .clipShape(Capsule())
                    }
                }

                Text("@solxce_athlete · Dedicated Lifter & Runner")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.md)
    }

    // MARK: - Pro Membership Card
    private var proMembershipCard: some View {
        Button {
            showingPaywall = true
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Image(systemName: subManager.isPro ? "crown.fill" : "sparkles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(subManager.isPro ? "Solxce Pro Active" : "Upgrade to Solxce Pro")
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(AppTheme.text)

                        Text(subManager.isPro ? subManager.activePlan.title : "$15/mo or $80/yr")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.onPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.primary)
                            .clipShape(Capsule())
                    }

                    Text(subManager.isPro ? "Camera food scan, fasting alerts & deep analytics active." : "Unlock camera food scan, fasting alerts & deep analytics.")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.primary)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                    .strokeBorder(AppTheme.primary.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - In-Depth Report Shortcut
    private var inDepthReportShortcut: some View {
        Button {
            showingProgressReport = true
        } label: {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .foregroundStyle(AppTheme.primary)
                Text("View In-Depth Progress Report")
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.textMuted)
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Lifetime Stats Card
    private var lifetimeStatsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("LIFETIME METRICS")
                .font(AppTheme.eyebrowFont)
                .tracking(1.5)
                .foregroundStyle(AppTheme.textSecondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                metricCell(
                    title: "WORKOUTS",
                    value: "\(workoutSessions.count)",
                    subtext: "Sessions Completed",
                    color: AppTheme.primary
                )
                metricCell(
                    title: "TOTAL VOLUME",
                    value: "\(Int(totalVolumeLbs))",
                    subtext: "Pounds Lifted",
                    color: AppTheme.proteinColor
                )
                metricCell(
                    title: "TOTAL DISTANCE",
                    value: String(format: "%.1f", totalRunMiles),
                    subtext: "Miles Run",
                    color: AppTheme.carbsColor
                )
                metricCell(
                    title: "TOTAL SETS",
                    value: "\(totalSetsCompleted)",
                    subtext: "Sets Logged",
                    color: AppTheme.fatColor
                )
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                .strokeBorder(AppTheme.hairline)
        )
    }

    private func metricCell(title: String, value: String, subtext: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppTheme.eyebrowFont)
                .foregroundStyle(AppTheme.textMuted)

            Text(value)
                .font(AppTheme.titleFont)
                .bold()
                .foregroundStyle(color)

            Text(subtext)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
    }

    // MARK: - Nutrition Goals
    private var nutritionGoalsCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("DAILY MACRO TARGETS")
                    .font(AppTheme.eyebrowFont)
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer()

                Button("Edit Targets") {
                    showingEditGoals = true
                }
                .font(AppTheme.captionFont)
                .bold()
                .foregroundStyle(AppTheme.primary)
            }

            HStack(spacing: AppTheme.Spacing.xs) {
                targetPill(label: "Calories", value: "\(target?.dailyCalories ?? 2400) kcal", color: AppTheme.caloriesColor)
                targetPill(label: "Protein", value: "\(target?.dailyProteinGrams ?? 180)g", color: AppTheme.proteinColor)
                targetPill(label: "Carbs", value: "\(target?.dailyCarbsGrams ?? 240)g", color: AppTheme.carbsColor)
                targetPill(label: "Fat", value: "\(target?.dailyFatGrams ?? 70)g", color: AppTheme.fatColor)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
    }

    private func targetPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(AppTheme.eyebrowFont)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(AppTheme.captionFont)
                .bold()
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(AppTheme.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Training History List
    private var trainingHistoryCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("SESSION HISTORY")
                .font(AppTheme.eyebrowFont)
                .tracking(1.5)
                .foregroundStyle(AppTheme.textSecondary)

            if workoutSessions.isEmpty && runEntries.isEmpty {
                Text("No training logged yet.")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.textMuted)
            } else {
                ForEach(workoutSessions) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.title)
                                .font(AppTheme.headlineFont)
                                .foregroundStyle(AppTheme.text)
                            Text("\(session.bodyPartFocus) · \(session.exercises.count) exercises · \(Int(session.totalVolumeLbs)) lbs")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        Text(session.date.formatted(.dateTime.month().day()))
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.surfaceRaised)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
    }
}

// MARK: - Edit Macro Goals Sheet
struct EditMacroGoalsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var target: MacroTarget

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Targets") {
                    HStack {
                        Text("Daily Calories")
                        Spacer()
                        TextField("Calories", value: $target.dailyCalories, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("Protein", value: $target.dailyProteinGrams, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("Carbs", value: $target.dailyCarbsGrams, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("Fat", value: $target.dailyFatGrams, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Edit Nutrition Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}
