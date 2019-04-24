//
//  InterfaceBuilderSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

import UIKit
import ZSWTappableLabel
import SafariServices

class InterfaceBuilderSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate {
    @IBOutlet weak var label: ZSWTappableLabel!

    // for iOS 8
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "InterfaceBuilderSwiftViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // end for iOS 8
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let attributedText = label.attributedText?.mutableCopy() as? NSMutableAttributedString {
            let range = (attributedText.string as NSString).range(of: "label")
            if range.location != NSNotFound {
                attributedText.addAttributes([
                    .tappableRegion: true,
                    .link: URL(string: "https://gotofail.com")!,
                    .tappableHighlightedBackgroundColor: UIColor.lightGray
                ], range: range)
            }
            label.attributedText = attributedText
        }
    }

    // MARK: - ZSWTappableLabelTapDelegate
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any]) {
        guard let URL = attributes[.link] as? URL else {
            return
        }
        
        show(SFSafariViewController(url: URL), sender: self)
    }
}
