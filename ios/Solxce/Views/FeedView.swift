// Views/FeedView.swift
import SwiftUI
import SwiftData

// MARK: - Local Feed Fixture Model
public struct AthletePost: Identifiable {
    public let id = UUID()
    public let authorName: String
    public let authorHandle: String
    public let athleteType: AthleteType
    public let timeAgo: String
    public let workoutTag: String
    public let workoutStats: String
    public var caption: String
    public let imageName: String
    public var mediaType: PostMediaType = .video
    public var mediaIconName: String = "figure.strengthtraining.traditional"
    public var gradientColors: [Color] = [Color(red: 0.15, green: 0.05, blue: 0.05), Color(red: 0.35, green: 0.1, blue: 0.1)]
    public var audioTrack: AudioTrack? = AudioTrack.library.first
    public var textOverlay: String? = nil
    public var likesCount: Int
    public var isLiked: Bool
    public var comments: [PostComment]

    public init(
        authorName: String,
        authorHandle: String,
        athleteType: AthleteType,
        timeAgo: String,
        workoutTag: String,
        workoutStats: String,
        caption: String,
        imageName: String,
        mediaType: PostMediaType = .video,
        mediaIconName: String = "figure.strengthtraining.traditional",
        gradientColors: [Color] = [Color(red: 0.15, green: 0.05, blue: 0.05), Color(red: 0.35, green: 0.1, blue: 0.1)],
        audioTrack: AudioTrack? = AudioTrack.library.first,
        textOverlay: String? = nil,
        likesCount: Int,
        isLiked: Bool,
        comments: [PostComment]
    ) {
        self.authorName = authorName
        self.authorHandle = authorHandle
        self.athleteType = athleteType
        self.timeAgo = timeAgo
        self.workoutTag = workoutTag
        self.workoutStats = workoutStats
        self.caption = caption
        self.imageName = imageName
        self.mediaType = mediaType
        self.mediaIconName = mediaIconName
        self.gradientColors = gradientColors
        self.audioTrack = audioTrack
        self.textOverlay = textOverlay
        self.likesCount = likesCount
        self.isLiked = isLiked
        self.comments = comments
    }
}

public struct PostComment: Identifiable {
    public let id = UUID()
    public let author: String
    public let athleteType: AthleteType?
    public let text: String
    public let timeAgo: String

    public init(author: String, athleteType: AthleteType?, text: String, timeAgo: String) {
        self.author = author
        self.athleteType = athleteType
        self.text = text
        self.timeAgo = timeAgo
    }
}

public struct AthleteStory: Identifiable {
    public let id = UUID()
    public let name: String
    public let athleteType: AthleteType
    public let hasUnseen: Bool
    public let tag: String

    public init(name: String, athleteType: AthleteType, hasUnseen: Bool, tag: String) {
        self.name = name
        self.athleteType = athleteType
        self.hasUnseen = hasUnseen
        self.tag = tag
    }
}

struct FeedView: View {
    @Query private var userProfiles: [UserProfile]

    var currentUserProfile: UserProfile? {
        userProfiles.first
    }

    var currentUserAthleteType: AthleteType {
        currentUserProfile?.athleteType ?? .hybrid
    }

    var currentUserName: String {
        currentUserProfile?.fullName ?? "You"
    }

    var currentUserHandle: String {
        currentUserProfile?.handle ?? "solxce_athlete"
    }

