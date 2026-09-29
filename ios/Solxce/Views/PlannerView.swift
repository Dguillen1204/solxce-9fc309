// Views/PlannerView.swift
import SwiftUI
import SwiftData

struct PlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlannerDay.dayOfWeek) private var days: [PlannerDay]

    @State private var editingDay: PlannerDay?

    // Custom sort order so Monday is first (2,3,4,5,6,7,1)
    var sortedDays: [PlannerDay] {
        days.sorted { a, b in
            let orderA = a.dayOfWeek == 1 ? 8 : a.dayOfWeek
            let orderB = b.dayOfWeek == 1 ? 8 : b.dayOfWeek
            return orderA < orderB
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Header / Overview
                    VStack(alignment: .leading, spacing: 4) {
                        Text("WEEKLY TRAINING SPLIT")
                            .font(AppTheme.eyebrowFont)
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.primary)

                        Text("Plan Your Focus")
                            .font(AppTheme.largeTitleFont)
                            .foregroundStyle(AppTheme.text)

                        Text("Assign targeted muscle groups for each day of the week to stay disciplined and structured.")
                            .font(AppTheme.subheadlineFont)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // 7-Day Split Cards
                    VStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(sortedDays) { day in
                            plannerDayRow(day)
                        }
                    }

                    // Split distribution summary
                    splitSummaryCard
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Split Planner")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $editingDay) { day in
                EditPlannerDaySheet(day: day)
            }
        }
    }

    private func plannerDayRow(_ day: PlannerDay) -> some View {
        Button(action: { editingDay = day }) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Day Badge
                VStack {
                    Text(day.dayName.prefix(3).uppercased())
                        .font(AppTheme.eyebrowFont)
                        .foregroundStyle(day.isRestDay ? AppTheme.accent : AppTheme.primary)
                    Text(String(day.dayOfWeek == 1 ? "Sun" : day.dayName.prefix(1)))
                        .font(AppTheme.titleFont)
                        .bold()
                        .foregroundStyle(AppTheme.text)
                }
                .frame(width: 48)
                .padding(.vertical, 8)
                .background(AppTheme.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))

                // Split Details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(day.focusBodyPart)
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(day.isRestDay ? AppTheme.textSecondary : AppTheme.text)

                        if day.isRestDay {
                            Text("REST")
                                .font(AppTheme.eyebrowFont)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.accent.opacity(0.18))
                                .foregroundStyle(AppTheme.accent)
                                .clipShape(Capsule())
                        }
                    }

                    if !day.targetExercisesDescription.isEmpty {
                        Text(day.targetExercisesDescription)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textMuted)
            }
            .padding(AppTheme.Spacing.sm)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                    .strokeBorder(day.isRestDay ? AppTheme.hairline : AppTheme.primary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var splitSummaryCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("SPLIT BALANCE")
                .font(AppTheme.eyebrowFont)
                .tracking(1.5)
                .foregroundStyle(AppTheme.textSecondary)

            let trainingDays = days.filter { !$0.isRestDay }.count
            let restDays = days.filter { $0.isRestDay }.count

            HStack(spacing: AppTheme.Spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(trainingDays) Days")
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.primary)
                    Text("Training Sessions")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(restDays) Days")
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.accent)
                    Text("Recovery Days")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
    }
}

// MARK: - Edit Planner Day Sheet
struct EditPlannerDaySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var day: PlannerDay

    let bodyPartOptions = [
        "Chest & Triceps",
        "Back & Biceps",
        "Legs & Core",
        "Shoulders & Arms",
        "Full Body Power",
        "Push (Chest/Shoulders/Tris)",
        "Pull (Back/Biceps)",
        "Legs & Hamstrings",
        "Upper Body",
        "Lower Body",
        "Running & Cardio",
        "Active Recovery",
        "Rest Day"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("\(day.dayName) Focus") {
                    Toggle("Is Rest Day", isOn: $day.isRestDay)
                        .tint(AppTheme.primary)

                    if !day.isRestDay {
                        Picker("Target Muscle Group", selection: $day.focusBodyPart) {
                            ForEach(bodyPartOptions, id: \.self) {
                                Text($0).tag($0)
                            }
                        }

                        TextField("Target Exercises / Notes", text: $day.targetExercisesDescription, axis: .vertical)
                            .lineLimit(3...5)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Edit \(day.dayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if day.isRestDay {
                            day.focusBodyPart = "Rest Day"
                        }
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
