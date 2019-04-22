//
//  LongPressSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/20/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

import ZSWTappableLabel
import ZSWTaggedString
import SafariServices

class LongPressSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .justified
        return label
    }()
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
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
        label.longPressDelegate = self
        label.longPressAccessibilityActionName = NSLocalizedString("Share", comment: "")
        
        let options = ZSWTaggedStringOptions(baseAttributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
        ])
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                    return [NSAttributedString.Key: AnyObject]()
            }
            
            return [
                .tappableRegion: true,
                .tappableHighlightedBackgroundColor: UIColor.lightGray,
                .tappableHighlightedForegroundColor: UIColor.white,
                .foregroundColor: UIColor.blue,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
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
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any]) {
        guard let URL = attributes[SimpleSwiftViewController.URLAttributeName] as? URL else {
            return
        }
        
        show(SFSafariViewController(url: URL), sender: self)
    }
    
    // MARK: - ZSWTappableLabelLongPressDelegate
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, longPressedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any]) {
        guard let URL = attributes[SimpleSwiftViewController.URLAttributeName] as? URL else {
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}
