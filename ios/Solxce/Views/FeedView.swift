// Views/FeedView.swift
import SwiftUI

// MARK: - Local Feed Fixture Model
struct AthletePost: Identifiable {
    let id = UUID()
    let authorName: String
    let authorHandle: String
    let timeAgo: String
    let workoutTag: String
    let workoutStats: String
    let caption: String
    let imageName: String
    var likesCount: Int
    var isLiked: Bool
    var comments: [PostComment]
}

struct PostComment: Identifiable {
    let id = UUID()
    let author: String
    let text: String
    let timeAgo: String
}

struct AthleteStory: Identifiable {
    let id = UUID()
    let name: String
    let hasUnseen: Bool
    let tag: String
}

struct FeedView: View {
    @State private var posts: [AthletePost] = [
        AthletePost(
            authorName: "Marcus Vance",
            authorHandle: "marcus_lifts",
            timeAgo: "2h ago",
            workoutTag: "CHEST & TRICEPS",
            workoutStats: "6 exercises · 22 sets · 18,400 lbs volume",
            caption: "New PR on bench today! 315 lbs for a clean double. Feeling dialed in with the new 5-day split.",
            imageName: "dumbbell.fill",
            likesCount: 142,
            isLiked: false,
            comments: [
                PostComment(author: "elena_runs", text: "Insane bench numbers man! Clean form 🔥", timeAgo: "1h ago"),
                PostComment(author: "coach_dave", text: "Chest drive looking sharp. Keep recovering well.", timeAgo: "45m ago")
            ]
        ),
        AthletePost(
            authorName: "Elena Rostova",
            authorHandle: "elena_runs",
            timeAgo: "4h ago",
            workoutTag: "TEMPO RUN",
            workoutStats: "6.20 mi · 44:18 · 7'08\" /mi pace",
            caption: "Early 10K around the bay before work. Crisp morning air and steady cadence throughout.",
            imageName: "figure.run",
            likesCount: 89,
            isLiked: true,
            comments: [
                PostComment(author: "marcus_lifts", text: "That 7:08 pace is flying!", timeAgo: "3h ago")
            ]
        ),
        AthletePost(
            authorName: "Kai Takahashi",
            authorHandle: "kai_athletic",
            timeAgo: "7h ago",
            workoutTag: "LEG DAY HYPERTROPHY",
            workoutStats: "5 exercises · 20 sets · 24,100 lbs volume",
            caption: "Squat drop sets humbled me this afternoon. 4 sets of 12 paused reps. Hydration and 200g protein rest of the day.",
            imageName: "figure.strengthtraining.traditional",
            likesCount: 215,
            isLiked: false,
            comments: [
                PostComment(author: "sarah_fit", text: "Pause squats are brutal! Respect 💪", timeAgo: "5h ago")
            ]
        )
    ]

    let stories: [AthleteStory] = [
        AthleteStory(name: "You", hasUnseen: false, tag: "Add"),
        AthleteStory(name: "Marcus", hasUnseen: true, tag: "Bench PR"),
        AthleteStory(name: "Elena", hasUnseen: true, tag: "10K Run"),
        AthleteStory(name: "Kai", hasUnseen: true, tag: "Legs"),
        AthleteStory(name: "Coach Dave", hasUnseen: false, tag: "Tips")
    ]

    @State private var selectedPost: AthletePost?
    @State private var showingCreatePostSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    // Demo Content Disclosure Banner (Required by capability contract)
                    demoDisclosureBanner

                    // Story Rail
                    storyRail

