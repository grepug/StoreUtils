//
//  File.swift
//  
//
//  Created by Kai on 2022/8/16.
//

import Foundation

public class PayWallViewModel: ObservableObject {
    let pm = PurchaseUseCases()
    let config: PayWallConfig
    
    @Published public var selectedPackage: Package?
    @Published public var purchaseInfo: PurchaseInfo?
    @Published public var state = PageState.loading
    @Published public var packages: [Package] = []
    @Published public var isPurchaseLoading = false
    
    public var purchaseButtonText: String {
        selectedPackage?.purchaseText ??
        "settings_pro_loading"
    }
    
    public var purchaseButtonDisabled: Bool {
        if currentPurchasedPackage?.isSubscription == false {
            return true
        }
        
        return selectedPackage == currentPurchasedPackage || !state.isLoaded
    }
    
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
    
    public init(config: PayWallConfig) {
        self.config = config
        
        Task {
            await reload()
            
            if let defaultSelectedPackage = config.defaultSelectedPakcage?(packages) {
                selectedPackage = defaultSelectedPackage
            }
        }
    }
    
    @MainActor
    func reload() async {
        do {
            state = .loading
            async let packagesTask = try pm.fetchPackages()
            async let infoTask = try pm.getPurchaseInfo()
            let (packages, info) = try await (packagesTask, infoTask)
            
            self.packages = packages
            self.purchaseInfo = info
            self.state = .loaded
            self.isPurchaseLoading = false
        } catch {
            self.state = .error(error)
        }
    }
}

public extension PayWallViewModel {
    @MainActor
    func purchase() async {
        guard let package = selectedPackage else {
            assertionFailure()
            return
        }
        
        // 处理订阅转买断的逻辑
        if !package.isSubscription && currentPurchasedPackage?.isSubscription == true {
            guard await config.presentConfirm(.convertingFromSubscriptionToLifetime) else {
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
    
    func packageState(_ pkg: Package) -> PayWallPackageState {
        if currentPurchasedPackage == pkg {
            return .active
        }
        
        if selectedPackage == pkg {
            return .selected
        }
        
        return .none
    }
}

extension PayWallViewModel {

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

public enum PayWallPackageState {
    case selected, active, none
}

public enum PayWallConfirmType {
    case convertingFromSubscriptionToLifetime
    
    public var title: String {
        switch self {
        case .convertingFromSubscriptionToLifetime: return "您正在订阅，确定是否要购买永久解锁？"
        }
    }
    
    public var message: String? {
        nil
    }
}

public enum PayWallErrorAlertType {
    case restoreFailure, purchaseFailure, purchaseSuccess
    
    public var title: String {
        switch self {
        case .purchaseSuccess: return "action_pro_puchase_alert_success".loc
        case .restoreFailure: return "action_pro_restore_alert_error".loc
        case .purchaseFailure: return "action_pro_puchase_alert_error".loc
        }
    }
}
