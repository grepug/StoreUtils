//
//  PurchaseUseCases.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import RevenueCat

public struct SUPurchaseUseCases {
    public static func configureRevenueCat(withAPIKey key: String) {
        RevenueCat.Purchases.configure(withAPIKey: key)
    }
    
    private var rc: Purchases {
        RevenueCat.Purchases.shared
    }
    
    func configRevenueCat(withAPIKey key: String) {
        RevenueCat.Purchases.configure(withAPIKey: key)
    }
    
    func fetchPackages() async throws -> [SUPackage] {
        guard let offering = try await rc.offerings().current else {
            return []
        }
        
        guard let info = try await getPurchaseInfo() else {
            return []
        }
        
        let packages: [SUPackage] = offering.availablePackages.map {
            .fromPurchasePackage($0, info: info)
        }
        let idsNotInOffering = info.allPurchasedProductIdentifiers.subtracting(packages.map(\.productId))
        
        if idsNotInOffering.isEmpty {
            return packages
        }
           
        let purchasedPackages = await getPurchasedPackage(ids: Array(idsNotInOffering))
        
        return packages + purchasedPackages
    }
    
    func getPurchaseInfo() async throws -> SUPurchaseInfo? {
        try await withCheckedThrowingContinuation { continuation in
            rc.getCustomerInfo { info, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let purchaseInfo = info.map { SUPurchaseInfo.fromPurchaseInfo(info: $0) }
                
                continuation.resume(returning: purchaseInfo)
            }
        }
    }
    
    /// 这里通过 id 获取 SKProduct，用于显示已经下架的 package，所以这里获取不到 rcPackage
    func getPurchasedPackage(ids: [String]) async -> [SUPackage] {
        await withCheckedContinuation { continuation in
            rc.getProducts(ids) { skProducts in
                let packages: [SUPackage] = skProducts.map { prod in
                        .init(id: prod.productIdentifier,
                              title: prod.localizedTitle,
                              currentPriceString: prod.currentPriceString,
                              isSubscription: prod.subscriptionPeriod != nil,
                              purchased: true,
                              packageType: .annual,
                              productId: prod.productIdentifier)
                }
                
                continuation.resume(returning: packages)
            }
        }
    }
    
    func purchase(_ package: SUPackage) async throws -> PurchaseResultData {
        try await rc.purchase(package: package.rcPackage!)
    }
    
    func restore() async throws -> SUPurchaseInfo? {
        let info = try await rc.restorePurchases()
        
        return .fromPurchaseInfo(info: info)
    }
}
