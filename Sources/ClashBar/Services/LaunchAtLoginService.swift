import CoreFoundation
import Foundation
import ServiceManagement

private enum LaunchItemConstants {
    static let bundleIdentifier = "com.clashbar.loginitem"
    static let expectedStateKey = "ClashBar.LegacyLaunchItemEnabled"
}

enum AppLaunchServiceError: Error {
    case unsupportedEnvironment
    case requiresApproval
    case registrationFailed(String)
    case unregistrationFailed(String)
}

struct AppLaunchService {
    var isEnabled: Bool {
        if self.isRegisteredWithLaunchd {
            return true
        }
        return UserDefaults.standard.bool(forKey: LaunchItemConstants.expectedStateKey)
    }

    func setEnabled(_ enabled: Bool) throws {
        guard self.isRunningFromAppBundle else {
            throw AppLaunchServiceError.unsupportedEnvironment
        }

        let identifier = (LaunchItemConstants.bundleIdentifier as NSString) as CFString
        guard SMLoginItemSetEnabled(identifier, enabled) else {
            let message = enabled
                ? "SMLoginItemSetEnabled returned false."
                : "Failed to disable the login item."
            if enabled {
                throw AppLaunchServiceError.registrationFailed(message)
            }
            throw AppLaunchServiceError.unregistrationFailed(message)
        }

        UserDefaults.standard.set(enabled, forKey: LaunchItemConstants.expectedStateKey)
    }

    private var isRegisteredWithLaunchd: Bool {
        guard let unmanagedJobs = SMCopyAllJobDictionaries(kSMDomainUserLaunchd) else {
            return false
        }
        let jobs = unmanagedJobs.takeRetainedValue() as NSArray
        return jobs.contains { job in
            guard let dictionary = job as? [String: Any] else { return false }
            return dictionary["Label"] as? String == LaunchItemConstants.bundleIdentifier
        }
    }

    private var isRunningFromAppBundle: Bool {
        Bundle.main.bundleURL.pathExtension.caseInsensitiveCompare("app") == .orderedSame
    }
}
