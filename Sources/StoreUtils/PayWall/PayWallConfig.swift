//
//  PayWallConfig.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import RevenueCat

public struct PayWallConfig {
    public init(showingProTestSwitch: @escaping () -> Bool, presentErrorAlert: @escaping (PayWallErrorAlertType) -> Void) {
        self.showingProTestSwitch = showingProTestSwitch
        self.presentErrorAlert = presentErrorAlert
    }
    
    public var showingProTestSwitch: () -> Bool
    public var presentErrorAlert: (PayWallErrorAlertType) -> Void
}

public extension PayWallConfig {
    func configRevenueCat(withAPIKey key: String) {
        RevenueCat.Purchases.configure(withAPIKey: key)
    }
}
