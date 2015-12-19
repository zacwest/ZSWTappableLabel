//
//  RootExampleCell.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

protocol RootExampleCellDelegate: class {
    func rootExampleCellSelectedSwift(cell: RootExampleCell)
    func rootExampleCellSelectedObjectiveC(cell: RootExampleCell)
}

class RootExampleCell: UITableViewCell {
    weak var delegate: RootExampleCellDelegate?
    
    let swiftButton: UIButton = {
        let button = UIButton(type: .System)
        button.setTitle("Swift", forState: .Normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()
    
    let objcButton: UIButton = {
        let button = UIButton(type: .System)
        button.setTitle("Obj-C", forState: .Normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        swiftButton.addTarget(self, action: "selectButton:", forControlEvents: .TouchUpInside)
        objcButton.addTarget(self, action: "selectButton:", forControlEvents: .TouchUpInside)
        
        contentView.addSubview(swiftButton)
        contentView.addSubview(objcButton)
        
        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func selectButton(sender: UIButton) {
        if sender === swiftButton {
            delegate?.rootExampleCellSelectedSwift(self)
        } else {
            delegate?.rootExampleCellSelectedObjectiveC(self)
        }
    }
    
    override func updateConstraints() {
        swiftButton.snp_remakeConstraints { make in
            make.leading.equalTo(objcButton.snp_trailing)
            make.trailing.equalTo(contentView.snp_trailingMargin)
            make.top.equalTo(contentView.snp_topMargin)
            make.bottom.equalTo(contentView.snp_bottomMargin)
        }
        
        objcButton.snp_remakeConstraints { make in
            make.top.equalTo(contentView.snp_topMargin)
            make.bottom.equalTo(contentView.snp_bottomMargin)
        }
        
        contentView.bringSubviewToFront(swiftButton)
        contentView.bringSubviewToFront(objcButton)
        
        super.updateConstraints()
    }
    
    func configureWith(exampleRow: ExampleRow) {
        textLabel?.text = exampleRow.name
    }

}
