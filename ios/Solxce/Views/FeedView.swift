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
    public let caption: String
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
            caption: "New PR on bench today! 315 lbs for a clean double. Feeling dialed in with the new 5-day split.",
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
            caption: "Early 10K around the bay before work. Crisp morning air and steady cadence throughout.",
            imageName: "figure.run",
            mediaType: .video,
            mediaIconName: "figure.run",
            gradientColors: [Color(red: 0.05, green: 0.15, blue: 0.3), Color(red: 0.1, green: 0.3, blue: 0.5)],
            audioTrack: AudioTrack.library[3],
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
            audioTrack: AudioTrack.library[2],
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
            audioTrack: AudioTrack.library[4],
            textOverlay: "STRICT RINGS",
            likesCount: 167,
            isLiked: true,
            comments: [
                PostComment(author: "kai_athletic", athleteType: .hybrid, text: "That planche hold was flawless.", timeAgo: "9h ago")
            ]
        )
    ]

    let stories: [AthleteStory] = [
        AthleteStory(name: "Your Story", athleteType: .hybrid, hasUnseen: false, tag: "Add"),
        AthleteStory(name: "Marcus", athleteType: .powerlifter, hasUnseen: true, tag: "PR"),
        AthleteStory(name: "Elena", athleteType: .runner, hasUnseen: true, tag: "10K"),
        AthleteStory(name: "Kai", athleteType: .hybrid, hasUnseen: true, tag: "Split"),
        AthleteStory(name: "Maya", athleteType: .calisthenics, hasUnseen: false, tag: "Rings"),
        AthleteStory(name: "Jordan", athleteType: .bodybuilder, hasUnseen: true, tag: "Pump")
    ]

    // Active full screen reel modal
    @State private var activeReelPost: AthletePost? = nil
    @State private var showingCreatePostSheet = false
    @State private var selectedFilterType: AthleteType? = nil

    var filteredPosts: [AthletePost] {
        if let filter = selectedFilterType {
            return posts.filter { $0.athleteType == filter }
        }
        return posts
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Demo Content Header Bar
                    demoNoticeBar

                    // Athlete Stories Rail
                    storiesRail
                        .padding(.vertical, 12)

                    Divider()
                        .overlay(AppTheme.hairline)

                    // Athlete Archetype Filter Bar
                    athleteFilterRail
                        .padding(.vertical, 10)

                    // Feed Posts List
                    LazyVStack(spacing: 16) {
                        ForEach($posts) { $post in
                            if selectedFilterType == nil || post.athleteType == selectedFilterType {
                                PostCardView(
                                    post: $post,
                                    onOpenReel: {
                                        activeReelPost = post
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.screenMargin)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Community Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreatePostSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Post")
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

    // MARK: - Demo Notice Bar
    private var demoNoticeBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles.tv.fill")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.primary)
            Text("ATHLETE FEED · Videos, Photos & Audio Beats")
                .font(AppTheme.eyebrowFont)
                .foregroundColor(AppTheme.textSecondary)
                .tracking(1.2)
            Spacer()
            Text("DEMO")
                .font(.system(size: 9, weight: .black))
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(AppTheme.surfaceRaised)
                .foregroundColor(AppTheme.textMuted)
                .clipShape(Capsule())
        }
        .padding(.horizontal, AppTheme.Spacing.screenMargin)
        .padding(.vertical, 8)
        .background(AppTheme.surface)
    }

    // MARK: - Stories Rail
    private var storiesRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(stories) { story in
                    VStack(spacing: 6) {
                        ZStack {
                            if story.tag == "Add" {
                                Circle()
                                    .stroke(AppTheme.primary, lineWidth: 2)
                                    .frame(width: 58, height: 58)

                                Circle()
                                    .fill(AppTheme.surfaceRaised)
                                    .frame(width: 50, height: 50)

                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppTheme.primary)
                            } else {
                                Circle()
                                    .stroke(
                                        story.hasUnseen
                                            ? story.athleteType.badgeColor
                                            : AppTheme.hairline,
                                        lineWidth: 2.5
                                    )
                                    .frame(width: 58, height: 58)

                                Circle()
                                    .fill(AppTheme.surfaceRaised)
                                    .frame(width: 50, height: 50)

                                Image(systemName: story.athleteType.iconName)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(story.athleteType.badgeColor)
                            }
                        }

                        Text(story.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                            .frame(width: 60)
                    }
                    .onTapGesture {
                        if story.tag == "Add" {
                            showingCreatePostSheet = true
                        }
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.screenMargin)
        }
    }

    // MARK: - Athlete Archetype Filter Rail
    private var athleteFilterRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedFilterType = nil
                } label: {
                    Text("All Athletes")
                        .font(.system(size: 12, weight: selectedFilterType == nil ? .bold : .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedFilterType == nil ? AppTheme.primary : AppTheme.surface)
                        .foregroundColor(selectedFilterType == nil ? AppTheme.onPrimary : AppTheme.textSecondary)
                        .clipShape(Capsule())
                }

                ForEach(AthleteType.allCases) { type in
                    Button {
                        selectedFilterType = (selectedFilterType == type) ? nil : type
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: type.iconName)
                                .font(.system(size: 10, weight: .bold))
                            Text(type.shortTag)
                                .font(.system(size: 11, weight: selectedFilterType == type ? .bold : .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selectedFilterType == type ? type.badgeColor : AppTheme.surface)
                        .foregroundColor(selectedFilterType == type ? .black : AppTheme.textSecondary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.screenMargin)
        }
    }
}

// MARK: - Post Card View
struct PostCardView: View {
    @Binding var post: AthletePost
    var onOpenReel: () -> Void

    @State private var isCommenting = false
    @State private var commentText = ""
    @State private var showHeartBurst = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Post Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(post.athleteType.badgeColor, lineWidth: 1.5)
                        .frame(width: 38, height: 38)

                    Circle()
                        .fill(AppTheme.surfaceRaised)
                        .frame(width: 34, height: 34)

                    Image(systemName: post.athleteType.iconName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(post.athleteType.badgeColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(post.authorName)
                            .font(AppTheme.headlineFont)
                            .foregroundColor(AppTheme.text)

                        HStack(spacing: 3) {
                            Image(systemName: post.athleteType.iconName)
                                .font(.system(size: 8, weight: .bold))
                            Text(post.athleteType.shortTag)
                                .font(.system(size: 8, weight: .black))
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(post.athleteType.badgeColor.opacity(0.2))
                        .foregroundColor(post.athleteType.badgeColor)
                        .clipShape(Capsule())
                    }

                    Text("@\(post.authorHandle) · \(post.timeAgo)")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                // Media type badge (Video vs Photo)
                HStack(spacing: 4) {
                    Image(systemName: post.mediaType.iconName)
                        .font(.system(size: 11, weight: .bold))
                    Text(post.mediaType == .video ? "REEL" : "PHOTO")
                        .font(.system(size: 9, weight: .black))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(AppTheme.surfaceRaised)
                .foregroundColor(AppTheme.primary)
                .clipShape(Capsule())
            }
            .padding(12)

            // Audio Track Bar (if soundtrack selected)
            if let audio = post.audioTrack {
                HStack(spacing: 8) {
                    EqualizerAnimationView()
                        .frame(width: 14, height: 12)
                        .foregroundColor(AppTheme.primary)

                    Text("\(audio.title) · \(audio.artist)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.text)
                        .lineLimit(1)

                    Spacer()

                    Text(audio.genre.uppercased())
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.surface)
                .overlay(
                    Rectangle().frame(height: 1).foregroundColor(AppTheme.hairline),
                    alignment: .bottom
                )
            }

            // Post Media Viewport (Tapping opens TikTok/Reels full screen player)
            ZStack {
                LinearGradient(
                    colors: post.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 280)

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(post.athleteType.badgeColor.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: post.mediaIconName)
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(post.athleteType.badgeColor)
                    }

                    // On-screen text sticker if available
                    if let sticker = post.textOverlay, !sticker.isEmpty {
                        Text(sticker)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(AppTheme.primary, lineWidth: 1)
                            )
                    }

                    if post.mediaType == .video {
                        HStack(spacing: 6) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 16))
                            Text("TAP FOR FULL REEL")
                                .font(AppTheme.eyebrowFont)
                                .tracking(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Capsule())
                    }
                }

                if showHeartBurst {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 72))
                        .foregroundColor(AppTheme.accent)
                        .scaleEffect(1.2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
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

            // Workout Stats Ribbon
            HStack {
                Text(post.workoutTag)
                    .font(AppTheme.eyebrowFont)
                    .foregroundColor(AppTheme.primary)
                    .tracking(1)

                Spacer()

                Text(post.workoutStats)
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.surface)

            // Engagement Actions (Like, Comment, Share, Fullscreen)
            HStack(spacing: 16) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        post.isLiked.toggle()
                        post.likesCount += post.isLiked ? 1 : -1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? AppTheme.accent : AppTheme.textSecondary)
                            .font(.system(size: 18))
                        Text("\(post.likesCount)")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.text)
                    }
                }

                Button {
                    isCommenting.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(AppTheme.textSecondary)
                            .font(.system(size: 16))
                        Text("\(post.comments.count)")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.text)
                    }
                }

                Spacer()

                Button {
                    onOpenReel()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 13, weight: .bold))
                        Text("Immersive")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            // Caption
            VStack(alignment: .leading, spacing: 4) {
                Text("**\(post.authorHandle)** \(post.caption)")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.text)
                    .lineLimit(3)

                if !post.comments.isEmpty {
                    Text("View all \(post.comments.count) comments")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.top, 2)
                        .onTapGesture {
                            isCommenting = true
                        }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            // Quick Comment Composer
            if isCommenting {
                Divider().overlay(AppTheme.hairline)
                HStack(spacing: 8) {
                    TextField("Add a comment...", text: $commentText)
                        .font(AppTheme.captionFont)
                        .padding(8)
                        .background(AppTheme.field)
                        .clipShape(Capsule())
                        .foregroundColor(AppTheme.text)

                    Button {
                        guard !commentText.isEmpty else { return }
                        let newC = PostComment(
                            author: "you",
                            athleteType: .hybrid,
                            text: commentText,
                            timeAgo: "Just now"
                        )
                        post.comments.append(newC)
                        commentText = ""
                        isCommenting = false
                    } label: {
                        Text("Post")
                            .font(AppTheme.captionFont)
                            .bold()
                            .foregroundColor(AppTheme.primary)
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.surface)
            }
        }
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                .stroke(AppTheme.hairline, lineWidth: 1)
        )
    }
}
