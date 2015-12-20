//
//  InterfaceBuilderSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import UIKit
import ZSWTappableLabel
import SafariServices

class InterfaceBuilderSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate {
    @IBOutlet weak var label: ZSWTappableLabel!

    // for iOS 8
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "InterfaceBuilderSwiftViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // end for iOS 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let attributedText = label.attributedText?.mutableCopy() as? NSMutableAttributedString {
            let range = (attributedText.string as NSString).rangeOfString("label")
            if range.location != NSNotFound {
                attributedText.addAttributes([
                    ZSWTappableLabelTappableRegionAttributeName: true,
                    NSLinkAttributeName: NSURL(string: "https://gotofail.com")!,
                    ZSWTappableLabelHighlightedBackgroundAttributeName: UIColor.lightGrayColor()
                ], range: range)
            }
            label.attributedText = attributedText
        }
    }

    // MARK: - ZSWTappableLabelTapDelegate
    func tappableLabel(tappableLabel: ZSWTappableLabel, tappedAtIndex idx: Int, withAttributes attributes: [String : AnyObject]) {
        guard let URL = attributes[NSLinkAttributeName] as? NSURL else {
            return
        }
        
        if #available(iOS 9, *) {
            showViewController(SFSafariViewController(URL: URL), sender: self)
        } else {
            UIApplication.sharedApplication().openURL(URL)
        }
    }
}
