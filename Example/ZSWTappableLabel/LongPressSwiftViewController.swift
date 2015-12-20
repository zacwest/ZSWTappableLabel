//
//  LongPressSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/20/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import ZSWTappableLabel
import ZSWTaggedString
import SafariServices

class LongPressSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        label.textAlignment = .Justified
        return label
    }()
    
    static let URLAttributeName = "URL"
    
    enum LinkType: String {
        case Privacy = "privacy"
        case TermsOfService = "tos"
        
        var URL: NSURL {
            switch self {
            case .Privacy:
                return NSURL(string: "http://google.com/search?q=privacy")!
            case .TermsOfService:
                return NSURL(string: "http://google.com/search?q=tos")!
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        label.tapDelegate = self
        label.longPressDelegate = self
        label.longPressAccessibilityActionName = NSLocalizedString("Share", comment: "")
        
        let options = ZSWTaggedStringOptions()
        options["link"] = .Dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                    return [String: AnyObject]()
            }
            
            return [
                ZSWTappableLabelTappableRegionAttributeName: true,
                ZSWTappableLabelHighlightedBackgroundAttributeName: UIColor.lightGrayColor(),
                ZSWTappableLabelHighlightedForegroundAttributeName: UIColor.whiteColor(),
                NSForegroundColorAttributeName: UIColor.blueColor(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                MultipleSwiftViewController.URLAttributeName: type.URL
            ]
        })
        
        let string = NSLocalizedString("Please, feel free to peruse and enjoy our wonderful and alluring <link type='privacy'>Privacy Policy</link> or if you'd really like to understand what you're allowed or not allowed to do, reading our <link type='tos'>Terms of Service</link> is sure to be enlightening", comment: "")
        label.attributedText = try? ZSWTaggedString(string: string).attributedStringWithOptions(options)
        
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
    
    // MARK: - ZSWTappableLabelLongPressDelegate
    
    func tappableLabel(tappableLabel: ZSWTappableLabel, longPressedAtIndex idx: Int, withAttributes attributes: [String : AnyObject]) {
        guard let URL = attributes[SimpleSwiftViewController.URLAttributeName] as? NSURL else {
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
}