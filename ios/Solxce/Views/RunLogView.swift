// Views/RunLogView.swift
import SwiftUI
import SwiftData

struct RunLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RunEntry.date, order: .reverse) private var pastRuns: [RunEntry]

    @State private var title: String = "Outdoor Run"
    @State private var distanceMiles: Double = 3.1
    @State private var durationMinutes: Int = 24
    @State private var durationSeconds: Int = 30
    @State private var caloriesBurned: Int = 340
    @State private var notes: String = ""

    var totalDurationSeconds: Int {
        (durationMinutes * 60) + durationSeconds
    }

    var paceMinutesPerMile: Double {
        guard distanceMiles > 0 else { return 0 }
        return (Double(totalDurationSeconds) / 60.0) / distanceMiles
    }

    var formattedPace: String {
        let pace = paceMinutesPerMile
        let mins = Int(pace)
        let secs = Int((pace - Double(mins)) * 60)
        return String(format: "%d'%02d\" /mi", mins, secs)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Hero Pace & Distance Display
                    VStack(spacing: AppTheme.Spacing.md) {
                        Text("ESTIMATED PACE")
                            .font(AppTheme.eyebrowFont)
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textSecondary)

                        Text(formattedPace)
                            .font(AppTheme.heroNumeralFont)
                            .foregroundStyle(AppTheme.primary)

                        HStack(spacing: AppTheme.Spacing.xl) {
                            statPill(label: "DISTANCE", value: "\(String(format: "%.2f", distanceMiles)) mi")
                            statPill(label: "DURATION", value: String(format: "%d:%02d", durationMinutes, durationSeconds))
                            statPill(label: "CALORIES", value: "\(caloriesBurned) kcal")
                        }
                    }
                    .padding(AppTheme.Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                            .strokeBorder(AppTheme.primary.opacity(0.25))
                    )

                    // Inputs Section
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("RUN DETAILS")
                            .font(AppTheme.eyebrowFont)
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textSecondary)

                        VStack(spacing: AppTheme.Spacing.sm) {
                            TextField("Run Title", text: $title)
                                .font(AppTheme.bodyFont)
                                .padding(AppTheme.Spacing.sm)
                                .background(AppTheme.field)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                                .foregroundStyle(AppTheme.text)

                            // Distance slider & input
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Distance")
                                        .font(AppTheme.subheadlineFont)
                                        .foregroundStyle(AppTheme.textSecondary)
                                    Spacer()
                                    Text(String(format: "%.2f miles", distanceMiles))
                                        .font(AppTheme.headlineFont)
                                        .foregroundStyle(AppTheme.text)
                                }
                                Slider(value: $distanceMiles, in: 0.5...26.2, step: 0.1)
                                    .tint(AppTheme.primary)
                            }

                            // Time Picker
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Duration")
                                    .font(AppTheme.subheadlineFont)
                                    .foregroundStyle(AppTheme.textSecondary)

                                HStack(spacing: AppTheme.Spacing.sm) {
                                    HStack {
                                        TextField("Mins", value: $durationMinutes, format: .number)
                                            .keyboardType(.numberPad)
                                            .frame(width: 50)
                                        Text("min")
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                    .padding(8)
                                    .background(AppTheme.field)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))

                                    HStack {
                                        TextField("Secs", value: $durationSeconds, format: .number)
                                            .keyboardType(.numberPad)
                                            .frame(width: 50)
                                        Text("sec")
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                    .padding(8)
                                    .background(AppTheme.field)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))

                                    Spacer()
                                }
                            }

                            TextField("Workout Notes (optional)", text: $notes)
                                .font(AppTheme.bodyFont)
                                .padding(AppTheme.Spacing.sm)
                                .background(AppTheme.field)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                                .foregroundStyle(AppTheme.text)
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))

                    // Past Run Log History
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("PAST RUNS")
                            .font(AppTheme.eyebrowFont)
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textSecondary)

                        if pastRuns.isEmpty {
                            Text("No previous runs logged.")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.textMuted)
                        } else {
                            ForEach(pastRuns) { run in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(run.title)
                                            .font(AppTheme.headlineFont)
                                            .foregroundStyle(AppTheme.text)
                                        Text("\(String(format: "%.2f", run.distanceMiles)) mi · \(run.formattedDuration) · \(run.formattedPace)")
                                            .font(AppTheme.captionFont)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }

                                    Spacer()

                                    Text(run.date.formatted(.dateTime.month().day()))
                                        .font(AppTheme.captionFont)
                                        .foregroundStyle(AppTheme.textMuted)
                                }
                                .padding(AppTheme.Spacing.sm)
                                .background(AppTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Log Run")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Run") {
                        saveRun()
                        dismiss()
                    }
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }

    private func statPill(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(AppTheme.eyebrowFont)
                .foregroundStyle(AppTheme.textMuted)
            Text(value)
                .font(AppTheme.subheadlineFont)
                .bold()
                .foregroundStyle(AppTheme.text)
        }
    }

    private func saveRun() {
        let entry = RunEntry(
            title: title.isEmpty ? "Outdoor Run" : title,
            distanceMiles: distanceMiles,
            durationSeconds: totalDurationSeconds,
            date: Date(),
            caloriesBurned: caloriesBurned,
            notes: notes
        )
        modelContext.insert(entry)
        try? modelContext.save()
    }
}
