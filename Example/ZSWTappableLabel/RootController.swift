//
//  ZSWRootExampleController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import UIKit

struct ExampleRow {
    let name: String
    let constructorSwift: () -> UIViewController
    let constructorObjectiveC: () -> UIViewController
}

class RootController: UITableViewController, RootExampleCellDelegate {
    let examples: [ExampleRow]
    
    init() {
        var examples = [ExampleRow]()
        
        examples.append(ExampleRow(name: "Simple string", constructorSwift: { () -> UIViewController in
            return SimpleSwiftViewController()
        }, constructorObjectiveC: { () -> UIViewController in
            return SimpleObjectiveCViewController()
        }))
        
        self.examples = examples
        
        super.init(style: .Plain)
        
        title = "Examples"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 75
        tableView.registerClass(RootExampleCell.self, forCellReuseIdentifier: NSStringFromClass(RootExampleCell))
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(RootExampleCell), forIndexPath: indexPath) as! RootExampleCell
        cell.delegate = self
        cell.configureWith(examples[indexPath.item])
        return cell
    }
    
    // MARK: - RootExampleCellDelegate
    
    private func exampleFor(cell: UITableViewCell) -> ExampleRow {
        guard let indexPath = tableView.indexPathForCell(cell) else {
            fatalError()
        }
        
        return examples[indexPath.item]
    }
    
    func rootExampleCellSelectedSwift(cell: RootExampleCell) {
        let example = exampleFor(cell)
        showViewController(example.constructorSwift(), sender: self)
    }
    
    func rootExampleCellSelectedObjectiveC(cell: RootExampleCell) {
        let example = exampleFor(cell)
        showViewController(example.constructorObjectiveC(), sender: self)
    }
}
