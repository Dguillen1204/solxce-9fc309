// Views/CreateMediaPostSheet.swift
import SwiftUI

struct CreateMediaPostSheet: View {
    @Environment(\.dismiss) private var dismiss

    var authorName: String
    var authorHandle: String
    var athleteType: AthleteType
    var onPost: (AthletePost) -> Void

    // Form State
    @State private var selectedMediaType: PostMediaType = .video
    @State private var selectedMediaPreset: MediaPreset = MediaPreset.defaults[0]
    @State private var selectedAudio: AudioTrack? = AudioTrack.library[0]
    @State private var workoutFocus: String = "Chest & Heavy Hypertrophy"
    @State private var workoutStats: String = "5 sets · 315 lbs Bench Press PR"
    @State private var caption: String = "Crushed today's session! Progressive overload is hitting all the right marks. ⚡"
    @State private var textOverlay: String = "NEW BENCH PR 🔥"

    // Sheet Presentations
    @State private var showingAudioPicker: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 1. Interactive 9:16 Aspect Media Preview Viewport with Music on Top
                    mediaPreviewViewport

                    // 2. Music Soundtrack Selection (Apple Music & Spotify)
                    audioTrackSelectorBar

                    // 3. Caption & Details Input
                    captionInputArea
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, 12)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Share") {
                        commitAndPublishPost()
                    }
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.primary)
                }
            }
            .sheet(isPresented: $showingAudioPicker) {
                AudioPickerSheet(selectedAudio: $selectedAudio)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - 1. 9:16 Aspect Media Preview Viewport
    private var mediaPreviewViewport: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("POST PREVIEW (9:16)")
                .font(AppTheme.eyebrowFont)
                .foregroundColor(AppTheme.textSecondary)
                .tracking(1.5)

            ZStack(alignment: .bottom) {
                // Background Gradient
                LinearGradient(
                    colors: selectedMediaPreset.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // Center Icon / Graphics
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(athleteType.badgeColor.opacity(0.18))
                            .frame(width: 72, height: 72)

                        Image(systemName: selectedMediaPreset.systemIcon)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(athleteType.badgeColor)
                    }

                    if !textOverlay.isEmpty {
                        Text(textOverlay)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Top Bar with Music Tag
                VStack {
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AppTheme.surfaceRaised)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Image(systemName: athleteType.iconName)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(athleteType.badgeColor)
                                )

                            Text(authorName)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        if let audio = selectedAudio {
                            HStack(spacing: 4) {
                                Image(systemName: audio.platform.iconName)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(audio.platform.brandColor)

                                Text("\(audio.title) · \(audio.artist)")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(maxWidth: 120, alignment: .leading)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.65))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(12)

                    Spacer()
                }

                // Bottom Scrim & Caption Preview
                VStack(alignment: .leading, spacing: 4) {
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    .overlay(alignment: .bottomLeading) {
                        Text(caption.isEmpty ? "Your caption will appear here..." : caption)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding(12)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            )

            // Preset Style Switcher
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MediaPreset.defaults) { preset in
                        Button {
                            selectedMediaPreset = preset
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: preset.systemIcon)
                                    .font(.system(size: 11))
                                Text(preset.title)
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedMediaPreset.id == preset.id ? AppTheme.primary : AppTheme.surface)
                            .foregroundColor(selectedMediaPreset.id == preset.id ? AppTheme.onPrimary : AppTheme.textSecondary)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
    }

    // MARK: - 2. Music Soundtrack Selection Bar
    private var audioTrackSelectorBar: some View {
        Button {
            showingAudioPicker = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(selectedAudio != nil ? selectedAudio!.platform.brandColor.opacity(0.2) : AppTheme.primary.opacity(0.2))
                        .frame(width: 38, height: 38)

                    Image(systemName: selectedAudio != nil ? selectedAudio!.platform.iconName : "music.note")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(selectedAudio != nil ? selectedAudio!.platform.brandColor : AppTheme.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("MUSIC ON TOP")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(AppTheme.primary)
                        .tracking(1)

                    if let audio = selectedAudio {
                        Text("\(audio.title) · \(audio.artist)")
                            .font(AppTheme.subheadlineFont)
                            .bold()
                            .foregroundColor(AppTheme.text)
                            .lineLimit(1)
                    } else {
                        Text("Add song from Apple Music or Spotify...")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textMuted)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(12)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 3. Caption & Details Input
    private var captionInputArea: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("CAPTION")
                    .font(AppTheme.eyebrowFont)
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(1.5)

                TextField("Write your caption...", text: $caption, axis: .vertical)
                    .lineLimit(3...4)
                    .padding(12)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                    .foregroundColor(AppTheme.text)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                            .stroke(AppTheme.hairline, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("WORKOUT TAG & STATS")
                    .font(AppTheme.eyebrowFont)
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(1.5)

                HStack(spacing: 8) {
                    TextField("Routine (e.g. Chest PR)", text: $workoutFocus)
                        .font(AppTheme.subheadlineFont)
                        .padding(10)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))

                    TextField("Stats", text: $workoutStats)
                        .font(AppTheme.subheadlineFont)
                        .padding(10)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                }
            }
        }
    }

    // MARK: - Post Publisher
    private func commitAndPublishPost() {
        let finalCaption = caption.isEmpty ? "Great workout in the books." : caption
        let newPost = AthletePost(
            authorName: authorName,
            authorHandle: authorHandle,
            athleteType: athleteType,
            timeAgo: "Just now",
            workoutTag: workoutFocus.uppercased(),
            workoutStats: workoutStats,
            caption: finalCaption,
            imageName: selectedMediaPreset.systemIcon,
            mediaType: selectedMediaType,
            mediaIconName: selectedMediaPreset.systemIcon,
            gradientColors: selectedMediaPreset.gradientColors,
            audioTrack: selectedAudio,
            textOverlay: textOverlay.isEmpty ? nil : textOverlay,
            likesCount: 1,
            isLiked: true,
            comments: []
        )

        onPost(newPost)
        dismiss()
    }
}
