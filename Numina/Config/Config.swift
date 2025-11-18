import Foundation

enum Config {
    enum Environment {
        case development
        case production

        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }

    static var apiBaseURL: String {
        switch Environment.current {
        case .development:
            return "http://localhost:8080"
        case .production:
            return "https://api.numina.app"
        }
    }

    static var websocketURL: String {
        switch Environment.current {
        case .development:
            return "ws://localhost:8080/ws"
        case .production:
            return "wss://api.numina.app/ws"
        }
    }
}
