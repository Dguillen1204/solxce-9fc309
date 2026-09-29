// Models/MediaAndAudioModels.swift
import Foundation
import SwiftUI
import AVFoundation

// MARK: - Post Media Type
public enum PostMediaType: String, Codable, CaseIterable {
    case photo = "Photo"
    case video = "Video / Reel"

    public var iconName: String {
        switch self {
        case .photo: return "photo.on.rectangle.angled"
        case .video: return "video.fill"
        }
    }
}

// MARK: - Streaming Platform Source
public enum MusicService: String, Codable, CaseIterable, Identifiable {
    case appleMusic = "Apple Music"
    case spotify = "Spotify"
    case all = "All Platforms"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .appleMusic: return "apple.logo"
        case .spotify: return "waveform.circle.fill"
        case .all: return "music.note.list"
        }
    }

    public var brandColor: Color {
        switch self {
        case .appleMusic: return Color(red: 0.98, green: 0.22, blue: 0.35) // Apple Music Pink-Red
        case .spotify: return Color(red: 0.11, green: 0.84, blue: 0.38)    // Spotify Green
        case .all: return Color(red: 0.83, green: 1.0, blue: 0.25)       // Athletic Volt
        }
    }
}

// MARK: - Music Artist Model
public struct MusicArtist: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let genre: String
    public let monthlyListeners: String
    public let avatarIcon: String
    public let gradientColors: [String]
    public let isVerified: Bool

    public static let artists: [MusicArtist] = [
        MusicArtist(
            id: "drake",
            name: "Drake",
            genre: "Hip-Hop / Rap",
            monthlyListeners: "82.4M",
            avatarIcon: "person.crop.circle.fill",
            gradientColors: ["#1F1F1F", "#3A2A1A"],
            isVerified: true
        ),
        MusicArtist(
            id: "travis_scott",
            name: "Travis Scott",
            genre: "Trap / Hype",
            monthlyListeners: "68.9M",
            avatarIcon: "flame.circle.fill",
            gradientColors: ["#2C1A0D", "#5A2800"],
            isVerified: true
        ),
        MusicArtist(
            id: "eminem",
            name: "Eminem",
            genre: "Workout Rap",
            monthlyListeners: "71.2M",
            avatarIcon: "bolt.circle.fill",
            gradientColors: ["#1A1A1A", "#333333"],
            isVerified: true
        ),
        MusicArtist(
            id: "the_weeknd",
            name: "The Weeknd",
            genre: "Synthwave / R&B",
            monthlyListeners: "108.5M",
            avatarIcon: "moon.stars.fill",
            gradientColors: ["#2B0B14", "#66001B"],
            isVerified: true
        ),
        MusicArtist(
            id: "dvrst",
            name: "DVRST",
            genre: "Gym Phonk",
            monthlyListeners: "12.8M",
            avatarIcon: "car.side.fill",
            gradientColors: ["#0F1E2E", "#16385C"],
            isVerified: true
        ),
        MusicArtist(
            id: "tevez",
            name: "Tevez Athletic",
            genre: "Hardstyle / 200BPM",
            monthlyListeners: "5.4M",
            avatarIcon: "waveform.path.ecg",
            gradientColors: ["#290000", "#730000"],
            isVerified: true
        ),
        MusicArtist(
            id: "kanye_west",
            name: "Kanye West",
            genre: "Hip-Hop / Motivation",
            monthlyListeners: "64.1M",
            avatarIcon: "crown.fill",
            gradientColors: ["#1A1C23", "#2F3542"],
            isVerified: true
        ),
        MusicArtist(
            id: "taylor_swift",
            name: "Taylor Swift",
            genre: "Pop Cardio",
            monthlyListeners: "96.3M",
            avatarIcon: "sparkles",
            gradientColors: ["#261C2C", "#5C3D75"],
            isVerified: true
        ),
        MusicArtist(
            id: "dua_lipa",
            name: "Dua Lipa",
            genre: "Dance / Cardio",
            monthlyListeners: "74.8M",
            avatarIcon: "heart.circle.fill",
            gradientColors: ["#1C0F2B", "#4A154B"],
            isVerified: true
        ),
        MusicArtist(
            id: "fred_again",
            name: "Fred again..",
            genre: "Electronic / High-Energy",
            monthlyListeners: "19.6M",
            avatarIcon: "speaker.wave.3.fill",
            gradientColors: ["#0D2024", "#1B4D57"],
            isVerified: true
        ),
        MusicArtist(
            id: "cyberstride",
            name: "Cyberstride",
            genre: "Synthwave / Cardio",
            monthlyListeners: "3.2M",
            avatarIcon: "figure.run",
            gradientColors: ["#0A192F", "#00B4D8"],
            isVerified: true
        ),
        MusicArtist(
            id: "hans_zimmer",
            name: "Hans Zimmer",
            genre: "Epic Motivational / Score",
            monthlyListeners: "15.9M",
            avatarIcon: "theatermasks.fill",
            gradientColors: ["#141414", "#2E2E2E"],
            isVerified: true
        )
    ]
}

