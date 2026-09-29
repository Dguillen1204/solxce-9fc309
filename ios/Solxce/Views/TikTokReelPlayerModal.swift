// Views/TikTokReelPlayerModal.swift
import SwiftUI

struct TikTokReelPlayerModal: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var post: AthletePost
    var onAddComment: (PostComment) -> Void

    @State private var isPlaying: Bool = true
    @State private var isMuted: Bool = false
    @State private var videoProgress: Double = 0.35
    @State private var showHeartBurst: Bool = false
    @State private var showCommentsOverlay: Bool = false
    @State private var commentText: String = ""

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Immersive Dark Background
            Color.black.ignoresSafeArea()

            // Main Media Viewport (9:16 Full Screen Video / Picture style)
            ZStack {
                LinearGradient(
                    colors: [
                        post.gradientColors.first ?? Color(red: 0.1, green: 0.1, blue: 0.15),
                        post.gradientColors.last ?? Color(red: 0.2, green: 0.05, blue: 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Animated Video Simulation Visualizer
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(post.athleteType.badgeColor.opacity(0.15))
                            .frame(width: 140, height: 140)
                            .scaleEffect(isPlaying ? 1.08 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPlaying)

                        Image(systemName: post.mediaIconName)
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(post.athleteType.badgeColor)
                    }

                    if post.mediaType == .video {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppTheme.accent)
                                .frame(width: 8, height: 8)
                            Text(isPlaying ? "PLAYING 4K VIDEO" : "PAUSED")
                                .font(AppTheme.eyebrowFont)
                                .foregroundColor(.white)
                                .tracking(1.5)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    }

                    // On-screen custom text sticker overlay if present
                    if let stickerText = post.textOverlay, !stickerText.isEmpty {
                        Text(stickerText)
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.primary, lineWidth: 2)
                            )
                            .shadow(color: AppTheme.primary.opacity(0.4), radius: 8)
                    }
                }

                // Double tap heart burst animation
                if showHeartBurst {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 100))
                        .foregroundColor(AppTheme.accent)
                        .scaleEffect(1.2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showHeartBurst = true
                    if !post.isLiked {
                        post.isLiked = true
                        post.likesCount += 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation { showHeartBurst = false }
                }
            }
            .onTapGesture(count: 1) {
                isPlaying.toggle()
            }

            // Top Bar Controls (Close, Sound indicator)
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Audio Pill in top header
                    if let audio = post.audioTrack {
                        HStack(spacing: 6) {
                            EqualizerAnimationView()
                                .frame(width: 14, height: 12)
                                .foregroundColor(AppTheme.primary)

                            Text("\(audio.title) · \(audio.artist)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .frame(maxWidth: 180, alignment: .leading)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    Button {
                        isMuted.toggle()
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, 16)

                Spacer()
            }

            // Right Action Rail (TikTok / Reels layout)
            HStack {
                Spacer()

                VStack(spacing: 20) {
                    Spacer()

                    // Athlete Profile Avatar
                    ZStack {
                        Circle()
                            .stroke(post.athleteType.badgeColor, lineWidth: 2)
                            .frame(width: 48, height: 48)

                        Circle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 44, height: 44)

                        Image(systemName: post.athleteType.iconName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(post.athleteType.badgeColor)
                    }

                    // Like Button
                    Button {
                        withAnimation(.spring()) {
                            post.isLiked.toggle()
                            post.likesCount += post.isLiked ? 1 : -1
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: post.isLiked ? "heart.fill" : "heart.fill")
                                .font(.system(size: 28))
                                .foregroundColor(post.isLiked ? AppTheme.accent : .white)
                            Text("\(post.likesCount)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    // Comments Button
                    Button {
                        showCommentsOverlay = true
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "bubble.right.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                            Text("\(post.comments.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    // Share Button
                    Button {
                        // Demo action feedback
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                            Text("Share")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }

                    // Rotating Vinyl Sound Disc (TikTok style)
                    if let audio = post.audioTrack {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle().stroke(AppTheme.primary, lineWidth: 2)
                                )

                            Image(systemName: "music.note")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.primary)
                        }
                    }

                    Spacer().frame(height: 30)
                }
                .padding(.trailing, 16)
            }

            // Bottom Caption & Creator Info
            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    // Creator Handle & Athlete Archetype Badge
                    HStack(spacing: 8) {
                        Text("@\(post.authorHandle)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 3) {
                            Image(systemName: post.athleteType.iconName)
                                .font(.system(size: 10, weight: .bold))
                            Text(post.athleteType.shortTag)
                                .font(.system(size: 9, weight: .black))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2.5)
                        .background(post.athleteType.badgeColor.opacity(0.3))
                        .foregroundColor(post.athleteType.badgeColor)
                        .clipShape(Capsule())

                        Text(post.workoutTag)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(AppTheme.primary.opacity(0.3))
                            .foregroundColor(AppTheme.primary)
                            .clipShape(Capsule())
                    }

                    // Caption
                    Text(post.caption)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    // Audio Track Marquee
                    if let audio = post.audioTrack {
                        HStack(spacing: 6) {
                            Image(systemName: "music.note")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.primary)

                            Text("\(audio.title) · \(audio.artist)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }

                    // Video Scrubbing Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 3)

                            Capsule()
                                .fill(AppTheme.primary)
                                .frame(width: geo.size.width * videoProgress, height: 3)
                        }
                    }
                    .frame(height: 3)
                    .padding(.top, 4)
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.bottom, 24)
                .padding(.trailing, 70) // Avoid overlap with right action buttons
            }
        }
        .onReceive(timer) { _ in
            if isPlaying {
                videoProgress += 0.015
                if videoProgress >= 1.0 {
                    videoProgress = 0.0
                }
            }
        }
        .sheet(isPresented: $showCommentsOverlay) {
            PostCommentsSheet(post: $post, onAddComment: onAddComment)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Post Comments Sheet
struct PostCommentsSheet: View {
    @Binding var post: AthletePost
    var onAddComment: (PostComment) -> Void
    @State private var commentInput: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    ForEach(post.comments) { comment in
                        HStack(alignment: .top, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.surfaceRaised)
                                    .frame(width: 32, height: 32)

                                if let type = comment.athleteType {
                                    Image(systemName: type.iconName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(type.badgeColor)
                                } else {
                                    Text(comment.author.prefix(1).uppercased())
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(AppTheme.primary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(comment.author)
                                        .font(AppTheme.subheadlineFont)
                                        .bold()
                                        .foregroundColor(AppTheme.text)
                                    Spacer()
                                    Text(comment.timeAgo)
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(AppTheme.textMuted)
                                }
                                Text(comment.text)
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.text)
                            }
                        }
                        .listRowBackground(AppTheme.surface)
                        .listRowSeparatorTint(AppTheme.hairline)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                // Composer
                HStack(spacing: 8) {
                    TextField("Add a comment...", text: $commentInput)
                        .padding(10)
                        .background(AppTheme.field)
                        .clipShape(Capsule())
                        .foregroundColor(AppTheme.text)

                    Button {
                        guard !commentInput.isEmpty else { return }
                        let newC = PostComment(
                            author: "you",
                            athleteType: .hybrid,
                            text: commentInput,
                            timeAgo: "Just now"
                        )
                        onAddComment(newC)
                        commentInput = ""
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(AppTheme.onPrimary)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                    }
                    .disabled(commentInput.isEmpty)
                }
                .padding(10)
                .background(AppTheme.surface)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Comments (\(post.comments.count))")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}
