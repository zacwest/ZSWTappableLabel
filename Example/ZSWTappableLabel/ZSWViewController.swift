//
//  ZSWViewController.swift
//  ZSWTappableLabel
//
//  Created by Zachary West on 12/5/15.
//  Copyright © 2015 Zachary West. All rights reserved.
//

import ZSWTappableLabel
import Swift

class ZSWViewController: UIViewController, ZSWTappableLabelTapDelegate {
    @IBOutlet var singleLabel: ZSWTappableLabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = singleLabel!
        label.tapDelegate = self
        
let string1 = NSLocalizedString("Privacy Policy", comment: "")
let attributes: [String: AnyObject] = [
  ZSWTappableLabelTappableRegionAttributeName: true,
  ZSWTappableLabelHighlightedBackgroundAttributeName: UIColor.lightGrayColor(),
  ZSWTappableLabelHighlightedForegroundAttributeName: UIColor.whiteColor(),
  NSForegroundColorAttributeName: UIColor.blueColor(),
  NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
  "URL": NSURL(string: "http://imgur.com/gallery/VgXCk")!
]

label.attributedText = NSAttributedString(string: string1, attributes: attributes)

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
            attributes["NSTextCheckingResult"] = result
            attributedString.addAttributes(attributes, range: result.range)
        }
        label.attributedText = attributedString
    }
    
    func tappableLabel(tappableLabel: ZSWTappableLabel, tappedAtIndex idx: Int, withAttributes attributes: [String : AnyObject]) {
        if let url = attributes["URL"] as? NSURL {
            UIApplication.sharedApplication().openURL(url)
        }
        
        if let result = attributes["NSTextCheckingResult"] as? NSTextCheckingResult {
            switch result.resultType {
            case [.Address]:
                print("Address components: \(result.addressComponents)")                
            case [.PhoneNumber]:
                print("Phone number: \(result.phoneNumber)")
            case [.Date]:
                print("Date: \(result.date)")
            case [.Link]:
                print("Link: \(result.URL)")
            default:
                break
            }
        }
    }
}
