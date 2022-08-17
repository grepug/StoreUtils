//
//  PayWall.swift
//  StoreUtilsExample
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import StoreUtils
import SwiftUI
import UIKitUtils

struct PayWall: View {
    @ObservedObject var vm: PayWallViewModel
    
    var body: some View {
        content
            .overlay {
                if vm.isPurchaseLoading {
                    ZStack {
                        Color.white.opacity(0.3)
                        ProgressView()
                    }
                }
            }
    }
    
    var content: some View {
        VStack {
            ForEach(vm.packages) { pkg in
                packageItem(pkg, state: vm.packageState(pkg)) {
                    vm.selectedPackage = pkg
                }
            }
            
            Button {
                Task {
                    await vm.purchase()
                }
            } label: {
                Text(vm.purchaseButtonText)
                    .padding()
                    .background(vm.purchaseButtonDisabled ? .gray : Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 32)
            .foregroundColor(.white)
            .disabled(vm.purchaseButtonDisabled)
        }
    }
    
    func packageItem(_ package: Package,
                     state: PayWallPackageState,
                     action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack {
                Text(package.title)
                Text(package.currentPriceString)
                
                if let origin = package.originalPriceString {
                    Text(origin)
                        .strikethrough()
                }
            }
            .font(state.font)
            .foregroundColor(state.foregroundColor)
            .padding()
            .border(Color.gray, width: 0.3)
        }
        .buttonStyle(.plain)
    }
}

extension PayWall {
    static func makeViewController(parentVC: @escaping () -> UIViewController) -> UIViewController {
        var config = PayWallConfig {
            false
        } presentErrorAlert: { type in
            parentVC().presentAlertController(title: type.title, message: nil, actions: [.ok()])
        } presentConfirm: { type in
            let result = await parentVC().presentAlertController(title: type.title, message: type.message, actions: [.cancel, .ok])
            
            return result == .ok
        }
        
        config.defaultSelectedPakcage = { packages in
            packages[2]
        }
        
        config.configRevenueCat(withAPIKey: "FokOLeJNisqopzIIybWrDTpxIIJLNLPJ")
        
        let model = PayWallViewModel(config: config)
        let view = PayWall(vm: model)
        let vc = UIHostingController(rootView: view)
        let nav = UINavigationController(rootViewController: vc)
        
        return nav
    }
}

extension PayWallPackageState {
    var foregroundColor: Color {
        switch self {
        case .active: return .orange
        case .selected: return .blue
        case .none: return Color(UIColor.label)
        }
    }
    
    var font: Font {
        switch self {
        case .active, .selected: return .body.bold()
        case .none: return .body
        }
    }
}

extension Package {
    var originalPriceString: String? {
        let product = rcPackage.storeProduct
        
        if let introductoryPriceString = product.introductoryPriceString {
            return introductoryPriceString
        }
        
        let currencyCode = product.currencyCode ?? ""
        
        switch product.productIdentifier {
        case "vis_1y_2w_free":
            let price = product.price * 1.589
            
            return "\(currencyCode) \(price)"
        case "vis_lifetime_unlock":
            let ratio = Decimal(216) / Decimal(88)
            let price = product.price * ratio
            
            return "\(currencyCode) \(price.doubleValue.toString(toFixed: 2))"
        default: return nil
        }
    }
}

extension Double {
    func toString(toFixed fixed: Int, dropingDotZero: Bool = false) -> String {
        let string = String(format: "%.\(fixed)f", self)
        let decimal = truncatingRemainder(dividingBy: 1)
        
        if dropingDotZero && decimal == 0 {
            return String(Int(self))
        }
        
        return string
    }
}
