import SwiftUI

enum VersionCheckState {
    case iddle
    case loading
    case lockVersion
}

struct VersionCheckView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var viewModel: VersionCheckViewModel
    init() {
        print("[VersionCheckView] Init.")
        self._viewModel = State(initialValue: VersionCheckViewModelFactory.getViewModel())
    }
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.versionCheck {
            case .iddle:
                RootView()
            case .loading:
                LaunchScreenView(viewModel: $viewModel)
            case .lockVersion:
                LockScreenView(viewModel: $viewModel)
            }
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            print("[VersionCheckView] Start check version with scenePhase: \(scenePhase)")
            await viewModel.checkVersion()
        }
    }
}

struct VersionCheckViewModelFactory {
    static func getViewModel() -> VersionCheckViewModel {
        return VersionCheckViewModel(
            checkLatestVersionUseCase: getCheckLatestVersionUseCase()
        )
    }
    static private func getCheckLatestVersionUseCase() -> CheckLatestVersionUseCase {
        return CheckLatestVersionInteractor(appConfigRepository: AppContainer.shared.appConfigRepository)
    }
}

protocol AlertPresenting: AnyObject {
    var alert: Bool { get set }
    var alertInfo: AlertInfo? { get set }
    func showAlert(alertInfo: AlertInfo) async
    func dismissAlert()
}

extension AlertPresenting {
    func showAlert(alertInfo: AlertInfo) async {
        await MainActor.run {
            self.alertInfo = alertInfo
            self.alert = true
        }
    }
    func dismissAlert() {
        self.alertInfo = nil
        self.alert = false
    }
}

@Observable
final class VersionCheckViewModel: AlertPresenting {
    var versionCheck: VersionCheckState = .loading
    var alert: Bool = false
    var alertInfo: AlertInfo?
    private var intervalRequest: TimeInterval = 15 * 60 // 15 minutos en segundos
    private var latestVersion: StableVersion?
    //Use Cases
    private var checkLatestVersionUseCase: CheckLatestVersionUseCase
    init(
        checkLatestVersionUseCase: CheckLatestVersionUseCase
    ) {
        self.checkLatestVersionUseCase = checkLatestVersionUseCase
    }
    func checkVersion() async {
        print("[VersionCheckViewModel] checkVersion...")
        do {
            try await fetchLatestVersion()
            try await validateVersion()
        } catch {
            print("Error: \(error.localizedDescription)")
            let alertInfo = AlertInfo(tittle: "Error", message: error.localizedDescription, mainButton: AlertInfo.ButtonConfig(text: "Aceptar", action: { [weak self] in
                self?.dismissAlert()
            }))
            await showAlert(alertInfo: alertInfo)
        }
    }
    private func fetchLatestVersion() async throws {
        let currentDate = Date()
        if latestVersion == nil {
            print("[VersionCheckViewModel] Fetching latest version...")
            await MainActor.run {
                self.versionCheck = .loading
            }
            self.latestVersion = try await self.checkLatestVersionUseCase.execute()
        }
        guard let latestVersion else {
            throw NSError(domain: "Error al obtener la versión más reciente", code: 0, userInfo: nil)
        }
        // Si ya pasaron más de 15 minutos, vuelve a consultar
        if currentDate.timeIntervalSince(latestVersion.lastChecked) > intervalRequest {
            await MainActor.run {
                self.versionCheck = .loading
            }
            self.latestVersion = try await self.checkLatestVersionUseCase.execute()
        }
    }
    private func validateVersion() async throws {
        guard let latestVersion else {
            throw NSError(domain: "Error al obtener la versión más reciente", code: 0, userInfo: nil)
        }
        guard Date().timeIntervalSince(latestVersion.lastChecked) <= intervalRequest else {
            throw NSError(domain: "No es la request de la versión más reciente", code: 0, userInfo: nil)
        }
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        print("Current Version: \(currentVersion), Minimum Version: \(latestVersion.minimumVersion), Latest Version: \(latestVersion.latestVersion)")
        if compareVersions(currentVersion, latestVersion.minimumVersion) != .orderedAscending {
            await MainActor.run {
                self.versionCheck = .iddle
            }
        } else {
            await MainActor.run {
                self.versionCheck = .lockVersion
            }
        }
    }
    private func checkRemoteVersion() async throws {
        self.latestVersion = try await self.checkLatestVersionUseCase.execute()
    }

    private func compareVersions(_ v1: String, _ v2: String) -> ComparisonResult {
        let components1 = v1.split(separator: ".").map { Int($0) ?? 0 }
        let components2 = v2.split(separator: ".").map { Int($0) ?? 0 }
        let maxCount = max(components1.count, components2.count)

        for i in 0..<maxCount {
            let value1 = i < components1.count ? components1[i] : 0
            let value2 = i < components2.count ? components2[i] : 0

            if value1 < value2 { return .orderedAscending }
            if value1 > value2 { return .orderedDescending }
        }
        return .orderedSame
    }
}

#Preview {
    VersionCheckView()
}