// MARK: - Background Audio / Music Track with Apple Music & Spotify metadata
public struct AudioTrack: Identifiable, Hashable, Codable {
    public let id: String
    public let title: String
    public let artist: String
    public let album: String
    public let durationSeconds: Int
    public let genre: String
    public let coverIcon: String
    public let bpm: Int
    public let isTrending: Bool
    public let platform: MusicService
    public let playsCount: String
    public let energyLevel: String // High Energy, Pump, Cardio, Zone 2, Focus

    public var durationFormatted: String {
        let mins = durationSeconds / 60
        let secs = durationSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    public static let library: [AudioTrack] = [
        // MARK: - Apple Music & Spotify Hype Hip Hop / Rap
        AudioTrack(
            id: "sicko_mode",
            title: "SICKO MODE",
            artist: "Travis Scott & Drake",
            album: "ASTROWORLD",
            durationSeconds: 312,
            genre: "Hype Hip Hop",
            coverIcon: "flame.fill",
            bpm: 155,
            isTrending: true,
            platform: .spotify,
            playsCount: "2.1B",
            energyLevel: "Max Pump"
        ),
        AudioTrack(
            id: "till_i_collapse",
            title: "'Till I Collapse",
            artist: "Eminem & Nate Dogg",
            album: "The Eminem Show",
            durationSeconds: 297,
            genre: "Hype Hip Hop",
            coverIcon: "bolt.fill",
            bpm: 171,
            isTrending: true,
            platform: .appleMusic,
            playsCount: "1.9B",
            energyLevel: "Max Pump"
        ),
        AudioTrack(
            id: "first_person_shooter",
            title: "First Person Shooter",
            artist: "Drake ft. J. Cole",
            album: "For All The Dogs",
            durationSeconds: 247,
            genre: "Hype Hip Hop",
            coverIcon: "target",
            bpm: 144,
            isTrending: true,
            platform: .appleMusic,
            playsCount: "540M",
            energyLevel: "High Energy"
        ),
        AudioTrack(
            id: "stronger",
            title: "Stronger",
            artist: "Kanye West",
            album: "Graduation",
            durationSeconds: 311,
            genre: "Hype Hip Hop",
            coverIcon: "crown.fill",
            bpm: 123,
            isTrending: true,
            platform: .spotify,
            playsCount: "1.4B",
            energyLevel: "Max Pump"
        ),
        AudioTrack(
            id: "fein",
            title: "FE!N",
            artist: "Travis Scott ft. Playboi Carti",
            album: "UTOPIA",
            durationSeconds: 191,
            genre: "Trap / Hype",
            coverIcon: "flame.circle.fill",
            bpm: 148,
            isTrending: true,
            platform: .spotify,
            playsCount: "820M",
            energyLevel: "Max Pump"
        ),
        AudioTrack(
            id: "lose_yourself",
            title: "Lose Yourself",
            artist: "Eminem",
            album: "8 Mile",
            durationSeconds: 326,
            genre: "Hype Hip Hop",
            coverIcon: "bolt.horizontal.fill",
            bpm: 171,
            isTrending: true,
            platform: .appleMusic,
            playsCount: "2.3B",
            energyLevel: "Max Pump"
        ),

        // MARK: - Gym Phonk & Hardstyle (High PR Lifting Beats)
        AudioTrack(
            id: "close_eyes_dvrst",
            title: "Close Eyes (Gym Phonk)",
            artist: "DVRST",
            album: "Close Eyes Phonk Edition",
            durationSeconds: 132,
            genre: "Gym Phonk",
            coverIcon: "car.side.fill",
            bpm: 160,
            isTrending: true,
            platform: .spotify,
            playsCount: "680M",
            energyLevel: "PR Overload"
        ),
        AudioTrack(
            id: "phonk_rage",
            title: "Midnight Rage (Drift Phonk)",
            artist: "KSLV & DVRST Mix",
            album: "Drift Phonk Essentials",
            durationSeconds: 145,
            genre: "Gym Phonk",
            coverIcon: "bolt.fill",
            bpm: 160,
            isTrending: true,
            platform: .appleMusic,
            playsCount: "310M",
            energyLevel: "PR Overload"
        ),
        AudioTrack(
            id: "hardstyle_overload",
            title: "PR Overload 200BPM",
            artist: "Tevez Athletic",
            album: "Iron Temple Hardstyle",
            durationSeconds: 180,
            genre: "Hardstyle",
            coverIcon: "waveform.path.ecg",
            bpm: 200,
            isTrending: true,
            platform: .spotify,
            playsCount: "94M",
            energyLevel: "PR Overload"
        ),
        AudioTrack(
            id: "zyzz_legacy",
            title: "Tribute to Aesthetics (Tevez Mix)",
            artist: "Tevez Athletic",
            album: "Aesthetics Unleashed",
            durationSeconds: 215,
            genre: "Hardstyle",
            coverIcon: "figure.strengthtraining.traditional",
            bpm: 195,
            isTrending: true,
            platform: .spotify,
            playsCount: "115M",
            energyLevel: "PR Overload"
        ),

        // MARK: - Synthwave, Electronic & Cardio Cadence
        AudioTrack(
            id: "blinding_lights",
            title: "Blinding Lights",
            artist: "The Weeknd",
            album: "After Hours",
            durationSeconds: 200,
            genre: "Synthwave / Cardio",
            coverIcon: "sparkles",
            bpm: 171,
            isTrending: true,
            platform: .appleMusic,
            playsCount: "4.2B",
            energyLevel: "Cardio Cadence"
        ),
        AudioTrack(
            id: "delilah",
            title: "Delilah (pull me out of this)",
            artist: "Fred again..",
            album: "Actual Life 3",
            durationSeconds: 250,
            genre: "Dance / Electronic",
            coverIcon: "speaker.wave.3.fill",
            bpm: 134,
            isTrending: true,
            platform: .spotify,
            playsCount: "210M",
            energyLevel: "High Energy"
        ),
        AudioTrack(
            id: "levitating",
            title: "Levitating",
            artist: "Dua Lipa",
            album: "Future Nostalgia",
            durationSeconds: 203,
            genre: "Dance / Cardio",
            coverIcon: "heart.fill",
            bpm: 103,
            isTrending: false,
            platform: .appleMusic,
            playsCount: "1.8B",
            energyLevel: "Cardio Cadence"
        ),
        AudioTrack(
            id: "dark_synthwave_run",
            title: "Neon Horizon 10K",
            artist: "Cyberstride",
            album: "Midnight Runner 2099",
            durationSeconds: 210,
            genre: "Synthwave / Cardio",
            coverIcon: "figure.run",
            bpm: 175,
            isTrending: false,
            platform: .spotify,
            playsCount: "42M",
            energyLevel: "Cardio Cadence"
        ),
        AudioTrack(
            id: "cruel_summer",
            title: "Cruel Summer",
            artist: "Taylor Swift",
            album: "Lover",
            durationSeconds: 178,
            genre: "Pop Cardio",
            coverIcon: "sun.max.fill",
            bpm: 170,
            isTrending: true,
            platform: .appleMusic,
            playsCount: "1.6B",
            energyLevel: "Cardio Cadence"
        ),

        // MARK: - Epic Motivational & Lo-Fi Recovery
        AudioTrack(
            id: "time_inception",
            title: "Time (Solxce Epic Remix)",
            artist: "Hans Zimmer",
            album: "Inception OST",
            durationSeconds: 275,
            genre: "Epic Motivational",
            coverIcon: "theatermasks.fill",
            bpm: 130,
            isTrending: true,
            platform: .appleMusic,
            playsCount: "450M",
            energyLevel: "Mindset"
        ),
        AudioTrack(
            id: "epic_orchestral",
            title: "Legends Never Rest",
            artist: "Cinematic Core",
            album: "Valkyrie Ascendant",
            durationSeconds: 220,
            genre: "Epic Motivational",
            coverIcon: "trophy.fill",
            bpm: 132,
            isTrending: true,
            platform: .spotify,
            playsCount: "78M",
            energyLevel: "Mindset"
        ),
        AudioTrack(
            id: "lofi_focus_recovery",
            title: "Deep Stretch & Hydrate",
            artist: "Chilled Cow Athlete",
            album: "Recovery Beats Vol. 4",
            durationSeconds: 195,
            genre: "Lo-Fi Focus",
            coverIcon: "leaf.fill",
            bpm: 85,
            isTrending: false,
            platform: .spotify,
            playsCount: "65M",
            energyLevel: "Zone 2 / Recovery"
        ),
        AudioTrack(
            id: "industrial_bass",
            title: "Iron Temple Bass Drop",
            artist: "Valhalla Audio",
            album: "Raw Power",
            durationSeconds: 130,
            genre: "Industrial",
            coverIcon: "dumbbell.fill",
            bpm: 150,
            isTrending: false,
            platform: .appleMusic,
            playsCount: "38M",
            energyLevel: "Max Pump"
        )
    ]
}

// MARK: - Post Media Preset / Filter
public enum MediaFilterStyle: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case highContrast = "Volt Grit"
    case midnight = "Midnight Dark"
    case warmGlow = "Warm Pump"
    case blackAndWhite = "Monochrome Iron"

