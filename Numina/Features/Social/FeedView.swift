//
//  FeedView.swift
//  Numina
//
//  Social activity feed view
//

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel: FeedViewModel
    @State private var selectedActivity: Activity?

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.activities.isEmpty {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage, viewModel.activities.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadFeed()
                        }
                    }
                } else if viewModel.activities.isEmpty {
                    EmptyFeedView()
                } else {
                    feedContent
                }
            }
            .navigationTitle("Activity Feed")
            .sheet(item: $selectedActivity) { activity in
                ActivityDetailView(
                    activity: activity,
                    viewModel: viewModel
                )
            }
            .task {
                if viewModel.activities.isEmpty {
                    await viewModel.loadFeed()
                }
            }
        }
    }

    private var feedContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.activities, id: \.id) { activity in
                    ActivityFeedItem(
                        activity: activity,
                        onLike: {
                            Task {
                                await viewModel.toggleLike(activity: activity)
                            }
                        },
                        onComment: {
                            selectedActivity = activity
                        }
                    )
                    .onTapGesture {
                        selectedActivity = activity
                    }
                    .padding(.horizontal)

                    // Load more trigger
                    if activity.id == viewModel.activities.last?.id {
                        if viewModel.isLoadingMore {
                            ProgressView()
                                .padding()
                        } else if viewModel.hasMorePages {
                            Color.clear
                                .frame(height: 1)
                                .onAppear {
                                    Task {
                                        await viewModel.loadMoreActivities()
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refreshFeed()
        }
    }
}

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.wave.circle")
                .font(.system(size: 60))
                .foregroundColor(.orange.opacity(0.5))

            Text("No Activity Yet")
                .font(.title3.weight(.medium))

            Text("Start following users to see their activities")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    FeedView(
        viewModel: FeedViewModel(
            socialRepository: SocialRepository()
        )
    )
}