    @State private var posts: [AthletePost] = [
        AthletePost(
            authorName: "Marcus Vance",
            authorHandle: "marcus_lifts",
            athleteType: .powerlifter,
            timeAgo: "2h ago",
            workoutTag: "CHEST & TRICEPS",
            workoutStats: "6 exercises · 22 sets · 18,400 lbs volume",
            caption: "New PR on bench today! 315 lbs for a clean double. Feeling dialed in with the split.",
            imageName: "dumbbell.fill",
            mediaType: .video,
            mediaIconName: "figure.strengthtraining.traditional",
            gradientColors: [Color(red: 0.25, green: 0.05, blue: 0.05), Color(red: 0.45, green: 0.1, blue: 0.1)],
            audioTrack: AudioTrack.library[0],
            textOverlay: "315 LBS BENCH DOUBLE 🔥",
            likesCount: 142,
            isLiked: false,
            comments: [
                PostComment(author: "elena_runs", athleteType: .runner, text: "Insane bench numbers man! Clean form 🔥", timeAgo: "1h ago"),
                PostComment(author: "coach_dave", athleteType: .functional, text: "Chest drive looking sharp. Keep recovering well.", timeAgo: "45m ago")
            ]
        ),
        AthletePost(
            authorName: "Elena Rostova",
            authorHandle: "elena_runs",
            athleteType: .runner,
            timeAgo: "4h ago",
            workoutTag: "TEMPO RUN",
            workoutStats: "6.20 mi · 44:18 · 7'08\" /mi pace",
            caption: "Early 10K around the bay before sunrise. Crisp morning air and steady cadence throughout.",
            imageName: "figure.run",
            mediaType: .video,
            mediaIconName: "figure.run",
            gradientColors: [Color(red: 0.05, green: 0.15, blue: 0.3), Color(red: 0.1, green: 0.3, blue: 0.5)],
            audioTrack: AudioTrack.library[10], // The Weeknd - Blinding Lights (Apple Music)
            textOverlay: "SUB-45 10K SUNSET ⚡",
            likesCount: 89,
            isLiked: true,
            comments: [
                PostComment(author: "marcus_lifts", athleteType: .powerlifter, text: "That 7:08 pace is flying!", timeAgo: "3h ago")
            ]
        ),
        AthletePost(
            authorName: "Kai Takahashi",
            authorHandle: "kai_athletic",
            athleteType: .hybrid,
            timeAgo: "7h ago",
            workoutTag: "HYBRID ENGINE",
            workoutStats: "Heavy Deadlifts 405 + 4-Mile Aerobic Base",
            caption: "Dual-threat training day. Pulled 405x3 then hit zone-2 cardio. Macros hit at 210g protein.",
            imageName: "bolt.shield.fill",
            mediaType: .photo,
            mediaIconName: "bolt.shield.fill",
            gradientColors: [Color(red: 0.15, green: 0.2, blue: 0.05), Color(red: 0.25, green: 0.35, blue: 0.1)],
            audioTrack: AudioTrack.library[6], // DVRST - Close Eyes (Spotify)
            textOverlay: "HYBRID OVERLOAD",
            likesCount: 215,
            isLiked: false,
            comments: [
                PostComment(author: "sarah_lifts", athleteType: .bodybuilder, text: "The definition of hybrid athletic output!", timeAgo: "5h ago")
            ]
        ),
        AthletePost(
            authorName: "Maya Lin",
            authorHandle: "maya_rings",
            athleteType: .calisthenics,
            timeAgo: "12h ago",
            workoutTag: "RINGS & BARS",
            workoutStats: "Straddle Planche + 5 Strict Muscle-Ups",
            caption: "Full bodyweight control routine. Clean lockout on every repetition.",
            imageName: "figure.gymnastics",
            mediaType: .video,
            mediaIconName: "figure.gymnastics",
            gradientColors: [Color(red: 0.05, green: 0.2, blue: 0.15), Color(red: 0.1, green: 0.35, blue: 0.25)],
            audioTrack: AudioTrack.library[8], // Tevez - Hardstyle Overload (Spotify)
            textOverlay: "STRICT RINGS",
            likesCount: 167,
            isLiked: true,
            comments: [
                PostComment(author: "kai_athletic", athleteType: .hybrid, text: "That planche hold was flawless.", timeAgo: "9h ago")
            ]
        )
    ]

