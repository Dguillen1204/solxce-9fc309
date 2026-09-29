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
    @State private var selectedFilter: MediaFilterStyle = .normal
    @State private var workoutFocus: String = "Chest & Heavy Hypertrophy"
    @State private var workoutStats: String = "5 sets · 315 lbs Bench Press PR"
    @State private var caption: String = "Crushed today's session! Progressive overload is hitting all the right marks. ⚡"
    @State private var textOverlay: String = "NEW BENCH PR 🔥"

    // Sheet Presentations
    @State private var showingAudioPicker: Bool = false
    @State private var isSimulatingRecording: Bool = false
    @State private var recordSeconds: Int = 0
    @State private var showCustomTextEditor: Bool = false

    let recordingTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // 1. Media Type Selector (Photo vs Video / Reel)
                    mediaTypeSegmentedPicker

                    // 2. Interactive Media Preview Viewport (Instagram / TikTok style)
                    mediaPreviewViewport

                    // 3. Audio & Music Soundtrack Selection Bar
                    audioTrackSelectorBar

                    // 4. Filter & Visual Look Chips
                    filterStylePicker

                    // 5. Workout Metadata Inputs (Focus, Stats, Tag)
                    workoutDetailsForm

                    // 6. Caption & Hashtag Input
                    captionInputArea
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, 12)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Create Media Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Share Post") {
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
        .onReceive(recordingTimer) { _ in
            if isSimulatingRecording {
                recordSeconds += 1
            }
        }
    }

    // MARK: - 1. Media Type Segmented Picker
    private var mediaTypeSegmentedPicker: some View {
        HStack(spacing: 0) {
            ForEach(PostMediaType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedMediaType = type
                        if type == .photo && selectedMediaPreset.mediaType == .video {
                            selectedMediaPreset = MediaPreset.defaults.first(where: { $0.mediaType == .photo }) ?? MediaPreset.defaults[2]
                        } else if type == .video && selectedMediaPreset.mediaType == .photo {
                            selectedMediaPreset = MediaPreset.defaults.first(where: { $0.mediaType == .video }) ?? MediaPreset.defaults[0]
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: type.iconName)
                            .font(.system(size: 14, weight: .bold))
                        Text(type.rawValue)
                            .font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedMediaType == type ? AppTheme.primary : AppTheme.surface)
                    .foregroundColor(selectedMediaType == type ? AppTheme.onPrimary : AppTheme.textSecondary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radii.tag)
                .stroke(AppTheme.hairline, lineWidth: 1)
        )
    }

    // MARK: - 2. Media Preview Viewport
    private var mediaPreviewViewport: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background Gradient with selected filter
                LinearGradient(
                    colors: selectedMediaPreset.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .aspectRatio(4/3, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                        .stroke(selectedFilter.badgeColor.opacity(0.6), lineWidth: selectedFilter == .normal ? 1 : 2)
                )

                // Simulated Content Graphics
                VStack(spacing: 12) {
                    Image(systemName: selectedMediaPreset.systemIcon)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(athleteType.badgeColor)
                        .shadow(color: athleteType.badgeColor.opacity(0.5), radius: 10)

                    Text(selectedMediaPreset.workoutContext)
                        .font(AppTheme.headlineFont)
                        .foregroundColor(.white)

                    if selectedMediaType == .video {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(isSimulatingRecording ? AppTheme.accent : AppTheme.primary)
                                .frame(width: 8, height: 8)
                            Text(isSimulatingRecording ? "RECORDING: 00:\(String(format: "%02d", recordSeconds))" : "VIDEO READY (1080p 60FPS)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    }
                }

                // Overlay Text Sticker (TikTok / IG Style)
                if !textOverlay.isEmpty {
                    VStack {
                        Spacer()
                        Text(textOverlay)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.primary, lineWidth: 1.5)
                            )
                            .padding(.bottom, 14)
                    }
                }

                // Viewport Controls Overlay (Camera Simulator & Text Sticker toggle)
                VStack {
                    HStack {
                        // Quick Preset Swapper
                        Menu {
                            ForEach(MediaPreset.defaults.filter { $0.mediaType == selectedMediaType }) { preset in
                                Button {
                                    selectedMediaPreset = preset
                                } label: {
                                    Label(preset.title, systemImage: preset.systemIcon)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "photo.stack")
                                Text(selectedMediaPreset.title)
                                Image(systemName: "chevron.down")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.65))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }

                        Spacer()

                        // Record / Capture Simulator Action
                        Button {
                            if selectedMediaType == .video {
                                isSimulatingRecording.toggle()
                                if !isSimulatingRecording { recordSeconds = 0 }
                            } else {
                                // Simulate shutter flash
                            }
                        } label: {
                            Image(systemName: selectedMediaType == .video ? (isSimulatingRecording ? "stop.circle.fill" : "record.circle") : "camera.fill")
                                .font(.system(size: 20))
                                .foregroundColor(isSimulatingRecording ? AppTheme.accent : AppTheme.primary)
                                .padding(8)
                                .background(Color.black.opacity(0.65))
                                .clipShape(Circle())
                        }
                    }
                    .padding(10)

                    Spacer()
                }
            }

            // Quick Preset Thumbnail Strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MediaPreset.defaults.filter { $0.mediaType == selectedMediaType }) { preset in
                        Button {
                            selectedMediaPreset = preset
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(preset.gradientColors.first ?? .gray)
                                        .frame(width: 58, height: 44)

                                    Image(systemName: preset.systemIcon)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedMediaPreset.id == preset.id ? AppTheme.primary : Color.clear, lineWidth: 2)
                                )

                                Text(preset.title)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(selectedMediaPreset.id == preset.id ? AppTheme.primary : AppTheme.textSecondary)
                                    .frame(width: 62)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 3. Audio & Music Soundtrack Selection Bar
    private var audioTrackSelectorBar: some View {
        Button {
            showingAudioPicker = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: selectedAudio != nil ? "music.note" : "music.note.list")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("BACKGROUND AUDIO & SOUNDS")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(AppTheme.primary)
                            .tracking(1)

                        if selectedAudio != nil {
                            Text("ACTIVE")
                                .font(.system(size: 8, weight: .heavy))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(AppTheme.primary)
                                .foregroundColor(AppTheme.onPrimary)
                                .clipShape(Capsule())
                        }
                    }

                    if let audio = selectedAudio {
                        Text("\(audio.title) · \(audio.artist)")
                            .font(AppTheme.subheadlineFont)
                            .bold()
                            .foregroundColor(AppTheme.text)
                            .lineLimit(1)
                    } else {
                        Text("Add gym phonk, hardstyle, or hype workout music...")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textMuted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
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

    // MARK: - 4. Filter Style Picker
    private var filterStylePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PHOTO / VIDEO LOOK")
                .font(AppTheme.eyebrowFont)
                .foregroundColor(AppTheme.textSecondary)
                .tracking(1.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MediaFilterStyle.allCases) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(filter.badgeColor)
                                    .frame(width: 8, height: 8)
                                Text(filter.rawValue)
                                    .font(.system(size: 12, weight: selectedFilter == filter ? .bold : .medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(selectedFilter == filter ? AppTheme.surfaceRaised : AppTheme.surface)
                            .foregroundColor(selectedFilter == filter ? AppTheme.text : AppTheme.textSecondary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedFilter == filter ? filter.badgeColor : AppTheme.hairline, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - 5. Workout Details Form
    private var workoutDetailsForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WORKOUT SNAPSHOT")
                .font(AppTheme.eyebrowFont)
                .foregroundColor(AppTheme.textSecondary)
                .tracking(1.5)

            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(AppTheme.primary)
                        .frame(width: 20)

                    TextField("Body Split / Routine (e.g. Legs Hypertrophy)", text: $workoutFocus)
                        .font(AppTheme.subheadlineFont)
                        .foregroundColor(AppTheme.text)
                }
                .padding(10)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))

                HStack(spacing: 10) {
                    Image(systemName: "bolt.shield.fill")
                        .foregroundColor(athleteType.badgeColor)
                        .frame(width: 20)

                    TextField("Stats (e.g. 5 sets · 315 lbs · 12 reps)", text: $workoutStats)
                        .font(AppTheme.subheadlineFont)
                        .foregroundColor(AppTheme.text)
                }
                .padding(10)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))

                HStack(spacing: 10) {
                    Image(systemName: "textformat")
                        .foregroundColor(AppTheme.accent)
                        .frame(width: 20)

                    TextField("On-Screen Text Sticker (optional)", text: $textOverlay)
                        .font(AppTheme.subheadlineFont)
                        .foregroundColor(AppTheme.text)
                }
                .padding(10)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
            }
        }
    }

    // MARK: - 6. Caption Input Area
    private var captionInputArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CAPTION & NOTES")
                .font(AppTheme.eyebrowFont)
                .foregroundColor(AppTheme.textSecondary)
                .tracking(1.5)

            TextField("Write your caption, training takeaways, or call-outs...", text: $caption, axis: .vertical)
                .lineLimit(3...5)
                .padding(12)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                .foregroundColor(AppTheme.text)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                        .stroke(AppTheme.hairline, lineWidth: 1)
                )
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
