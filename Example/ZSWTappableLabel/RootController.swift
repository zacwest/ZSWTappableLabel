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
    let body: String
    let constructorSwift: () -> UIViewController
    let constructorObjectiveC: () -> UIViewController
}

class RootController: UIViewController, UITableViewDelegate, UITableViewDataSource, RootExampleCellDelegate {
    let examples: [ExampleRow]
    let tableView = UITableView()
    
    init() {
        var examples = [ExampleRow]()
        
        examples.append(ExampleRow(name: "Simple string", body: "Entirely a link. The simplest case: attributes apply to the entire thing.", constructorSwift: {
            return SimpleSwiftViewController()
        }, constructorObjectiveC: {
            return SimpleObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Multiple links", body: "Contains multiple links with different attributes, with non-links in-between.", constructorSwift: {
            return MultipleSwiftViewController()
        }, constructorObjectiveC: {
            return MultipleObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Data detectors", body: "Uses data detectors to apply links to dynamic content inside a given string.", constructorSwift: {
            return DataDetectorsSwiftViewController()
        }, constructorObjectiveC: {
            return DataDetectorsObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Interface builder", body: "Label is completely configured inside Interface Builder, and modifications are made later.", constructorSwift: {
            return InterfaceBuilderSwiftViewController()
        }, constructorObjectiveC: {
            return InterfaceBuilderObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Long press", body: "Long press triggers an Activity View Controller, tapping opens the link.", constructorSwift: { () -> UIViewController in
            return LongPressSwiftViewController()
        }, constructorObjectiveC: { () -> UIViewController in
            return LongPressSwiftViewController()
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
        tableView.estimatedRowHeight = 75
        tableView.rowHeight = UITableViewAutomaticDimension
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
    
    func showExampleViewController(controller: UIViewController, forExample example: ExampleRow) {
        controller.configureWith(example)
        showViewController(controller, sender: self)
    }
    
    func rootExampleCellSelectedSwift(cell: RootExampleCell) {
        let example = exampleFor(cell)
        showExampleViewController(example.constructorSwift(), forExample: example)
    }
    
    func rootExampleCellSelectedObjectiveC(cell: RootExampleCell) {
        let example = exampleFor(cell)
        showExampleViewController(example.constructorObjectiveC(), forExample: example)
    }
}

extension UIViewController {
    func configureWith(example: ExampleRow) {
        title = example.name
    }
}
