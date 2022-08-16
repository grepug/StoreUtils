//
//  File.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import RevenueCat

public struct Package {
    var id: String = ""
    var title: String = ""
    var originalPriceString: String?
    var currentPriceString: String = ""
    var currentPriceDouble: Double = 0
    var isSubscription: Bool = false
    var rcPackage: RevenueCat.Package!
    var purchased: Bool = false
    var packageType: RevenueCat.PackageType = .unknown
    var productId: String
}

extension Package {
    static func fromPurchasePackage(_ rcPackage: RevenueCat.Package,
                                    info: PurchaseInfo) -> Self {
        let product = rcPackage.storeProduct
        
        return .init(id: rcPackage.identifier,
                     title: rcPackage.storeProduct.localizedTitle,
                     originalPriceString: product.originalPriceString,
                     currentPriceString: product.currentPriceString,
                     currentPriceDouble: product.currentPriceDouble,
                     isSubscription: rcPackage.storeProduct.subscriptionGroupIdentifier != nil,
                     rcPackage: rcPackage,
                     purchased: info.activeSubscriptions.contains(rcPackage.storeProduct.productIdentifier),
                     packageType: rcPackage.packageType,
                     productId: rcPackage.storeProduct.productIdentifier)
    }
}