    // Active full screen reel modal
    @State private var activeReelPost: AthletePost? = nil
    @State private var showingCreatePostSheet = false
    @State private var shareSheetItem: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach($posts) { $post in
                        SimplePostCardView(
                            post: $post,
                            onShare: {
                                shareSheetItem = "Check out @\(post.authorHandle)'s workout on Solxce: \(post.caption)"
                            },
                            onOpenReel: {
                                activeReelPost = post
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreatePostSheet = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("New Post")
                                .font(AppTheme.headlineFont)
                        }
                        .foregroundColor(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePostSheet) {
                CreateMediaPostSheet(
                    authorName: currentUserName,
                    authorHandle: currentUserHandle,
                    athleteType: currentUserAthleteType,
                    onPost: { newPost in
                        withAnimation(.spring()) {
                            posts.insert(newPost, at: 0)
                        }
                    }
                )
            }
            .sheet(item: $shareSheetItem) { shareText in
                ShareActivitySheet(text: shareText)
            }
            .fullScreenCover(item: $activeReelPost) { reelPost in
                if let index = posts.firstIndex(where: { $0.id == reelPost.id }) {
                    TikTokReelPlayerModal(
                        post: $posts[index],
                        onAddComment: { newComment in
                            posts[index].comments.append(newComment)
                        }
                    )
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Super Simple 9:16 / 16:9 Aspect Post Card
struct SimplePostCardView: View {
    @Binding var post: AthletePost
    var onShare: () -> Void
    var onOpenReel: () -> Void

    @State private var isCommenting: Bool = false
    @State private var commentText: String = ""
    @State private var showHeartBurst: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 9:16 Aspect Media Card Viewport with Top Music Bar and Bottom Caption Overlay
            ZStack(alignment: .bottom) {
                // Background Media Gradient Canvas in 9:16 vertical ratio
                LinearGradient(
                    colors: post.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                .clipped()

                // Center Athlete Visual Icon
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(post.athleteType.badgeColor.opacity(0.18))
                            .frame(width: 84, height: 84)

                        Image(systemName: post.mediaIconName)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(post.athleteType.badgeColor)
                    }

                    if let sticker = post.textOverlay, !sticker.isEmpty {
                        Text(sticker)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Top: Author Info + Music on Top
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        // Author Avatar & Handle
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppTheme.surfaceRaised)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: post.athleteType.iconName)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(post.athleteType.badgeColor)
                                )

                            VStack(alignment: .leading, spacing: 1) {
                                Text(post.authorName)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                Text("@\(post.authorHandle)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }

                        Spacer()

                        // Music on Top Bar / Pill
                        if let audio = post.audioTrack {
                            HStack(spacing: 5) {
                                Image(systemName: audio.platform.iconName)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(audio.platform.brandColor)

                                EqualizerAnimationView()
                                    .frame(width: 12, height: 10)
                                    .foregroundColor(AppTheme.primary)

                                Text("\(audio.title) · \(audio.artist)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(maxWidth: 130, alignment: .leading)
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.65))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                            )
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 14)

                    Spacer()
                }

                // Bottom Gradient Scrim for readable Caption overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 120)

                // Bottom Caption Overlay
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(post.workoutTag)
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(AppTheme.primary)
                            .tracking(1)

                        Spacer()

                        Text(post.timeAgo)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Text(post.caption)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)

                // Double Tap Heart Animation
                if showHeartBurst {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 72))
                        .foregroundColor(AppTheme.accent)
                        .scaleEffect(1.2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            )
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
                onOpenReel()
            }

            // Just the Likes, Comments, and Share Button
            HStack(spacing: 24) {
                // Like Button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        post.isLiked.toggle()
                        post.likesCount += post.isLiked ? 1 : -1
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(post.isLiked ? AppTheme.accent : AppTheme.text)
                        Text("\(post.likesCount)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.text)
                    }
                }
                .buttonStyle(.plain)

                // Comment Button
                Button {
                    withAnimation(.spring()) {
                        isCommenting.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.text)
                        Text("\(post.comments.count)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.text)
                    }
                }
                .buttonStyle(.plain)

                // Share Button
                Button {
                    onShare()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(AppTheme.text)
                        Text("Share")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.text)
                    }
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)
            .padding(.bottom, 6)

            // Simple In-line Comments Tray (when open)
            if isCommenting {
                VStack(alignment: .leading, spacing: 8) {
                    if !post.comments.isEmpty {
                        ForEach(post.comments) { comment in
                            HStack(alignment: .top, spacing: 6) {
                                Text(comment.author)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppTheme.primary)
                                Text(comment.text)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.text)
                            }
                        }
                    }

                    HStack(spacing: 8) {
                        TextField("Add a comment...", text: $commentText)
                            .font(AppTheme.captionFont)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppTheme.surface)
                            .clipShape(Capsule())
                            .foregroundColor(AppTheme.text)

                        Button {
                            guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            let newC = PostComment(
                                author: "you",
                                athleteType: .hybrid,
                                text: commentText,
                                timeAgo: "Just now"
                            )
                            post.comments.append(newC)
                            commentText = ""
                        } label: {
                            Text("Post")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(AppTheme.surfaceRaised)
                                .clipShape(Capsule())
                        }
                        .disabled(commentText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .padding(8)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppTheme.hairline, lineWidth: 1)
        )
    }
}

// MARK: - Share Activity Sheet Bridge
extension String: @retroactive Identifiable {
    public var id: String { self }
}

struct ShareActivitySheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
