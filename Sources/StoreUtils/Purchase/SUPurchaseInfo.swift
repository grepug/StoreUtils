//
//  File.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import RevenueCat

public struct SUPurchaseInfo {
    public let userId: String
    public let activeSubscriptions: Set<String>
    public let allPurchasedProductIdentifiers: Set<String>
    public let nonConsumableProductIds: [String]
    public let firstSeen: Date
    public var latestExpirationDate: Date?
    public let hasAccessToPro: Bool
    public let managementURL: URL?
}

extension SUPurchaseInfo {
    static func fromPurchaseInfo(info: RevenueCat.CustomerInfo) -> Self {
        return .init(userId: info.originalAppUserId,
                     activeSubscriptions: info.activeSubscriptions,
                     allPurchasedProductIdentifiers: info.allPurchasedProductIdentifiers,
                     nonConsumableProductIds: info.nonSubscriptions.map(\.productIdentifier),
                     firstSeen: info.firstSeen,
                     latestExpirationDate: info.latestExpirationDate,
                     hasAccessToPro: info.entitlements.active.isEmpty == false,
                     managementURL: info.managementURL)
    }
}
