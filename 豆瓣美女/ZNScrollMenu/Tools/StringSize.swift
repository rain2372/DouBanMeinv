//
//  StringSize.swift
//  ScrollMenu
//
//  Created by zn on 15/7/14.
//  Copyright © 2015年 zn. All rights reserved.
//

import Foundation
import UIKit
extension NSString {
    func sizeByFont(font:UIFont) -> CGSize {
        let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
        return self.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: .UsesFontLeading, attributes: attributes as? [String : AnyObject], context: nil).size
    }
    
}