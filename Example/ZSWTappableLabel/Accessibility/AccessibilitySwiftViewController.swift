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

class ViewLinkCustomAction: UIAccessibilityCustomAction {
    let range: NSRange
    let attributes: [NSAttributedString.Key: Any]
    
    init(name: String, target: Any?, selector: Selector, range: NSRange, attributes: [NSAttributedString.Key: Any]) {
        self.attributes = attributes
        self.range = range
        super.init(name: name, target: target, selector: selector)
    }
}

class AccessibilitySwiftViewController: UIViewController, ZSWTappableLabelTapDelegate, ZSWTappableLabelAccessibilityDelegate {
    let label = ZSWTappableLabel()
    
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
    
    @objc func viewLink(_ action: ViewLinkCustomAction) {
        guard let URL = action.attributes[.link] as? URL else {
            return
        }
        
        let alertController = UIAlertController(title: URL.absoluteString, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Open URL", style: .default, handler: { [weak self] _ in
            guard let this = self else {
                return
            }
            this.show(SFSafariViewController(url: URL), sender: this)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
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
            ViewLinkCustomAction(
                name: "View Link Address",
                target: self,
                selector: #selector(viewLink(_:)),
                range: characterRange,
                attributes: attributes
            )
        ]
    }
}
