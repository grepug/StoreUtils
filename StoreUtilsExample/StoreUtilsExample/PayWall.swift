//
//  PayWall.swift
//  StoreUtilsExample
//
//  Created by Kai on 2022/8/16.
//

import Foundation
import StoreUtils
import SwiftUI

struct PayWall: View {
    @ObservedObject var vm: PayWallViewModel
    
    var body: some View {
        HStack {
            Color.red
            ForEach(vm.packages) { pkg in
                Text(pkg.title)
            }
        }
    }
}
