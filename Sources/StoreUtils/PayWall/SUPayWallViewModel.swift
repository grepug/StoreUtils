//
//  File.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import RevenueCat

public class SUPayWallViewModel: ObservableObject {
    let pm = SUPurchaseUseCases()
    let config: SUPayWallConfig
    
    @Published public var selectedPackage: SUPackage?
    @Published public var purchaseInfo: SUPurchaseInfo?
    @Published public var state = PageState.loading
    @Published public var packages: [SUPackage] = []
    @Published public var isPurchaseLoading = false
    
    public var purchaseButtonText: String {
        selectedPackage?.purchaseText ??
        "settings_pro_loading".loc
    }
    
    public var purchaseButtonDisabled: Bool {
        if !state.isLoaded {
            return true
        }
        
        if hasPurchasedNonsubscription {
            return true
        }
        
        if let selectedPackage = selectedPackage {
            return currentPurchasedPackage.contains(selectedPackage)
        }
            
        return true
    }
    
    var currentPurchasedPackage: Set<SUPackage> {
        guard let info = purchaseInfo,
              state.isLoaded else { return [] }
        
        let activeSubscriptions = info.activeSubscriptions.compactMap { id in
            packages.first { $0.productId == id }
        }

        let activePurchases = info.nonConsumableProductIds.compactMap { id in
            packages.first { $0.productId == id }
        }

        return Set(activeSubscriptions + activePurchases)
    }
    
    var hasPurchasedNonsubscription: Bool {
        currentPurchasedPackage.contains { !$0.isSubscription }
    }
    
    public init(config: SUPayWallConfig) {
        self.config = config
        
        Task {
            await reload()
            
            if let defaultSelectedPackage = config.defaultSelectedPakcage?(packages) {
                selectedPackage = defaultSelectedPackage
            }
        }
    }
}

public extension SUPayWallViewModel {
    @MainActor
    func reload() async {
        do {
            state = .loading
            async let packagesTask = try pm.fetchPackages()
            async let infoTask = try pm.getPurchaseInfo()
            
            packages = try await packagesTask
            purchaseInfo = try await infoTask
            state = .loaded
            isPurchaseLoading = false
        } catch {
            if let error = error as? RevenueCat.ErrorCode {
                state = .error(.revenueCatError(error))
            } else {
                state = .error(.other(error))
            }
        }
    }
    
    @MainActor
    func purchase() async {
        guard let package = selectedPackage else {
            assertionFailure()
            return
        }
        
        // 处理订阅转买断的逻辑
        if !package.isSubscription && !hasPurchasedNonsubscription {
            guard await config.presentConfirm(.convertingFromSubscriptionToNonsubscription) else {
                return
            }
        }
        
        isPurchaseLoading = true
        
        do {
            let userCancelled = try await pm.purchase(package).userCancelled
            
            if userCancelled {
                config.presentErrorAlert(.purchaseFailure)
            } else {
                await reload()
                config.presentErrorAlert(.purchaseSuccess)
            }
        } catch {
            config.presentErrorAlert(.purchaseFailure)
        }
        
        isPurchaseLoading = false
    }
    
    @MainActor
    func restore() async {
        guard state.isLoaded && !isPurchaseLoading else {
            return
        }
        
        isPurchaseLoading = true
        
        do {
            let response = try await pm.restore()
            
            if response?.hasAccessToPro != true {
                config.presentErrorAlert(.restoreFailure)
            }
            
            await reload()
        } catch {
            config.presentErrorAlert(.restoreFailure)
        }
    }
    
    func selectPackage(_ pkg: SUPackage) {
        guard packageState(pkg) == .none else {
            return
        }
        
        guard pkg.rcPackage != nil else {
            return
        }
        
        selectedPackage = pkg
    }
    
    func packageState(_ pkg: SUPackage) -> SUPayWallPackageState {
        if hasPurchasedNonsubscription && pkg.isSubscription {
            return .none
        }
        
        if currentPurchasedPackage.contains(pkg) {
            return .active
        }
        
        if selectedPackage == pkg {
            return .selected
        }
        
        return .none
    }
}

extension SUPayWallViewModel {

}

public extension SUPayWallViewModel {
    enum PageState {
        case loading, error(SUError), loaded
        
        var isLoaded: Bool {
            if case .loaded = self {
                return true
            }
            
            return false
        }
    }
    
}

public enum SUPayWallPackageState {
    case selected, active, none
}

public enum SUPayWallConfirmType {
    case convertingFromSubscriptionToNonsubscription
    
    public var title: String {
        switch self {
        case .convertingFromSubscriptionToNonsubscription: return "您正在订阅，确定是否要购买永久解锁？"
        }
    }
    
    public var message: String? {
        nil
    }
}

public enum SUPayWallErrorAlertType {
    case restoreFailure, purchaseFailure, purchaseSuccess
    
    public var title: String {
        switch self {
        case .purchaseSuccess: return "action_pro_puchase_alert_success".loc
        case .restoreFailure: return "action_pro_restore_alert_error".loc
        case .purchaseFailure: return "action_pro_puchase_alert_error".loc
        }
    }
}
