//
//  ZNCollectionViewCell.swift
//  ScrollMenu
//
//  Created by zn on 15/7/15.
//  Copyright © 2015年 zn. All rights reserved.
//  －－topMenu对应的cell

import UIKit

class ZNCollectionViewCell: UICollectionViewCell {
    
    var titleColor:UIColor = UIColor.blackColor() {
        willSet{
            self.titleLabel?.textColor = newValue as UIColor
        }
    }
    var titleName:NSString {
        get{
            return self.titleName
        }
        set{
            self.titleLabel?.text = newValue as String
        }
    
    }
    var titleLabel:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLable()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupLable()
    }
    
    func setupLable(){
        self.backgroundColor = UIColor.groupTableViewBackgroundColor()
        let titleLabel = UILabel()
        titleLabel.textAlignment = NSTextAlignment.Center
        
        titleLabel.font = UIFont.systemFontOfSize(14)
        self.addSubview(titleLabel)
        self.titleLabel = titleLabel
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.frame = self.bounds
        self.titleLabel?.textColor = self.titleColor
    }
    
}