                    // Posts Stream
                    ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                        postCard(post: post, index: index)
                    }
                }
                .padding(.top, AppTheme.Spacing.xs)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Community Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingCreatePostSheet = true }) {
                        Image(systemName: "plus.square")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppTheme.primary)
                    }
                }
            }
            .sheet(item: $selectedPost) { post in
                if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                    PostDetailView(
                        post: $posts[idx],
                        onAddComment: { newComment in
                            posts[idx].comments.append(newComment)
                        }
                    )
                }
            }
            .sheet(isPresented: $showingCreatePostSheet) {
                CreatePostSheet { newPost in
                    posts.insert(newPost, at: 0)
                }
            }
        }
    }

    // MARK: - Disclosure Banner
    private var demoDisclosureBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(AppTheme.primary)
                .font(.system(size: 14))

            Text("Demo content · Sample athletes and posts. Activity updates locally on this device.")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.textSecondary)

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, 8)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
        .padding(.horizontal, AppTheme.Spacing.screenMargin)
    }

    // MARK: - Story Rail
    private var storyRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.md) {
                ForEach(stories) { story in
                    VStack(spacing: 4) {
                        ZStack {
                            if story.hasUnseen {
                                Circle()
                                    .stroke(AppTheme.primary, lineWidth: 2.5)
                                    .frame(width: 62, height: 62)
                            } else {
                                Circle()
                                    .stroke(AppTheme.hairline, lineWidth: 1.5)
                                    .frame(width: 62, height: 62)
                            }

                            Circle()
                                .fill(AppTheme.surfaceRaised)
                                .frame(width: 54, height: 54)

                            Text(story.name.prefix(1))
                                .font(AppTheme.headlineFont)
                                .bold()
                                .foregroundStyle(AppTheme.primary)
                        }

                        Text(story.name)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.text)
                            .lineLimit(1)
                    }
                    .frame(width: 68)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.screenMargin)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Post Card
    private func postCard(post: AthletePost, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Post Header
            HStack(spacing: AppTheme.Spacing.sm) {
                Circle()
                    .fill(AppTheme.surfaceRaised)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(post.authorName.prefix(1))
                            .font(AppTheme.subheadlineFont)
                            .bold()
                            .foregroundStyle(AppTheme.primary)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(post.authorName)
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.text)
                    Text("@\(post.authorHandle) · \(post.timeAgo)")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Text(post.workoutTag)
                    .font(AppTheme.eyebrowFont)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.15))
                    .foregroundStyle(AppTheme.primary)
                    .clipShape(Capsule())
            }
            .padding(AppTheme.Spacing.md)

            // Media & Workout graphic area
            ZStack {
                Rectangle()
                    .fill(AppTheme.surfaceRaised)
                    .aspectRatio(16/9, contentMode: .fit)

                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: post.imageName)
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.primary)

                    Text(post.workoutStats)
                        .font(AppTheme.subheadlineFont)
                        .bold()
                        .foregroundStyle(AppTheme.text)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .multilineTextAlignment(.center)
                }
            }
            .onTapGesture(count: 2) {
                // Double-tap to heart
                posts[index].isLiked.toggle()
                posts[index].likesCount += posts[index].isLiked ? 1 : -1
            }

            // Action row (Like, Comment)
            HStack(spacing: AppTheme.Spacing.lg) {
                Button(action: {
                    posts[index].isLiked.toggle()
                    posts[index].likesCount += posts[index].isLiked ? 1 : -1
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundStyle(post.isLiked ? AppTheme.accent : AppTheme.text)
                        Text("\(post.likesCount)")
                            .font(AppTheme.captionFont)
                            .bold()
                            .foregroundStyle(AppTheme.text)
                    }
                }
                .buttonStyle(.plain)

                Button(action: { selectedPost = post }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 18))
                            .foregroundStyle(AppTheme.text)
                        Text("\(post.comments.count)")
                            .font(AppTheme.captionFont)
                            .bold()
                            .foregroundStyle(AppTheme.text)
                    }
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.sm)

            // Caption
            VStack(alignment: .leading, spacing: 4) {
                Text(post.caption)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.text)
                    .lineLimit(3)

                if !post.comments.isEmpty {
                    Button(action: { selectedPost = post }) {
                        Text("View all \(post.comments.count) comments")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(AppTheme.Spacing.md)
        }
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radii.card)
                .strokeBorder(AppTheme.hairline)
        )
        .padding(.horizontal, AppTheme.Spacing.screenMargin)
    }
}

