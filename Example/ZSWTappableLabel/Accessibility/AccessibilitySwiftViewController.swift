//
//  AccessibilitySwiftViewController.swift
//  ZSWTappableLabel_Example
//
//  Created by Zac West on 4/20/19.
//  Copyright © 2019 Zachary West. All rights reserved.
//

import UIKit
import ZSWTappableLabel
import SafariServices

class SwiftViewLinkCustomAction: UIAccessibilityCustomAction {
    let range: NSRange
    let attributes: [NSAttributedString.Key: Any]
    
    init(name: String, target: Any?, selector: Selector, range: NSRange, attributes: [NSAttributedString.Key: Any]) {
        self.attributes = attributes
        self.range = range
        super.init(name: name, target: target, selector: selector)
    }
}

class AccessibilitySwiftViewController: UIViewController, ZSWTappableLabelTapDelegate, ZSWTappableLabelAccessibilityDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        label.tapDelegate = self
        label.accessibilityDelegate = self
        label.textAlignment = .center
        
        let string = NSLocalizedString("Privacy Policy", comment: "")
        let attributes: [NSAttributedString.Key: Any] = [
            .tappableRegion: true,
            .tappableHighlightedBackgroundColor: UIColor.lightGray,
            .tappableHighlightedForegroundColor: UIColor.white,
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: URL(string: "http://imgur.com/gallery/VgXCk")!
        ]
        
        label.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    @objc func viewLink(_ action: SwiftViewLinkCustomAction) -> Bool {
        guard let URL = action.attributes[.link] as? URL else {
            return false
        }
        
        let alertController = UIAlertController(title: URL.absoluteString, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Open URL", comment: ""), style: .default, handler: { [weak self] _ in
            guard let this = self else {
                return
            }
            this.show(SFSafariViewController(url: URL), sender: this)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
        return true
    }
    
    // MARK: - ZSWTappableLabelTapDelegate
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[.link] as? URL else {
            return
        }
        
        show(SFSafariViewController(url: URL), sender: self)
    }
    
    // MARK: - ZSWTappableLabelAccessibilityDelegate
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, accessibilityCustomActionsForCharacterRange characterRange: NSRange, withAttributesAtStart attributes: [NSAttributedString.Key : Any] = [:]) -> [UIAccessibilityCustomAction] {
        return [
            SwiftViewLinkCustomAction(
                name: NSLocalizedString("View Link Address", comment: ""),
                target: self,
                selector: #selector(viewLink(_:)),
                range: characterRange,
                attributes: attributes
            )
        ]
    }

    func tappableLabel(_ tappableLabel: ZSWTappableLabel, accessibilityLabelForCharacterRange characterRange: NSRange, withAttributesAtStart attributes: [NSAttributedString.Key : Any] = [:]) -> String? {
        if attributes[.link] != nil {
            return NSLocalizedString("Privacy Policy Label For Accessibility", comment: "Replaces the Privacy Policy text in the label")
        } else {
            return nil
        }
    }
}
