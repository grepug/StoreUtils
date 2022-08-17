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
                packageItem(pkg) {
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
    
    func packageItem(_ package: Package, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(package.title)
                .foregroundColor(vm.selectedPackage == package ? .orange : .blue)
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
