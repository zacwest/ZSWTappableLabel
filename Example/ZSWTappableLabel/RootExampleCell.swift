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
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        return label
    }()
    
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
        contentView.addSubview(bodyLabel)
        contentView.addSubview(nameLabel)
        
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
        nameLabel.snp_remakeConstraints { make in
            make.top.equalTo(contentView.snp_topMargin)
            make.leading.equalTo(contentView.snp_leadingMargin)
        }
        
        swiftButton.snp_remakeConstraints { make in
            make.leading.equalTo(objcButton.snp_trailing)
            make.trailing.equalTo(contentView.snp_trailingMargin)
            make.top.equalTo(contentView.snp_topMargin)
            make.height.equalTo(nameLabel)
        }
        
        objcButton.snp_remakeConstraints { make in
            make.top.equalTo(contentView.snp_topMargin)
            make.leading.greaterThanOrEqualTo(nameLabel)
            make.height.equalTo(swiftButton)
        }

        bodyLabel.snp_remakeConstraints { make in
            make.top.equalTo(nameLabel.snp_bottom).offset(5)
            make.leading.equalTo(contentView.snp_leadingMargin)
            make.trailing.equalTo(contentView.snp_trailingMargin)
            make.bottom.equalTo(contentView.snp_bottomMargin)
        }
        
        super.updateConstraints()
    }
    
    func configureWith(exampleRow: ExampleRow) {
        nameLabel.text = exampleRow.name
        bodyLabel.text = exampleRow.body
    }
}
