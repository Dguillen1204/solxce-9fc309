// Views/AudioPickerSheet.swift
import SwiftUI

struct AudioPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAudio: AudioTrack?

    @State private var searchQuery: String = ""
    @State private var playingAudioId: String? = nil
    @State private var selectedPlatform: MusicService = .all
    @State private var selectedGenre: String = "All"
    @State private var selectedArtist: MusicArtist? = nil
    @State private var activeTab: MusicBrowseTab = .allTracks

    enum MusicBrowseTab: String, CaseIterable, Identifiable {
        case allTracks = "Top Hits"
        case artists = "Artists"
        case gymPlaylists = "Gym Sets"

        var id: String { rawValue }

        var iconName: String {
            switch self {
            case .allTracks: return "music.note"
            case .artists: return "person.2.fill"
            case .gymPlaylists: return "flame.fill"
            }
        }
    }

    let genres = [
        "All",
        "Hype Hip Hop",
        "Gym Phonk",
        "Hardstyle",
        "Synthwave / Cardio",
        "Dance / Electronic",
        "Pop Cardio",
        "Epic Motivational",
        "Lo-Fi Focus"
    ]

    var filteredTracks: [AudioTrack] {
        AudioTrack.library.filter { track in
            // Platform filter (Apple Music vs Spotify vs All)
            let matchesPlatform: Bool
            if selectedPlatform == .all {
                matchesPlatform = true
            } else {
                matchesPlatform = track.platform == selectedPlatform
            }

            // Genre filter
            let matchesGenre = (selectedGenre == "All" || track.genre == selectedGenre)

            // Artist filter (if selected)
            let matchesArtist: Bool
            if let artist = selectedArtist {
                matchesArtist = track.artist.localizedCaseInsensitiveContains(artist.name)
            } else {
                matchesArtist = true
            }

            // Search query
            let matchesSearch = searchQuery.isEmpty ||
                track.title.localizedCaseInsensitiveContains(searchQuery) ||
                track.artist.localizedCaseInsensitiveContains(searchQuery) ||
                track.album.localizedCaseInsensitiveContains(searchQuery) ||
                track.genre.localizedCaseInsensitiveContains(searchQuery) ||
                track.energyLevel.localizedCaseInsensitiveContains(searchQuery)

            return matchesPlatform && matchesGenre && matchesArtist && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Streaming Service Platform Selector (Apple Music & Spotify)
                platformSelectorHeader

                // 2. Search Field with Apple Music / Spotify indicator
                searchBarView

                // 3. Tab Bar (Top Hits, Artists, Gym Sets)
                browseTabsPicker

                // 4. Main Body Content based on Tab
                if activeTab == .artists && selectedArtist == nil {
                    artistsGridView
                } else {
                    tracksListView
                }
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Music & Sounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(AppTheme.headlineFont)
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Streaming Platform Header Selector
    private var platformSelectorHeader: some View {
        HStack(spacing: 8) {
            ForEach(MusicService.allCases) { service in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPlatform = service
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: service.iconName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(selectedPlatform == service ? (service == .appleMusic ? .white : (service == .spotify ? .black : AppTheme.onPrimary)) : service.brandColor)

                        Text(service.rawValue)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(selectedPlatform == service ? (service == .appleMusic ? .white : (service == .spotify ? .black : AppTheme.onPrimary)) : AppTheme.text)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedPlatform == service ?
                        service.brandColor :
                        AppTheme.surface
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radii.tag)
                            .stroke(selectedPlatform == service ? Color.clear : AppTheme.hairline, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.screenMargin)
        .padding(.top, 10)
    }

    // MARK: - Search Bar View
    private var searchBarView: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondary)

            TextField(
                selectedPlatform == .appleMusic ? "Search Apple Music catalog & artists..." :
                (selectedPlatform == .spotify ? "Search Spotify charts & tracks..." : "Search all music, artists, albums, phonk..."),
                text: $searchQuery
            )
            .font(AppTheme.bodyFont)
            .foregroundColor(AppTheme.text)
            .autocorrectionDisabled()

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
    }

    // MARK: - Browse Tabs
    private var browseTabsPicker: some View {
        HStack(spacing: 0) {
            ForEach(MusicBrowseTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        activeTab = tab
                        if tab != .artists {
                            selectedArtist = nil
                        }
                    }
                } label: {
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 12, weight: .bold))
                            Text(tab.rawValue)
                                .font(.system(size: 13, weight: activeTab == tab ? .bold : .medium))
                        }
                        .foregroundColor(activeTab == tab ? AppTheme.text : AppTheme.textSecondary)
                        .padding(.top, 10)

                        Rectangle()
                            .fill(activeTab == tab ? AppTheme.primary : Color.clear)
                            .frame(height: 2.5)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.screenMargin)
        .background(AppTheme.ground)
    }

    // MARK: - Artists Grid View
    private var artistsGridView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("FEATURED ATHLETE ARTISTS")
                        .font(AppTheme.eyebrowFont)
                        .foregroundColor(AppTheme.primary)
                        .tracking(1.2)
                    Spacer()
                    Text("Apple Music & Spotify")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, 12)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(MusicArtist.artists) { artist in
                        Button {
                            selectedArtist = artist
                            activeTab = .allTracks
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.surfaceRaised)
                                        .frame(width: 46, height: 46)

                                    Image(systemName: artist.avatarIcon)
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.primary)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 4) {
                                        Text(artist.name)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(AppTheme.text)
                                            .lineLimit(1)

                                        if artist.isVerified {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(Color.blue)
                                        }
                                    }

                                    Text(artist.genre)
                                        .font(.system(size: 11))
                                        .foregroundColor(AppTheme.textSecondary)
                                        .lineLimit(1)

                                    Text("\(artist.monthlyListeners) listeners")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(AppTheme.textMuted)
                                }

                                Spacer(minLength: 0)
                            }
                            .padding(10)
                            .background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                                    .stroke(AppTheme.hairline, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Tracks List View
    private var tracksListView: some View {
        VStack(spacing: 0) {
            // Filter banner if artist is selected
            if let artist = selectedArtist {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(AppTheme.primary)
                        Text("Showing catalog for: ")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                        Text(artist.name)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.text)
                    }

                    Spacer()

                    Button {
                        selectedArtist = nil
                    } label: {
                        Text("Clear")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.vertical, 8)
                .background(AppTheme.surface)
            }

            // Genre Horizontal Rail
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
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.vertical, 10)
            }

            // Currently Selected Track Banner
            if let selected = selectedAudio {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(selected.platform.brandColor.opacity(0.2))
                            .frame(width: 32, height: 32)
                        Image(systemName: selected.platform.iconName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(selected.platform.brandColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("ACTIVE SOUNDTRACK")
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(AppTheme.primary)
                                .tracking(1)

                            Text("• \(selected.platform.rawValue)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(selected.platform.brandColor)
                        }

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

            // List of Tracks
            List {
                if filteredTracks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 38))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("No matching songs found")
                            .font(AppTheme.headlineFont)
                            .foregroundColor(AppTheme.text)
                        Text("Try searching another artist, gym genre, or select All Platforms.")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredTracks) { track in
                        trackRow(track)
                            .listRowBackground(AppTheme.ground)
                            .listRowSeparatorTint(AppTheme.hairline)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Track Row Component
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

                HStack(spacing: 5) {
                    // Platform badge
                    HStack(spacing: 2) {
                        Image(systemName: track.platform.iconName)
                            .font(.system(size: 9))
                        Text(track.platform == .appleMusic ? "Apple" : "Spotify")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(track.platform.brandColor.opacity(0.18))
                    .foregroundColor(track.platform.brandColor)
                    .clipShape(RoundedRectangle(cornerRadius: 3))

                    Text(track.artist)
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)

                    Text("•")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)

                    Text("\(track.bpm) BPM")
                        .font(AppTheme.monoFont)
                        .foregroundColor(AppTheme.primary)

                    Text("•")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textMuted)

                    Text(track.energyLevel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
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
