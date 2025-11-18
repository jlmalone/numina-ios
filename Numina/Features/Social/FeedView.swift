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
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                OfflineBanner()

                ZStack {
                    if viewModel.isLoading && viewModel.activities.isEmpty {
                        skeletonLoadingView
                    } else if let errorMessage = viewModel.errorMessage, viewModel.activities.isEmpty {
                        if !networkMonitor.isConnected {
                            NetworkErrorView {
                                Task {
                                    await viewModel.loadFeed()
                                }
                            }
                        } else {
                            ErrorView(message: errorMessage) {
                                Task {
                                    await viewModel.loadFeed()
                                }
                            }
                        }
                    } else if viewModel.activities.isEmpty {
                        EmptyStateView.noActivities()
                    } else {
                        feedContent
                    }
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
                            HapticFeedback.shared.favorite()
                            Task {
                                await viewModel.toggleLike(activity: activity)
                            }
                        },
                        onComment: {
                            HapticFeedback.shared.light()
                            selectedActivity = activity
                        }
                    )
                    .onTapGesture {
                        HapticFeedback.shared.light()
                        selectedActivity = activity
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale))

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
            HapticFeedback.shared.refreshStart()
            await viewModel.refreshFeed()
            HapticFeedback.shared.refreshComplete()
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.activities.count)
    }

    private var skeletonLoadingView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonActivityItem()
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    FeedView(
        viewModel: FeedViewModel(
            socialRepository: SocialRepository()
        )
    )
}
