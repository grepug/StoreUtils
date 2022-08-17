//
//  SKProduct+Utils.swift
//  Vision 3
//
//  Created by Kai on 2021/12/28.
//

import Foundation
import RevenueCat
import StoreKit

public extension StoreProduct {
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
    
    var introductoryPriceString: String? {
        let product = self
        let introductoryPrice = product.introductoryDiscount?.price ?? 0
        
        guard introductoryPrice > 0 else {
            return nil
        }
        
        return product.localizedPriceString
    }
}

public extension Decimal {
    var doubleValue:Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
