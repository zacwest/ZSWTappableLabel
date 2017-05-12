//
//  SimpleSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import ZSWTappableLabel
import SafariServices

class SimpleSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        label.textAlignment = .center
        return label
    }()
    
    static let URLAttributeName = "URL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        label.tapDelegate = self
        
        let string = NSLocalizedString("Privacy Policy", comment: "")
        let attributes: [String: Any] = [
            ZSWTappableLabelTappableRegionAttributeName: true,
            ZSWTappableLabelHighlightedBackgroundAttributeName: UIColor.lightGray,
            ZSWTappableLabelHighlightedForegroundAttributeName: UIColor.white,
            NSForegroundColorAttributeName: UIColor.blue,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
            SimpleSwiftViewController.URLAttributeName: URL(string: "http://imgur.com/gallery/VgXCk")!
        ]
        
        label.attributedText = NSAttributedString(string: string, attributes: attributes)

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: - ZSWTappableLabelTapDelegate
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [String : Any]) {
        guard let URL = attributes[SimpleSwiftViewController.URLAttributeName] as? URL else {
            return
        }
        
        if #available(iOS 9, *) {
            show(SFSafariViewController(url: URL), sender: self)
        } else {
            UIApplication.shared.openURL(URL)
        }
    }
}
