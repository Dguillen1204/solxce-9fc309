// Views/RunLogView.swift
import SwiftUI
import SwiftData
import Combine

enum RunTrackingMode: String, CaseIterable, Identifiable {
    case live = "Live Run Tracker"
    case manual = "Manual Entry"

    var id: String { rawValue }
}

struct RunLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RunEntry.date, order: .reverse) private var pastRuns: [RunEntry]

    @State private var mode: RunTrackingMode = .live
    @State private var runTitle: String = "Outdoor Run"
    @State private var notes: String = ""

    // Live Tracking State
    @State private var isRunning: Bool = false
    @State private var isPaused: Bool = false
    @State private var elapsedSeconds: Int = 0
    @State private var liveDistanceMiles: Double = 0.0
    @State private var liveSpeedMph: Double = 6.0 // Target or simulated speed (mph)
    @State private var timerSubscription: AnyCancellable? = nil
    @State private var showFinishConfirmation: Bool = false

    // Manual Entry State
    @State private var manualDistanceMiles: Double = 3.1
    @State private var manualDurationMinutes: Int = 24
    @State private var manualDurationSeconds: Int = 30
    @State private var manualCaloriesBurned: Int = 340

    // MARK: - Computed Properties for Live Tracker
    var livePaceMinutesPerMile: Double {
        guard liveDistanceMiles > 0 else { return 0 }
        return (Double(elapsedSeconds) / 60.0) / liveDistanceMiles
    }

    var liveFormattedPace: String {
        guard liveDistanceMiles > 0.01 else { return "--'--\" /mi" }
        let pace = livePaceMinutesPerMile
        let mins = Int(pace)
        let secs = Int((pace - Double(mins)) * 60)
        return String(format: "%d'%02d\" /mi", mins, max(0, min(59, secs)))
    }

    var liveCurrentSpeedPace: String {
        guard liveSpeedMph > 0.1 else { return "--'--\" /mi" }
        let paceMins = 60.0 / liveSpeedMph
        let mins = Int(paceMins)
        let secs = Int((paceMins - Double(mins)) * 60)
        return String(format: "%d'%02d\" /mi", mins, max(0, min(59, secs)))
    }

    var liveFormattedTime: String {
        let hrs = elapsedSeconds / 3600
        let mins = (elapsedSeconds % 3600) / 60
        let secs = elapsedSeconds % 60
        if hrs > 0 {
            return String(format: "%02d:%02d:%02d", hrs, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }

    var liveCaloriesBurned: Int {
        Int(liveDistanceMiles * 110)
    }

    // MARK: - Manual Computed Properties
    var manualTotalDurationSeconds: Int {
        (manualDurationMinutes * 60) + manualDurationSeconds
    }

    var manualPaceMinutesPerMile: Double {
        guard manualDistanceMiles > 0 else { return 0 }
        return (Double(manualTotalDurationSeconds) / 60.0) / manualDistanceMiles
    }

    var manualFormattedPace: String {
        let pace = manualPaceMinutesPerMile
        let mins = Int(pace)
        let secs = Int((pace - Double(mins)) * 60)
        return String(format: "%d'%02d\" /mi", mins, max(0, min(59, secs)))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Mode Picker
                    Picker("Mode", selection: $mode) {
                        ForEach(RunTrackingMode.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, AppTheme.Spacing.xs)

                    if mode == .live {
                        liveTrackerCard
                    } else {
                        manualEntryCard
                    }

                    // Run Notes & Tagging
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("RUN TITLE & NOTES")
                            .font(AppTheme.eyebrowFont)
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textSecondary)

                        TextField("Workout Title (e.g. Morning 5K, Tempo Interval)", text: $runTitle)
                            .font(AppTheme.bodyFont)
                            .padding(AppTheme.Spacing.sm)
                            .background(AppTheme.field)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                            .foregroundStyle(AppTheme.text)

                        TextField("Notes (shoes, weather, elevation, feeling)", text: $notes)
                            .font(AppTheme.bodyFont)
                            .padding(AppTheme.Spacing.sm)
                            .background(AppTheme.field)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                            .foregroundStyle(AppTheme.text)
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))

                    // Past Run Log History
                    pastRunsSection
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Track Run")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        stopLiveTimer()
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.textSecondary)
                }

                if mode == .manual {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save Run") {
                            saveManualRun()
                            dismiss()
                        }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.primary)
                    }
                }
            }
            .alert("Finish & Save Run?", isPresented: $showFinishConfirmation) {
                Button("Save Workout") {
                    saveLiveRun()
                    dismiss()
                }
                Button("Discard", role: .destructive) {
                    resetLiveTracker()
                }
                Button("Resume Running", role: .cancel) {
                    resumeLiveTimer()
                }
            } message: {
                Text(String(format: "You ran %.2f miles in %@ at an average pace of %@.", liveDistanceMiles, liveFormattedTime, liveFormattedPace))
            }
        }
    }

    // MARK: - Live Tracker Card
    private var liveTrackerCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Live Status Indicator
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(isRunning ? AppTheme.primary : (isPaused ? AppTheme.carbsColor : AppTheme.textMuted))
                        .frame(width: 10, height: 10)
                        .scaleEffect(isRunning ? 1.2 : 1.0)
                        .animation(isRunning ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default, value: isRunning)

                    Text(isRunning ? "RECORDING RUN" : (isPaused ? "RUN PAUSED" : "READY TO RUN"))
                        .font(AppTheme.eyebrowFont)
                        .tracking(1.5)
                        .foregroundStyle(isRunning ? AppTheme.primary : AppTheme.textSecondary)
                }

                Spacer()

                if isRunning || isPaused {
                    Text(liveCurrentSpeedPace)
                        .font(AppTheme.captionFont)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.primary.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            // Big Live Timer & Distance Hero
            VStack(spacing: 2) {
                Text(liveFormattedTime)
                    .font(.system(size: 54, weight: .black, design: .monospaced))
                    .foregroundStyle(AppTheme.text)
                    .contentTransition(.numericText())

                Text("ELAPSED TIME")
                    .font(AppTheme.eyebrowFont)
                    .tracking(2.0)
                    .foregroundStyle(AppTheme.textMuted)
            }
            .padding(.vertical, AppTheme.Spacing.xs)

            // Primary Metrics Grid
            HStack(spacing: AppTheme.Spacing.md) {
                VStack(spacing: 2) {
                    Text(String(format: "%.2f", liveDistanceMiles))
                        .font(AppTheme.heroNumeralFont)
                        .foregroundStyle(AppTheme.primary)
                    Text("DISTANCE (MI)")
                        .font(AppTheme.eyebrowFont)
                        .tracking(1.5)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .background(AppTheme.hairline)

                VStack(spacing: 2) {
                    Text(liveFormattedPace)
                        .font(AppTheme.heroNumeralFont)
                        .foregroundStyle(AppTheme.primary)
                    Text("AVG PACE")
                        .font(AppTheme.eyebrowFont)
                        .tracking(1.5)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, AppTheme.Spacing.xs)

            // Speed Control / Running Pace Adjustment (Pedometer / Treadmill / Live Speed dial)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("PACE CADENCE SPEED")
                        .font(AppTheme.eyebrowFont)
                        .tracking(1.2)
                        .foregroundStyle(AppTheme.textMuted)
                    Spacer()
                    Text(String(format: "%.1f mph  (%@)", liveSpeedMph, liveCurrentSpeedPace))
                        .font(AppTheme.subheadlineFont)
                        .bold()
                        .foregroundStyle(AppTheme.text)
                }

                Slider(value: $liveSpeedMph, in: 3.0...12.0, step: 0.1)
                    .tint(AppTheme.primary)
            }
            .padding(AppTheme.Spacing.sm)
            .background(AppTheme.ground.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))

            // Action Buttons (Start, Pause, Resume, Finish)
            HStack(spacing: AppTheme.Spacing.sm) {
                if !isRunning && !isPaused {
                    Button(action: startLiveTimer) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("START RUN")
                        }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    }
                } else if isRunning {
                    Button(action: pauseLiveTimer) {
                        HStack {
                            Image(systemName: "pause.fill")
                            Text("PAUSE")
                        }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    }

                    Button(action: { showFinishConfirmation = true }) {
                        HStack {
                            Image(systemName: "flag.checkered")
                            Text("FINISH")
                        }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    }
                } else if isPaused {
                    Button(action: resumeLiveTimer) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("RESUME")
                        }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    }

                    Button(action: { showFinishConfirmation = true }) {
                        HStack {
                            Image(systemName: "flag.checkered")
                            Text("FINISH")
                        }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                .strokeBorder(isRunning ? AppTheme.primary.opacity(0.5) : AppTheme.hairline, lineWidth: 1.5)
        )
    }

    // MARK: - Manual Entry Card
    private var manualEntryCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Hero Pace & Distance Display
            VStack(spacing: AppTheme.Spacing.md) {
                Text("ESTIMATED PACE")
                    .font(AppTheme.eyebrowFont)
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.textSecondary)

                Text(manualFormattedPace)
                    .font(AppTheme.heroNumeralFont)
                    .foregroundStyle(AppTheme.primary)

                HStack(spacing: AppTheme.Spacing.xl) {
                    statPill(label: "DISTANCE", value: "\(String(format: "%.2f", manualDistanceMiles)) mi")
                    statPill(label: "DURATION", value: String(format: "%d:%02d", manualDurationMinutes, manualDurationSeconds))
                    statPill(label: "CALORIES", value: "\(manualCaloriesBurned) kcal")
                }
            }
            .padding(AppTheme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                    .strokeBorder(AppTheme.primary.opacity(0.25))
            )

            // Manual Slider Inputs
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("MANUAL LOG VALUES")
                    .font(AppTheme.eyebrowFont)
                    .tracking(1.5)
                    .foregroundStyle(AppTheme.textSecondary)

                // Distance Slider
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Distance")
                            .font(AppTheme.subheadlineFont)
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text(String(format: "%.2f miles", manualDistanceMiles))
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(AppTheme.text)
                    }
                    Slider(value: $manualDistanceMiles, in: 0.1...26.2, step: 0.1)
                        .tint(AppTheme.primary)
                }

                // Time Pickers
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(AppTheme.subheadlineFont)
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(spacing: AppTheme.Spacing.sm) {
                        HStack {
                            TextField("Mins", value: $manualDurationMinutes, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                            Text("min")
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(8)
                        .background(AppTheme.field)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))

                        HStack {
                            TextField("Secs", value: $manualDurationSeconds, format: .number)
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
            }
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
        }
    }

    // MARK: - Past Runs List
    private var pastRunsSection: some View {
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

    // MARK: - Live Timer Methods
    private func startLiveTimer() {
        isRunning = true
        isPaused = false
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                elapsedSeconds += 1
                // Add distance increment according to active speed: (speed in mph / 3600 seconds per hour)
                let distanceDelta = liveSpeedMph / 3600.0
                liveDistanceMiles += distanceDelta
            }
    }

    private func pauseLiveTimer() {
        isRunning = false
        isPaused = true
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    private func resumeLiveTimer() {
        startLiveTimer()
    }

    private func stopLiveTimer() {
        isRunning = false
        isPaused = false
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    private func resetLiveTracker() {
        stopLiveTimer()
        elapsedSeconds = 0
        liveDistanceMiles = 0.0
    }

    private func saveLiveRun() {
        stopLiveTimer()
        let entry = RunEntry(
            title: runTitle.isEmpty ? "Outdoor Run" : runTitle,
            distanceMiles: max(0.05, liveDistanceMiles),
            durationSeconds: max(1, elapsedSeconds),
            date: Date(),
            caloriesBurned: liveCaloriesBurned,
            notes: notes
        )
        modelContext.insert(entry)
        try? modelContext.save()
    }

    private func saveManualRun() {
        let entry = RunEntry(
            title: runTitle.isEmpty ? "Outdoor Run" : runTitle,
            distanceMiles: manualDistanceMiles,
            durationSeconds: manualTotalDurationSeconds,
            date: Date(),
            caloriesBurned: manualCaloriesBurned,
            notes: notes
        )
        modelContext.insert(entry)
        try? modelContext.save()
    }
}
