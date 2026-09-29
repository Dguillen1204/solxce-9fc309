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

// MARK: - Background Audio / Music Track
public struct AudioTrack: Identifiable, Hashable, Codable {
    public let id: String
    public let title: String
    public let artist: String
    public let durationSeconds: Int
    public let genre: String
    public let coverIcon: String
    public let bpm: Int
    public let isTrending: Bool

    public var durationFormatted: String {
        let mins = durationSeconds / 60
        let secs = durationSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    public static let library: [AudioTrack] = [
        AudioTrack(
            id: "phonk_rage",
            title: "Midnight Rage (Drift Phonk)",
            artist: "KSLV & DVRST Mix",
            durationSeconds: 145,
            genre: "Gym Phonk",
            coverIcon: "bolt.fill",
            bpm: 160,
            isTrending: true
        ),
        AudioTrack(
            id: "hardstyle_overload",
            title: "PR Overload 200BPM",
            artist: "Tevez Athletic",
            durationSeconds: 180,
            genre: "Hardstyle",
            coverIcon: "flame.fill",
            bpm: 200,
            isTrending: true
        ),
        AudioTrack(
            id: "beast_mode_hiphop",
            title: "Unstoppable Engine",
            artist: "Trap City Beatmasters",
            durationSeconds: 162,
            genre: "Hype Hip Hop",
            coverIcon: "speaker.wave.3.fill",
            bpm: 140,
            isTrending: true
        ),
        AudioTrack(
            id: "dark_synthwave_run",
            title: "Neon Horizon 10K",
            artist: "Cyberstride",
            durationSeconds: 210,
            genre: "Synthwave / Cardio",
            coverIcon: "figure.run",
            bpm: 175,
            isTrending: false
        ),
        AudioTrack(
            id: "lofi_focus_recovery",
            title: "Deep Stretch & Hydrate",
            artist: "Chilled Cow Athlete",
            durationSeconds: 195,
            genre: "Lo-Fi Focus",
            coverIcon: "leaf.fill",
            bpm: 85,
            isTrending: false
        ),
        AudioTrack(
            id: "industrial_bass",
            title: "Iron Temple Bass Drop",
            artist: "Valhalla Audio",
            durationSeconds: 130,
            genre: "Industrial",
            coverIcon: "dumbbell.fill",
            bpm: 150,
            isTrending: false
        ),
        AudioTrack(
            id: "epic_orchestral",
            title: "Legends Never Rest",
            artist: "Cinematic Core",
            durationSeconds: 220,
            genre: "Epic Motivational",
            coverIcon: "trophy.fill",
            bpm: 132,
            isTrending: true
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
