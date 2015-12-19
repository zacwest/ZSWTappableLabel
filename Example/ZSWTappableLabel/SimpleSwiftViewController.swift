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
        label.textAlignment = .Center
        return label
    }()
    
    static let URLAttributeName = "URL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        label.tapDelegate = self
        
        let string = NSLocalizedString("Privacy Policy", comment: "")
        let attributes: [String: AnyObject] = [
            ZSWTappableLabelTappableRegionAttributeName: true,
            ZSWTappableLabelHighlightedBackgroundAttributeName: UIColor.lightGrayColor(),
            ZSWTappableLabelHighlightedForegroundAttributeName: UIColor.whiteColor(),
            NSForegroundColorAttributeName: UIColor.blueColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            SimpleSwiftViewController.URLAttributeName: NSURL(string: "http://imgur.com/gallery/VgXCk")!
        ]
        
        label.attributedText = NSAttributedString(string: string, attributes: attributes)

        view.addSubview(label)
        label.snp_makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: - ZSWTappableLabelTapDelegate
    
    func tappableLabel(tappableLabel: ZSWTappableLabel, tappedAtIndex idx: Int, withAttributes attributes: [String : AnyObject]) {
        guard let URL = attributes[SimpleSwiftViewController.URLAttributeName] as? NSURL else {
            return
        }
        
        if #available(iOS 9, *) {
            showViewController(SFSafariViewController(URL: URL), sender: self)
        } else {
            UIApplication.sharedApplication().openURL(URL)
        }
    }
}
