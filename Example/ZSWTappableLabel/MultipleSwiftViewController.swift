//
//  MultipleSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import UIKit
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices

class MultipleSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        label.textAlignment = .justified
        return label
    }()
    
    static let URLAttributeName = "URL"
    
    enum LinkType: String {
        case Privacy = "privacy"
        case TermsOfService = "tos"
        
        var URL: Foundation.URL {
            switch self {
            case .Privacy:
                return Foundation.URL(string: "http://google.com/search?q=privacy")!
            case .TermsOfService:
                return Foundation.URL(string: "http://google.com/search?q=tos")!
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        label.tapDelegate = self
        
        let options = ZSWTaggedStringOptions()
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                return [String: AnyObject]()
            }
            
            return [
                ZSWTappableLabelTappableRegionAttributeName: true,
                ZSWTappableLabelHighlightedBackgroundAttributeName: UIColor.lightGray,
                ZSWTappableLabelHighlightedForegroundAttributeName: UIColor.white,
                NSForegroundColorAttributeName: UIColor.blue,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                MultipleSwiftViewController.URLAttributeName: type.URL
            ]
        })
        
        let string = NSLocalizedString("Please, feel free to peruse and enjoy our wonderful and alluring <link type='privacy'>Privacy Policy</link> or if you'd really like to understand what you're allowed or not allowed to do, reading our <link type='tos'>Terms of Service</link> is sure to be enlightening", comment: "")
        label.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: - ZSWTappableLabelTapDelegate
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [String : Any] = [:]) {
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
