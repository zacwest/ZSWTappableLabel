//
//  RootExampleCell.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

protocol RootExampleCellDelegate: class {
    func rootExampleCellSelectedSwift(_ cell: RootExampleCell)
    func rootExampleCellSelectedObjectiveC(_ cell: RootExampleCell)
}

class RootExampleCell: UITableViewCell {
    weak var delegate: RootExampleCellDelegate?
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    
    let swiftButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle("Swift", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()
    
    let objcButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitle("Obj-C", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        swiftButton.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
        objcButton.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
        
        contentView.addSubview(swiftButton)
        contentView.addSubview(objcButton)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(nameLabel)
        
        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    @objc func selectButton(_ sender: UIButton) {
        if sender === swiftButton {
            delegate?.rootExampleCellSelectedSwift(self)
        } else {
            delegate?.rootExampleCellSelectedObjectiveC(self)
        }
    }
    
    override func updateConstraints() {
        nameLabel.snp.remakeConstraints { make in
            make.top.equalTo(contentView.snp.topMargin)
            make.leading.equalTo(contentView.snp.leadingMargin)
        }
        
        swiftButton.snp.remakeConstraints { make in
            make.leading.equalTo(objcButton.snp.trailing)
            make.trailing.equalTo(contentView.snp.trailingMargin)
            make.top.equalTo(contentView.snp.topMargin)
            make.height.equalTo(nameLabel)
        }
        
        objcButton.snp.remakeConstraints { make in
            make.top.equalTo(contentView.snp.topMargin)
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing)
            make.height.equalTo(swiftButton)
        }

        bodyLabel.snp.remakeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.trailing.equalTo(contentView.snp.trailingMargin)
            make.bottom.equalTo(contentView.snp.bottomMargin)
        }
        
        super.updateConstraints()
    }
    
    func configureWith(_ exampleRow: ExampleRow) {
        nameLabel.text = exampleRow.name
        bodyLabel.text = exampleRow.body
    }
}
