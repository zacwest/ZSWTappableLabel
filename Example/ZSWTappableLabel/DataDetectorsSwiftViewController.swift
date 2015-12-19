//
//  DataDetectorsSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import UIKit
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices

class DataDetectorsSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        return label
    }()
    
    static let TextCheckingResultAttributeName = "TextCheckingResultAttributeName"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        label.tapDelegate = self
        
        let string = "check google.com or call 415-555-5555? how about friday at 5pm?"
        
        let detector = try! NSDataDetector(types: NSTextCheckingAllSystemTypes)
        let attributedString = NSMutableAttributedString(string: string, attributes: nil)
        let range = NSRange(location: 0, length: (string as NSString).length)
        
        detector.enumerateMatchesInString(attributedString.string, options: [], range: range) { (result, flags, _) in
            guard let result = result else { return }
            
            var attributes = [String: AnyObject]()
            attributes[ZSWTappableLabelTappableRegionAttributeName] = true
            attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = UIColor.lightGrayColor()
            attributes[ZSWTappableLabelHighlightedForegroundAttributeName] = UIColor.whiteColor()
            attributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleSingle.rawValue
            attributes[DataDetectorsSwiftViewController.TextCheckingResultAttributeName] = result
            attributedString.addAttributes(attributes, range: result.range)
        }
        label.attributedText = attributedString
        
        view.addSubview(label)
        label.snp_makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: - ZSWTappableLabelTapDelegate
    
    func tappableLabel(tappableLabel: ZSWTappableLabel, tappedAtIndex idx: Int, withAttributes attributes: [String : AnyObject]) {
        var URL: NSURL?
        
        if let result = attributes[DataDetectorsSwiftViewController.TextCheckingResultAttributeName] as? NSTextCheckingResult {
            switch result.resultType {
            case [.Address]:
                print("Address components: \(result.addressComponents)")
            case [.PhoneNumber]:
                let components = NSURLComponents()
                components.scheme = "tel"
                components.host = result.phoneNumber
                URL = components.URL
            case [.Date]:
                print("Date: \(result.date)")
            case [.Link]:
                URL = result.URL
            default:
                break
            }
        }
        
        if let URL = URL {
            if #available(iOS 9, *) {
                if ["http", "https"].contains(URL.scheme.lowercaseString) {
                    showViewController(SFSafariViewController(URL: URL), sender: self)
                } else {
                    UIApplication.sharedApplication().openURL(URL)
                }
            } else {
                UIApplication.sharedApplication().openURL(URL)
            }
        }
    }
}
