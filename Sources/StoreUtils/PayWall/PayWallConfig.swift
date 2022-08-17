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
    public var defaultSelectedPakcage: (([Package]) -> Package)?
}

public extension PayWallConfig {
    func configRevenueCat(withAPIKey key: String) {
        RevenueCat.Purchases.configure(withAPIKey: key)
    }
}