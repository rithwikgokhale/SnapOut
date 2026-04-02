import SwiftUI

@main
struct SnapOutApp: App {

    @StateObject private var container: DependencyContainer
    @StateObject private var coordinator: AppCoordinator

    init() {
        let c = DependencyContainer()
        _container = StateObject(wrappedValue: c)
        _coordinator = StateObject(wrappedValue: AppCoordinator(container: c))
    }

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(coordinator)
                .environmentObject(container)
        }
    }
}
