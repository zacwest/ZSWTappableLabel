//
//  ZSWRootExampleController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import UIKit

class RootController: UITableViewController {
    struct ExampleRow {
        let name: String
        let constructor: () -> UIViewController
    }
    
    init() {
        super.init(style: .Plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