    public var id: String { rawValue }

    public var badgeColor: Color {
        switch self {
        case .normal: return .gray
        case .highContrast: return Color(red: 0.831, green: 1.0, blue: 0.247)
        case .midnight: return Color(red: 0.38, green: 0.55, blue: 1.0)
        case .warmGlow: return Color(red: 1.0, green: 0.45, blue: 0.2)
        case .blackAndWhite: return .white
        }
    }
}

// MARK: - Sample Video & Picture Presets for Creation
public struct MediaPreset: Identifiable {
    public let id: String
    public let title: String
    public let mediaType: PostMediaType
    public let systemIcon: String
    public let gradientColors: [Color]
    public let workoutContext: String

    public static let defaults: [MediaPreset] = [
        MediaPreset(
            id: "squat_pr_vid",
            title: "405 lbs Squat Double",
            mediaType: .video,
            systemIcon: "figure.strengthtraining.traditional",
            gradientColors: [Color(red: 0.15, green: 0.05, blue: 0.05), Color(red: 0.35, green: 0.1, blue: 0.1)],
            workoutContext: "Heavy Squat Form Check"
        ),
        MediaPreset(
            id: "tempo_run_vid",
            title: "Sub-20 5K Sunset Tempo",
            mediaType: .video,
            systemIcon: "figure.run",
            gradientColors: [Color(red: 0.05, green: 0.15, blue: 0.25), Color(red: 0.1, green: 0.3, blue: 0.4)],
            workoutContext: "Trail Cadence 178 SPM"
        ),
        MediaPreset(
            id: "bench_drop_pic",
            title: "Bench Pump & Lockout",
            mediaType: .photo,
            systemIcon: "dumbbell.fill",
            gradientColors: [Color(red: 0.1, green: 0.1, blue: 0.1), Color(red: 0.2, green: 0.25, blue: 0.1)],
            workoutContext: "Chest & Triceps Finisher"
        ),
        MediaPreset(
            id: "crossfit_wod_vid",
            title: "Murph WOD Time Cap",
            mediaType: .video,
            systemIcon: "flame.fill",
            gradientColors: [Color(red: 0.25, green: 0.1, blue: 0.0), Color(red: 0.45, green: 0.15, blue: 0.0)],
            workoutContext: "100 Pullups · 200 Pushups"
        ),
        MediaPreset(
            id: "physique_check_pic",
            title: "Post-Workout Macro Check",
            mediaType: .photo,
            systemIcon: "figure.arms.open",
            gradientColors: [Color(red: 0.15, green: 0.05, blue: 0.25), Color(red: 0.25, green: 0.1, blue: 0.35)],
            workoutContext: "Hypertrophy Progress"
        ),
        MediaPreset(
            id: "calisthenics_vid",
            title: "Full Planche Hold 8s",
            mediaType: .video,
            systemIcon: "figure.gymnastics",
            gradientColors: [Color(red: 0.05, green: 0.2, blue: 0.15), Color(red: 0.1, green: 0.35, blue: 0.25)],
            workoutContext: "Strict Calisthenics Static"
        )
    ]
}
