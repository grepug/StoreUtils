//
//  SKProduct+Utils.swift
//  Vision 3
//
//  Created by Kai on 2021/12/28.
//

import Foundation
import RevenueCat
import StoreKit

extension StoreProduct {
    var currentPriceString: String {
        let introductoryPrice = introductoryDiscount?.price ?? 0
        let introductoryPriceString = self.introductoryDiscount?.localizedPriceString ?? ""
        
        return introductoryPrice > 0 ?
        introductoryPriceString :
        localizedPriceString
    }
    
    var currentPriceDouble: Double {
        price.doubleValue
    }
    
    var originalPriceString: String? {
        let product = self
        let introductoryPrice = product.introductoryDiscount?.price ?? 0
        
        if introductoryPrice > 0 {
            return product.localizedPriceString
        }
        
        var originalPriceString: String? = nil
        
        switch product.productIdentifier {
        case "vis_1y_2w_free":
            let price = product.price * 1.589
            
            originalPriceString = "\(product.currencyCode ?? "") \(price)"
        case "vis_lifetime_unlock":
            let price = product.price * 2
            
            originalPriceString = "\(product.currencyCode ?? "") \(price)"
        default: break
        }
        
        return originalPriceString
    }
}

extension SKProductDiscount {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}

extension Decimal {
    func currency(in locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: self as NSNumber)!
    }
    
    var doubleValue:Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