// MARK: - Post Detail View
struct PostDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var post: AthletePost
    var onAddComment: (PostComment) -> Void

    @State private var commentText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        // Author header
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Circle()
                                .fill(AppTheme.surfaceRaised)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(post.authorName.prefix(1))
                                        .font(AppTheme.headlineFont)
                                        .bold()
                                        .foregroundStyle(AppTheme.primary)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.authorName)
                                    .font(AppTheme.headlineFont)
                                    .foregroundStyle(AppTheme.text)
                                Text("@\(post.authorHandle) · \(post.timeAgo)")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                        }

                        // Caption & Workout stats
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                            Text(post.caption)
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.text)

                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(AppTheme.primary)
                                Text(post.workoutStats)
                                    .font(AppTheme.subheadlineFont)
                                    .bold()
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .padding(AppTheme.Spacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.surfaceRaised)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radii.tag))
                        }

                        Divider().background(AppTheme.hairline)

                        // Comments Section
                        Text("COMMENTS (\(post.comments.count))")
                            .font(AppTheme.eyebrowFont)
                            .tracking(1.5)
                            .foregroundStyle(AppTheme.textSecondary)

                        if post.comments.isEmpty {
                            Text("No comments yet. Be the first to cheer them on!")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.textMuted)
                        } else {
                            ForEach(post.comments) { comment in
                                HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
                                    Circle()
                                        .fill(AppTheme.surfaceRaised)
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Text(comment.author.prefix(1).uppercased())
                                                .font(AppTheme.captionFont)
                                                .bold()
                                                .foregroundStyle(AppTheme.primary)
                                        )

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(comment.author)
                                                .font(AppTheme.subheadlineFont)
                                                .bold()
                                                .foregroundStyle(AppTheme.text)
                                            Spacer()
                                            Text(comment.timeAgo)
                                                .font(AppTheme.captionFont)
                                                .foregroundStyle(AppTheme.textMuted)
                                        }
                                        Text(comment.text)
                                            .font(AppTheme.subheadlineFont)
                                            .foregroundStyle(AppTheme.text)
                                    }
                                }
                                .padding(AppTheme.Spacing.xs)
                            }
                        }
                    }
                    .padding(AppTheme.Spacing.screenMargin)
                }

                // Comment input box
                HStack(spacing: AppTheme.Spacing.sm) {
                    TextField("Add a comment...", text: $commentText)
                        .font(AppTheme.bodyFont)
                        .padding(AppTheme.Spacing.sm)
                        .background(AppTheme.field)
                        .clipShape(Capsule())
                        .foregroundStyle(AppTheme.text)

                    Button(action: {
                        guard !commentText.isEmpty else { return }
                        let comment = PostComment(author: "you", text: commentText, timeAgo: "Just now")
                        onAddComment(comment)
                        commentText = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppTheme.onPrimary)
                            .frame(width: 38, height: 38)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding(AppTheme.Spacing.sm)
                .background(AppTheme.surface)
            }
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("Workout Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}

// MARK: - Create Post Sheet
struct CreatePostSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onPost: (AthletePost) -> Void

    @State private var caption: String = ""
    @State private var workoutType: String = "Chest & Arms"
    @State private var workoutSummary: String = "4 exercises · 16 sets · 14,200 lbs"

    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Overview") {
                    TextField("Focus (e.g. Back & Biceps)", text: $workoutType)
                    TextField("Summary (e.g. 5 exercises, 18 sets)", text: $workoutSummary)
                }

                Section("Caption & Notes") {
                    TextField("Share your training notes or PRs...", text: $caption, axis: .vertical)
                        .lineLimit(4...6)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.ground.ignoresSafeArea())
            .navigationTitle("New Training Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Share") {
                        let post = AthletePost(
                            authorName: "You",
                            authorHandle: "athlete_you",
                            timeAgo: "Just now",
                            workoutTag: workoutType.uppercased(),
                            workoutStats: workoutSummary,
                            caption: caption.isEmpty ? "Pushed through a great session today." : caption,
                            imageName: "dumbbell.fill",
                            likesCount: 1,
                            isLiked: true,
                            comments: []
                        )
                        onPost(post)
                        dismiss()
                    }
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}
