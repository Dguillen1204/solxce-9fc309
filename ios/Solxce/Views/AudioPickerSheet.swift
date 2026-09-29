// Views/AudioPickerSheet.swift
import SwiftUI

struct AudioPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAudio: AudioTrack?

    @State private var searchQuery: String = ""
    @State private var playingAudioId: String? = nil
    @State private var selectedGenre: String = "All"

    let genres = ["All", "Gym Phonk", "Hardstyle", "Hype Hip Hop", "Synthwave / Cardio", "Lo-Fi Focus", "Epic Motivational"]

    var filteredTracks: [AudioTrack] {
        AudioTrack.library.filter { track in
            let matchesGenre = (selectedGenre == "All" || track.genre == selectedGenre)
            let matchesSearch = searchQuery.isEmpty ||
                track.title.localizedCaseInsensitiveContains(searchQuery) ||
                track.artist.localizedCaseInsensitiveContains(searchQuery) ||
                track.genre.localizedCaseInsensitiveContains(searchQuery)
            return matchesGenre && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.textSecondary)

                    TextField("Search gym music, phonk, hardstyle, beats...", text: $searchQuery)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.text)

                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                .padding(10)
                .background(AppTheme.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, 10)

                // Genre Pills Rail
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres, id: \.self) { genre in
                            Button {
                                selectedGenre = genre
                            } label: {
                                Text(genre)
                                    .font(.system(size: 12, weight: selectedGenre == genre ? .bold : .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedGenre == genre ? AppTheme.primary : AppTheme.surface)
                                    .foregroundColor(selectedGenre == genre ? AppTheme.onPrimary : AppTheme.text)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedGenre == genre ? Color.clear : AppTheme.hairline, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.screenMargin)
                    .padding(.vertical, 10)
                }

                // Currently selected audio header banner (if chosen)
                if let selected = selectedAudio {
                    HStack(spacing: 12) {
                        Image(systemName: "music.note")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("ACTIVE SOUNDTRACK")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(AppTheme.primary)
                                .tracking(1)
                            Text("\(selected.title) · \(selected.artist)")
                                .font(AppTheme.captionFont)
                                .bold()
                                .foregroundColor(AppTheme.text)
                                .lineLimit(1)
                        }

                        Spacer()

                        Button {
                            selectedAudio = nil
                        } label: {
                            Text("Remove")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                    .padding(10)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radii.tag)
                            .stroke(AppTheme.primary.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal, AppTheme.Spacing.screenMargin)
                    .padding(.bottom, 6)
                }

                // Track List
                List {
                    ForEach(filteredTracks) { track in
                        trackRow(track)
                            .listRowBackground(AppTheme.ground)
                            .listRowSeparatorTint(AppTheme.hairline)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Add Audio & Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppTheme.headlineFont)
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Track Row
    private func trackRow(_ track: AudioTrack) -> some View {
        HStack(spacing: 12) {
            // Play / Waveform indicator
            Button {
                if playingAudioId == track.id {
                    playingAudioId = nil
                } else {
                    playingAudioId = track.id
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(playingAudioId == track.id ? AppTheme.primary : AppTheme.surfaceRaised)
                        .frame(width: 44, height: 44)

                    if playingAudioId == track.id {
                        EqualizerAnimationView()
                            .frame(width: 20, height: 16)
                            .foregroundColor(AppTheme.onPrimary)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.text)
                            .offset(x: 1.5)
                    }
                }
            }
            .buttonStyle(.plain)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(track.title)
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.text)
                        .lineLimit(1)

                    if track.isTrending {
                        Text("TRENDING")
                            .font(.system(size: 8, weight: .black))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1.5)
                            .background(AppTheme.accent.opacity(0.2))
                            .foregroundColor(AppTheme.accent)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 6) {
                    Text(track.artist)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)

                    Text("•")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)

                    Text("\(track.bpm) BPM")
                        .font(AppTheme.monoFont)
                        .foregroundColor(AppTheme.primary)

                    Text("•")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)

                    Text(track.durationFormatted)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Spacer()

            // Choose Button
            Button {
                selectedAudio = track
                dismiss()
            } label: {
                Text(selectedAudio?.id == track.id ? "Selected" : "Use")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(selectedAudio?.id == track.id ? AppTheme.primary : AppTheme.surfaceRaised)
                    .foregroundColor(selectedAudio?.id == track.id ? AppTheme.onPrimary : AppTheme.text)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(selectedAudio?.id == track.id ? Color.clear : AppTheme.hairline, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Animated Equalizer View
struct EqualizerAnimationView: View {
    @State private var bar1: CGFloat = 0.4
    @State private var bar2: CGFloat = 0.8
    @State private var bar3: CGFloat = 0.6
    @State private var bar4: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 2) {
            Rectangle().frame(width: 3, height: 16 * bar1)
            Rectangle().frame(width: 3, height: 16 * bar2)
            Rectangle().frame(width: 3, height: 16 * bar3)
            Rectangle().frame(width: 3, height: 16 * bar4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                bar1 = 1.0
                bar2 = 0.3
                bar3 = 0.9
                bar4 = 0.4
            }
        }
    }
}
