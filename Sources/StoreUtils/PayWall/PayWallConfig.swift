//
//  PayWallConfig.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import RevenueCat

public struct PayWallConfig {
    public init(showingProTestSwitch: @escaping () -> Bool, presentErrorAlert: @escaping (PayWallErrorAlertType) -> Void, presentConfirm: @escaping (PayWallConfirmType) async -> Bool, defaultSelectedPakcage: (([Package]) -> Package)? = nil) {
        self.showingProTestSwitch = showingProTestSwitch
        self.presentErrorAlert = presentErrorAlert
        self.presentConfirm = presentConfirm
        self.defaultSelectedPakcage = defaultSelectedPakcage
    }
    
    public var showingProTestSwitch: () -> Bool
    public var presentErrorAlert: (PayWallErrorAlertType) -> Void
    public var presentConfirm: (PayWallConfirmType) async -> Bool
    public var defaultSelectedPakcage: (([Package]) -> Package?)?
}

public enum StoreUtilsError: Error {
    case revenueCatError(RevenueCat.ErrorCode), other(Error)
}

public extension StoreUtilsError {
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
