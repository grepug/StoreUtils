//
//  PayWallConfig.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import RevenueCat

public struct SUPayWallConfig {
    public init(showingProTestSwitch: @escaping () -> Bool, presentErrorAlert: @escaping (SUPayWallErrorAlertType) -> Void, presentConfirm: @escaping (SUPayWallConfirmType) async -> Bool, defaultSelectedPakcage: (([SUPackage]) -> SUPackage?)? = nil) {
        self.showingProTestSwitch = showingProTestSwitch
        self.presentErrorAlert = presentErrorAlert
        self.presentConfirm = presentConfirm
        self.defaultSelectedPakcage = defaultSelectedPakcage
    }
    
    public var showingProTestSwitch: () -> Bool
    public var presentErrorAlert: (SUPayWallErrorAlertType) -> Void
    public var presentConfirm: (SUPayWallConfirmType) async -> Bool
    public var defaultSelectedPakcage: (([SUPackage]) -> SUPackage?)?
}

public enum SUError: Error {
    case revenueCatError(RevenueCat.ErrorCode), other(Error)
}

public extension SUError {
    var description: String {
        switch self {
        case .revenueCatError(let rcError):
            switch rcError {
            case .networkError, .offlineConnectionError:
                return "网络连接断开，请检查网络"
            default:
                return rcError.localizedDescription
            }
        case .other(let error):
            return error.localizedDescription
        }
    }
}
