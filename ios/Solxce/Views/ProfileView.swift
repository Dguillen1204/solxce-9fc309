// Views/ProfileView.swift
import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query private var workoutSessions: [WorkoutSession]
    @Query private var runEntries: [RunEntry]
    @Query private var macroTargets: [MacroTarget]
    @ObservedObject private var subManager = SubscriptionManager.shared

    @State private var showingEditGoals = false
    @State private var showingPaywall = false
    @State private var showingProgressReport = false
    @State private var showingFastingTracker = false
    @State private var showingEditAthleteType = false

    var currentProfile: UserProfile {
        if let existing = userProfiles.first {
            return existing
        }
        let fallback = UserProfile(
            fullName: "Alex Rivera",
            handle: "alex_solxce",
            athleteType: .hybrid,
            bio: "Hybrid athlete chasing heavy lifts and fast miles."
        )
        return fallback
    }

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

                    // Athlete Archetype Pass Card
                    athleteArchetypeCard

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
            .sheet(isPresented: $showingEditAthleteType) {
                EditAthleteTypeSheet(profile: currentProfile)
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(currentProfile.athleteType.badgeColor, lineWidth: 3)
                    .frame(width: 88, height: 88)

                Circle()
                    .fill(AppTheme.surfaceRaised)
                    .frame(width: 80, height: 80)

                Image(systemName: currentProfile.avatarSymbol.isEmpty ? currentProfile.athleteType.iconName : currentProfile.avatarSymbol)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(currentProfile.athleteType.badgeColor)
            }

            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(currentProfile.fullName)
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

                Text("@\(currentProfile.handle)")
                    .font(AppTheme.monoFont)
                    .foregroundStyle(AppTheme.textSecondary)

                Text(currentProfile.bio)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xs)
    }

    // MARK: - Athlete Archetype Badge Card
    private var athleteArchetypeCard: some View {
        Button {
            showingEditAthleteType = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(currentProfile.athleteType.badgeColor.opacity(0.18))
                        .frame(width: 48, height: 48)

                    Image(systemName: currentProfile.athleteType.iconName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(currentProfile.athleteType.badgeColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(currentProfile.athleteType.rawValue)
                            .font(AppTheme.headlineFont)
                            .foregroundColor(AppTheme.text)

                        Text(currentProfile.athleteType.shortTag)
                            .font(AppTheme.eyebrowFont)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(currentProfile.athleteType.badgeColor.opacity(0.2))
                            .foregroundColor(currentProfile.athleteType.badgeColor)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                    }

                    Text(currentProfile.athleteType.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("Change")
                        .font(AppTheme.eyebrowFont)
                        .foregroundColor(AppTheme.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.primary)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                ZStack {
                    AppTheme.surface
                    LinearGradient(
                        colors: [currentProfile.athleteType.badgeColor.opacity(0.08), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                    .stroke(currentProfile.athleteType.badgeColor.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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

// MARK: - Edit Athlete Type Sheet
struct EditAthleteTypeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var profile: UserProfile

    @State private var selectedType: AthleteType = .hybrid
    @State private var fullName: String = ""
    @State private var handle: String = ""
    @State private var bio: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SELECT ATHLETE ARCHETYPE")
                            .font(AppTheme.eyebrowFont)
                            .foregroundColor(AppTheme.textSecondary)

                        ForEach(AthleteType.allCases) { type in
                            Button {
                                selectedType = type
                            } label: {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(type.badgeColor.opacity(0.2))
                                            .frame(width: 44, height: 44)

                                        Image(systemName: type.iconName)
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(type.badgeColor)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(type.rawValue)
                                                .font(AppTheme.headlineFont)
                                                .foregroundColor(AppTheme.text)

                                            Spacer()

                                            if selectedType == type {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(AppTheme.primary)
                                            }
                                        }

                                        Text(type.description)
                                            .font(.system(size: 12))
                                            .foregroundColor(AppTheme.textSecondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .padding(12)
                                .background(selectedType == type ? AppTheme.surfaceRaised : AppTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                                        .stroke(selectedType == type ? type.badgeColor : AppTheme.hairline, lineWidth: selectedType == type ? 1.5 : 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Personal details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROFILE DETAILS")
                            .font(AppTheme.eyebrowFont)
                            .foregroundColor(AppTheme.textSecondary)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                            TextField("Name", text: $fullName)
                                .padding(10)
                                .background(AppTheme.surfaceRaised)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.button))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Handle")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                            TextField("Handle", text: $handle)
                                .padding(10)
                                .background(AppTheme.surfaceRaised)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.button))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Bio")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textSecondary)
                            TextField("Bio", text: $bio)
                                .padding(10)
                                .background(AppTheme.surfaceRaised)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.button))
                        }
                    }
                    .padding(AppTheme.Spacing.md)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Edit Athlete Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                        Button {
                            // Persist to SwiftData
                            profile.athleteType = selectedType
                            if !fullName.isEmpty { profile.fullName = fullName }
                            if !handle.isEmpty { profile.handle = handle }
                            if !bio.isEmpty { profile.bio = bio }
                            try? modelContext.save()

                            // Asynchronously sync profile via TenxData
                            Task {
                                await BackendSyncService.shared.syncProfileData(
                                    name: profile.fullName,
                                    handle: profile.handle,
                                    athleteType: profile.athleteType.rawValue
                                )
                            }
                            dismiss()
                        } label: {
                            Text("Save")
                                .font(AppTheme.headlineFont)
                                .foregroundColor(AppTheme.primary)
                        }
                }
            }
            .onAppear {
                selectedType = profile.athleteType
                fullName = profile.fullName
                handle = profile.handle
                bio = profile.bio
            }
        }
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
