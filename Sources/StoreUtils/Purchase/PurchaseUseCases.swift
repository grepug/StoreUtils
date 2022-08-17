//
//  PurchaseUseCases.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import RevenueCat

struct PurchaseUseCases {
    private var rc: Purchases {
        RevenueCat.Purchases.shared
    }
    
    func configRevenueCat(withAPIKey key: String) {
        RevenueCat.Purchases.configure(withAPIKey: key)
    }
    
    func fetchPackages() async throws -> [Package] {
        guard let offering = try await fetchCurrentOffering() else {
            return []
        }
        
        guard let info = try await getPurchaseInfo() else {
            return []
        }
        
        let packages: [Package] = offering.availablePackages.map {
            .fromPurchasePackage($0, info: info)
        }
        let idsNotInOffering = info.allPurchasedProductIdentifiers.subtracting(packages.map(\.productId))
        
        if idsNotInOffering.isEmpty {
            return packages
        }
           
        let purchasedPackages = await getPurchasedPackage(ids: Array(idsNotInOffering))
        
        return packages + purchasedPackages
    }
    
    func getPurchaseInfo() async throws -> PurchaseInfo? {
        try await withCheckedThrowingContinuation { continuation in
            rc.getCustomerInfo { info, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let purchaseInfo = info.map { PurchaseInfo.fromPurchaseInfo(info: $0) }
                
                continuation.resume(returning: purchaseInfo)
            }
        }
    }
    
    func getPurchasedPackage(ids: [String]) async -> [Package] {
        await withCheckedContinuation { continuation in
            rc.getProducts(ids) { skProducts in
                let packages: [Package] = skProducts.map { prod in
                        .init(id: prod.productIdentifier,
                              title: prod.localizedTitle,
                              originalPriceString: prod.originalPriceString,
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
    
    func purchase(_ package: Package) async throws -> PurchaseResultData {
        try await rc.purchase(package: package.rcPackage)
    }
    
    func restore() async throws -> PurchaseInfo? {
        let info = try await rc.restorePurchases()
        
        return .fromPurchaseInfo(info: info)
    }
}

extension PurchaseUseCases {
    func fetchCurrentOffering() async throws -> RevenueCat.Offering? {
        try await rc.offerings().current
    }
}

