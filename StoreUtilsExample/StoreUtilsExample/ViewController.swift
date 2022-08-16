//
//  ViewController.swift
//  StoreUtilsExample
//
//  Created by Kai on 2022/8/16.
//

import UIKit
import DiffableList

class ViewController: DiffableListViewController {
    
    override var list: DLList {
        DLList {
            DLSection {
                DLCell {
                    DLText("hhaa")
                }
                .tag("1")
            }
            .tag("2")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "GOOD"
        reload()
    }


}

