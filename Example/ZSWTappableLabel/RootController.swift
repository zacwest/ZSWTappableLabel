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

class RootController: UIViewController, UITableViewDelegate, UITableViewDataSource, RootExampleCellDelegate {
    let examples: [ExampleRow]
    let tableView = UITableView()
    
    init() {
        var examples = [ExampleRow]()
        
        examples.append(ExampleRow(name: "Simple string", constructorSwift: {
            return SimpleSwiftViewController()
        }, constructorObjectiveC: {
            return SimpleObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Multiple links", constructorSwift: {
            return MultipleSwiftViewController()
        }, constructorObjectiveC: {
            return MultipleObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Data detectors", constructorSwift: {
            return DataDetectorsSwiftViewController()
        }, constructorObjectiveC: {
            return DataDetectorsObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Interface builder", constructorSwift: {
            return InterfaceBuilderSwiftViewController()
        }, constructorObjectiveC: {
            return InterfaceBuilderObjectiveCViewController()
        }))
        
        self.examples = examples
        
        super.init(nibName: nil, bundle: nil)
        title = "Examples"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.snp_makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 75
        tableView.registerClass(RootExampleCell.self, forCellReuseIdentifier: NSStringFromClass(RootExampleCell))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.flashScrollIndicators()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
