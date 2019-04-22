//
//  3DTouchSwiftViewController.swift
//  ZSWTappableLabel_Example
//
//  Created by Zac West on 4/20/19.
//  Copyright © 2019 Zachary West. All rights reserved.
//

import UIKit
import ZSWTappableLabel
import SafariServices

class DDDTouchSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate, UIViewControllerPreviewingDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        label.tapDelegate = self
        label.longPressDelegate = self
        label.textAlignment = .center
        let string = NSLocalizedString("Privacy Policy", comment: "")
        let attributes: [NSAttributedString.Key: Any] = [
            .tappableRegion: true,
            .tappableHighlightedBackgroundColor: UIColor.lightGray,
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
        
        registerForPreviewing(with: self, sourceView: label)
    }

    // MARK: - ZSWTappableLabelTapDelegate
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[.link] as? URL else {
            return
        }
        
        show(SFSafariViewController(url: URL), sender: self)
    }
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, longPressedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[.link] as? URL else {
            return
        }
        
        present(UIActivityViewController(activityItems: [URL], applicationActivities: nil), animated: true, completion: nil)
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let regionInfo = label.tappableRegionInfo(forPreviewingContext: previewingContext, location: location) else {
            return nil
        }
        
        guard let URL = regionInfo.attributes[.link] as? URL else {
            return nil
        }
    
        // convenience method that sets the rect of the previewing context
        regionInfo.configure(previewingContext: previewingContext)
    
        return SFSafariViewController(url: URL)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
