import Foundation
import Network
import SwiftUI

/// Monitors network connectivity status
@MainActor
final class NetworkMonitor: ObservableObject {

    /// Shared instance
    static let shared = NetworkMonitor()

    /// Current network connection status
    @Published private(set) var isConnected = true

    /// Network path status
    @Published private(set) var connectionType: ConnectionType = .unknown

    /// Network path monitor
    private let monitor: NWPathMonitor

    /// Monitor queue
    private let queue = DispatchQueue(label: "com.numina.networkmonitor")

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    /// Connection type enumeration
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    /// Start monitoring network status
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.updateConnectionType(path)
            }
        }
        monitor.start(queue: queue)
    }

    /// Stop monitoring network status
    func stopMonitoring() {
        monitor.cancel()
    }

    /// Update connection type based on path
    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }

    deinit {
        stopMonitoring()
    }
}

// MARK: - Offline Banner View

/// Banner that displays when the device is offline
struct OfflineBanner: View {
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 14, weight: .semibold))

                Text("No Internet Connection")
                    .font(.system(size: 14, weight: .medium))

                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.red.opacity(0.9))
            .transition(.move(edge: .top).combined(with: .opacity))
            .accessibilityLabel("No internet connection banner")
            .accessibilityAddTraits(.isStaticText)
        }
    }
}

// MARK: - View Extension for Offline Banner

extension View {
    /// Add offline banner to any view
    func withOfflineBanner() -> some View {
        VStack(spacing: 0) {
            OfflineBanner()
            self
        }
    }
}

// MARK: - Network Error View

/// Enhanced network error view for offline state
struct NetworkErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("No Internet Connection")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Please check your connection and try again")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: {
                HapticFeedback.shared.buttonPress()
                onRetry()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
            }
            .accessibilityLabel("Try again button")
            .accessibilityHint("Retry loading content")
        }
        .padding(40)
    }
}

#Preview {
    VStack {
        OfflineBanner()
        Spacer()
        NetworkErrorView {
            print("Retry tapped")
        }
        Spacer()
    }
}
