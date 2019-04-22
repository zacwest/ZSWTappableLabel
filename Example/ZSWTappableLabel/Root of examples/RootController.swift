//
//  ZSWRootExampleController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2019 Zachary West. All rights reserved.
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
            return LongPressObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Accessibility", body: "Contains additional actions for links for VoiceOver users.", constructorSwift: { () -> UIViewController in
            return AccessibilitySwiftViewController()
        }, constructorObjectiveC: { () -> UIViewController in
            return AccessibilityObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "3D Touch", body: "Tap to open, long-press to share and 3D Touch for a peeking preview.", constructorSwift: { () -> UIViewController in
            return DDDTouchSwiftViewController()
        }, constructorObjectiveC: { () -> UIViewController in
            return DDDTouchObjectiveCViewController()
        }))
        
        examples.append(ExampleRow(name: "Collection View", body: "Within a UICollectionViewCell, the label only intercepts touches for the tappable regions and allows selection elsewhere.", constructorSwift: { () -> UIViewController in
            return CollectionViewSwiftViewController()
        }, constructorObjectiveC: { () -> UIViewController in
            return CollectionViewObjectiveCViewController()
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
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 75
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(RootExampleCell.self, forCellReuseIdentifier: NSStringFromClass(RootExampleCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.flashScrollIndicators()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(RootExampleCell.self), for: indexPath) as! RootExampleCell
        cell.delegate = self
        cell.configureWith(examples[indexPath.item])
        return cell
    }
    
    // MARK: - RootExampleCellDelegate
    
    fileprivate func exampleFor(_ cell: UITableViewCell) -> ExampleRow {
        guard let indexPath = tableView.indexPath(for: cell) else {
            fatalError()
        }
        
        return examples[indexPath.item]
    }
    
    func showExampleViewController(_ controller: UIViewController, forExample example: ExampleRow) {
        controller.configureWith(example)
        show(controller, sender: self)
    }
    
    func rootExampleCellSelectedSwift(_ cell: RootExampleCell) {
        let example = exampleFor(cell)
        showExampleViewController(example.constructorSwift(), forExample: example)
    }
    
    func rootExampleCellSelectedObjectiveC(_ cell: RootExampleCell) {
        let example = exampleFor(cell)
        showExampleViewController(example.constructorObjectiveC(), forExample: example)
    }
}

extension UIViewController {
    func configureWith(_ example: ExampleRow) {
        title = example.name
    }
}
