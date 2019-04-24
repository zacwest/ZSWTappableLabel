//
//  DataDetectorsSwiftViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/19/15.
//  Copyright © 2019 Zachary West. All rights reserved.
//

import UIKit
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices

class DataDetectorsSwiftViewController: UIViewController, ZSWTappableLabelTapDelegate {
    let label: ZSWTappableLabel = {
        let label = ZSWTappableLabel()
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    static let TextCheckingResultAttributeName = NSAttributedString.Key(rawValue: "TextCheckingResultAttributeName")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        label.tapDelegate = self
        
        let string = "check google.com or call 415-555-5555? how about friday at 5pm?"
        
        let detector = try! NSDataDetector(types: NSTextCheckingAllSystemTypes)
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
        ])
        let range = NSRange(location: 0, length: (string as NSString).length)
        
        detector.enumerateMatches(in: attributedString.string, options: [], range: range) { (result, flags, _) in
            guard let result = result else { return }
            
            var attributes = [NSAttributedString.Key: Any]()
            attributes[.tappableRegion] = true
            attributes[.tappableHighlightedBackgroundColor] = UIColor.lightGray
            attributes[.tappableHighlightedForegroundColor] = UIColor.white
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[DataDetectorsSwiftViewController.TextCheckingResultAttributeName] = result
            attributedString.addAttributes(attributes, range: result.range)
        }
        label.attributedText = attributedString
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: - ZSWTappableLabelTapDelegate
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any]) {
        var URL: URL?
        
        if let result = attributes[DataDetectorsSwiftViewController.TextCheckingResultAttributeName] as? NSTextCheckingResult {
            switch result.resultType {
            case [.address]:
                print("Address components: \(String(describing: result.addressComponents))")
            case [.phoneNumber]:
                var components = URLComponents()
                components.scheme = "tel"
                components.host = result.phoneNumber
                URL = components.url
            case [.date]:
                print("Date: \(String(describing: result.date))")
            case [.link]:
                URL = result.url
            default:
                break
            }
        }
        
        if let URL = URL {
            if let scheme = URL.scheme?.lowercased(), ["http", "https"].contains(scheme) {
                show(SFSafariViewController(url: URL), sender: self)
            } else {
                UIApplication.shared.open(URL, options: [:], completionHandler: nil)
            }
        }
    }
}
