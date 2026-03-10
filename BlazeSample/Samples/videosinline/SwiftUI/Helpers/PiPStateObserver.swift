import BlazeSDK
import Combine

@MainActor
final class PiPStateObserver: ObservableObject {
    static let shared = PiPStateObserver()

    @Published private(set) var isActive: Bool = false

    private init() {
        isActive = Blaze.shared.pipManager.isActive
        Blaze.shared.pipManager.delegate = BlazePipDelegate(
            onPiPStateChanged: { [weak self] args in
                Task { @MainActor [weak self] in
                    self?.isActive = args.newState == .on
                }
            }
        )
    }
}
