//
//  MainCollectionViewCell.swift
//  豆瓣美女
//
//  Created by lu on 15/11/12.
//  Copyright © 2015年 lu. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    var imageView  = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.frame = bounds
        imageView.contentMode = .ScaleAspectFit
        
//        imageView.layer.borderWidth = 1.0
//        imageView.layer.borderColor = UIColor.grayColor().CGColor
//        imageView.layer.cornerRadius = 6.0
//        imageView.layer.shadowColor = UIColor.grayColor().CGColor
//        imageView.layer.shadowOffset = CGSizeMake(2, 2)
//        imageView.layer.shadowOpacity = 1
//        imageView.layer.shadowRadius = 2.0
//        imageView.layer.masksToBounds = true
    }
}