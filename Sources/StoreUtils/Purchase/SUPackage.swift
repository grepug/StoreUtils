//
//  File.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import RevenueCat

public struct SUPackage: Identifiable, Hashable {
    public var id: String = ""
    public var title: String = ""
    public var currentPriceString: String = ""
    public var currentPriceDouble: Double = 0
    public var isSubscription: Bool = false
    public var rcPackage: RevenueCat.Package?
    public var purchased: Bool = false
    var packageType: RevenueCat.PackageType = .unknown
    public var productId: String
}

extension SUPackage {
    var purchasedText: String {
        switch self.isSubscription {
        case true: return "settings_pro_subscribed".loc
        case false: return "settings_pro_purchased".loc
        }
    }
    
    var purchaseText: String {
        switch self.isSubscription {
        case true: return "settings_pro_subscribe".loc
        case false: return "settings_pro_purchase".loc
        }
    }
}

extension SUPackage {
    static func fromPurchasePackage(_ rcPackage: RevenueCat.Package,
                                    info: SUPurchaseInfo) -> Self {
        let product = rcPackage.storeProduct
        
        return .init(id: rcPackage.identifier,
                     title: rcPackage.storeProduct.localizedTitle,
                     currentPriceString: product.currentPriceString,
                     currentPriceDouble: product.currentPriceDouble,
                     isSubscription: rcPackage.storeProduct.subscriptionGroupIdentifier != nil,
                     rcPackage: rcPackage,
                     purchased: info.activeSubscriptions.contains(rcPackage.storeProduct.productIdentifier),
                     packageType: rcPackage.packageType,
                     productId: rcPackage.storeProduct.productIdentifier)
    }
}
