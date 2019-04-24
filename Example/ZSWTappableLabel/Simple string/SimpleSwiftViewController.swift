//
//  SimpleSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

import ZSWTappableLabel
import SafariServices

class SimpleSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        // note: this doesn't seem to take effect unless you pass a .font to the label, this may be a bug?
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        label.tapDelegate = self
        
        let string = NSLocalizedString("Privacy Policy", comment: "")
        let attributes: [NSAttributedString.Key: Any] = [
            .tappableRegion: true,
            .tappableHighlightedBackgroundColor: UIColor.lightGray,
            .tappableHighlightedForegroundColor: UIColor.white,
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            SimpleSwiftViewController.URLAttributeName: URL(string: "http://imgur.com/gallery/VgXCk")!
        ]
        
        label.attributedText = NSAttributedString(string: string, attributes: attributes)

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: - ZSWTappableLabelTapDelegate
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any]) {
        guard let URL = attributes[SimpleSwiftViewController.URLAttributeName] as? URL else {
            return
        }
        
        show(SFSafariViewController(url: URL), sender: self)
    }
}
