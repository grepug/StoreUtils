//
//  File.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation

public class PayWallViewModel: ObservableObject {
    let pm = PurchaseUseCases()
    
    @Published var selectedPackage: Package?
    @Published var purchaseInfo: PurchaseInfo?
    @Published var state = PageState.loading
    @Published var packages: [Package] = []
    @Published var isPurchaseLoading = false
    
    var currentPurchasedPackage: Package? {
        guard let info = purchaseInfo,
              state.isLoaded else { return nil }
        
        let activeSubscriptions = info.activeSubscriptions.compactMap { id in
            packages.first { $0.productId == id }
        }
        
        let activePurchases = info.nonConsumableProductIds.compactMap { id in
            packages.first { $0.productId == id }
        }
        
        return activePurchases.first ?? activeSubscriptions.first
    }
    
    init() {
        Task {
            await setup()
        }
    }
}

extension PayWallViewModel {
    func setup() async {
        do {
            state = .loading
            packages = try await pm.fetchPackages()
            purchaseInfo = try await pm.getPurchaseInfo()
            state = .loaded
            isPurchaseLoading = false
        } catch {
            state = .error(error)
        }
    }
    
    func purchase() async {
        guard let package = selectedPackage else {
            assertionFailure()
            return
        }
        
        isPurchaseLoading = true
        
        do {
            let userCancelled = try await pm.purchase(package).userCancelled
            
            if userCancelled {
                
            } else {
                
            }
        } catch {

        }
        
        isPurchaseLoading = false
    }
}

public extension PayWallViewModel {
    enum PageState {
        case loading, error(Error), loaded
        
        var isLoaded: Bool {
            if case .loaded = self {
                return true
            }
            
            return false
        }
    }
}
