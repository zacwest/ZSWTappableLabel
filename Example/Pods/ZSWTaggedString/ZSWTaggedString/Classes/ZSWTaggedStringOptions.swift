//
//  ZSWTaggedStringOptions.swift
//  Pods
//
//  Created by Zachary West on 12/6/15.
//
//

import ZSWTaggedString.Private

extension ZSWTaggedStringOptions {
    /**
     Dynamic attributes executed for a tag
     
     Below parameters are for an example tag of:
     
     `<a href="http://google.com">`
     
     - Parameter tagName: This would be `"a"` in the example.
     - Parameter tagAttributes: This would be `["href": "http://google.com"]` in the example.
     - Parameter existingStringAttributes: The attributes for the generated attributed string at the given tag start location before applying the given attributes.
     
     - Returns: The `NSAttributedString` attributes you wish to be applied for the tag.
     
     */
    public typealias DynamicAttributes = (_ tagName: String, _ tagAttributes: [String: Any], _ existingStringAttributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]
    
    /**
     Attributes to be applied to an attributed string.
     
     - Dynamic: Takes input about the tag to generate values.
     - Static: Always returns the same attributes.
     */
    public enum Attributes {
        case dynamic(DynamicAttributes)
        case `static`([NSAttributedString.Key: Any])
        
        init(wrapper: ZSWTaggedStringAttribute) {
            if let dictionary = wrapper.staticDictionary {
                self = .static(dictionary)
            } else if let block = wrapper.dynamicAttributes {
                self = .dynamic(block)
            } else {
                fatalError("Not static or dynamic")
            }
        }
        
        var wrapper: ZSWTaggedStringAttribute {
            let wrapper = ZSWTaggedStringAttribute()
            
            switch self {
            case .dynamic(let attributes):
                wrapper.dynamicAttributes = attributes
            case .static(let attributes):
                wrapper.staticDictionary = attributes
            }
            
            return wrapper
        }
    }
    
    /**
     Attributes to be applied for an unknown tag.
     
     For example, if you do not specify attributes for the tag `"a"` and your
     string contains it, these attributes would be invoked for it.
     */
    public var unknownTagAttributes: Attributes? {
        get {
            if let wrapper = _private_unknownTagWrapper {
                return Attributes(wrapper: wrapper)
            } else {
                return nil
            }
        }
        set {
            _private_unknownTagWrapper = newValue?.wrapper
        }
    }
    
    /**
     Attributes for a given tag name.
     
     For example, use the subscript `"a"` to set the attributes for that tag.
     */
    public subscript (tagName: String) -> Attributes? {
        get {
            if let currentValue = _private_tagToAttributesMap[tagName] {
                return Attributes(wrapper: currentValue)
            } else {
                return nil
            }
        }
        set {
            _private_setWrapper(newValue?.wrapper, forTagName: tagName)
        }
    }
}
