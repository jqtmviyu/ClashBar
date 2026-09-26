import CoreFoundation
import Foundation
import Security
import ServiceManagement

private enum LegacyPrivilegedHelperError: LocalizedError {
    case authorizationFailed(Int32)
    case installationFailed(String)

    var errorDescription: String? {
        switch self {
        case let .authorizationFailed(status):
            return "Unable to obtain administrator authorization (OSStatus \(status))."
        case let .installationFailed(message):
            return message
        }
    }
}

enum LegacyPrivilegedHelperInstaller {
    static let label = ProxyHelperConstants.machServiceName

    private static var installedHelperURL: URL {
        URL(fileURLWithPath: "/Library/PrivilegedHelperTools")
            .appendingPathComponent(self.label, isDirectory: false)
    }

    static var isInstalled: Bool {
        FileManager.default.fileExists(atPath: self.installedHelperURL.path)
    }

    static func install() throws {
        var authorization: AuthorizationRef?
        let flags: AuthorizationFlags = [.interactionAllowed, .extendRights, .preAuthorize]
        let authorizationStatus = AuthorizationCreate(nil, nil, flags, &authorization)
        guard authorizationStatus == errAuthorizationSuccess, let authorization else {
            throw LegacyPrivilegedHelperError.authorizationFailed(authorizationStatus)
        }
        defer { _ = AuthorizationFree(authorization, []) }

        var blessingError: Unmanaged<CFError>?
        let succeeded = SMJobBless(
            kSMDomainSystemLaunchd,
            (self.label as NSString) as CFString,
            authorization,
            &blessingError)
        guard succeeded else {
            let message = blessingError?.takeRetainedValue().localizedDescription
                ?? "SMJobBless returned false."
            throw LegacyPrivilegedHelperError.installationFailed(message)
        }
    }
}
