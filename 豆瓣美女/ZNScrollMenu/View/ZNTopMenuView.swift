//
//  ZNTopMenuView.swift
//  ScrollMenu
//
//  Created by zn on 15/7/9.
//  Copyright © 2015年 zn. All rights reserved.
//  顶部可以滚动横条

import UIKit
private let reuseIdentifier = "Cell"


let topViewHeight: CGFloat = 30.0

protocol TopMenuDelegate {
    func topMenuDidChangedToIndex(index:Int)
}

class ZNTopMenuView: UIView,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    private var collection: UICollectionView?
    private var flowLayout: UICollectionViewFlowLayout?
    private var lineView: UIView?
    
    //整行menu背景颜色
    var bgColor: UIColor?
    
    /* 下方跟随滚动的线条的颜色 */
    var lineColor: UIColor?
    
    /* 所有的标题 */
    var titles = [NSString]()
    
    var delegate: TopMenuDelegate?
    

    init() {
         super.init(frame: CGRectMake(0.0, kStatusHeight, kScreenSize.width, topViewHeight))
        self.setupCollectionView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupCollectionView()
    }

    func setScrollToTop(value: Bool){
        self.collection?.scrollsToTop = value
    }
    
    //MARK: - 设置item 用collectionView的方式
    func setupCollectionView(){
        //设置collectionView的布局
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        self.flowLayout = flowLayout
        
        //设置 collectionView
        let collection = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.bounces = true
        collection.backgroundColor = UIColor.clearColor()
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        
        self.addSubview(collection)
        self.collection = collection
        
        //设置底部跟随滚动的线
        let bottomView = UIView()
        bottomView.backgroundColor = self.lineColor ?? UIColor.grayColor()
        self.collection!.addSubview(bottomView)
        self.lineView = bottomView
        
        //注册cell
        self.collection?.registerClass(ZNCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
    }
    
    override func layoutSubviews() {
        self.backgroundColor = bgColor ?? UIColor.whiteColor()
        self.collection?.frame = self.bounds
        self.lineView!.frame = CGRectMake(2, topViewHeight - 2, self.titles[0].sizeByFont(UIFont.systemFontOfSize(14)).width + 20, 2);
    }
    
    //MARK: - collectionViewDataSource method
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.titles.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ZNCollectionViewCell
        cell.titleName = self.titles[indexPath.item]
        cell.backgroundColor = UIColor.clearColor()
        cell.titleColor = UIColor.grayColor()
        if indexPath.item == self.titles.count-1 {
          let width = CGRectGetMaxX(cell.frame)
            if width < kScreenSize.width {
                self.setCollectionFrame(cell.frame)
            }
            
        }
        return cell
    }
    //MARK: - 设置collection的frame
    func setCollectionFrame(lastItemFrame : CGRect){
        let cWidth:CGFloat = CGRectGetMaxX(lastItemFrame)
        let cHeight:CGFloat = topViewHeight
        let cX:CGFloat = (kScreenSize.width - cWidth)/2.0
        let cY:CGFloat = self.bounds.origin.y
        self.collection?.frame = CGRectMake(cX, cY, cWidth, cHeight)
    
    }
    //MARK: - UICollectionViewDelegate method
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.moveTopMenu(indexPath)
        
        //当点击了menu 通知代理
        self.delegate?.topMenuDidChangedToIndex(indexPath.item)
     
    }
    //移动topMenu 及滚动的线
    func moveTopMenu(indexPath: NSIndexPath){
        let cell = self.collection!.cellForItemAtIndexPath(indexPath) as? ZNCollectionViewCell
        UIView.animateWithDuration(0.25) { () -> Void in
            self.lineView!.frame = CGRectMake(cell!.frame.origin.x, cell!.frame.size.height-2, cell!.frame.size.width , 2);
        }
        
        var nextIndexPath = NSIndexPath(forItem: indexPath.item+2, inSection: 0)
        if nextIndexPath.item > self.titles.count-1 {
            nextIndexPath = NSIndexPath(forItem: self.titles.count-1, inSection: 0)
        }
        var lastIndexPath = NSIndexPath(forItem: indexPath.item-2, inSection: 0)
        if lastIndexPath.item < 0 {
            lastIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        }
        let visibleItems = self.collection?.indexPathsForVisibleItems()
        
        if let visibleItem = visibleItems  {
            if !contains(visibleItem, value: nextIndexPath) || nextIndexPath.item == self.titles.count-1 {
                self.collection?.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
            }
            if !contains(visibleItem, value: lastIndexPath) || lastIndexPath.item == 0 {
                self.collection?.scrollToItemAtIndexPath(lastIndexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            }
            
        }
    }
    
    func contains(array: [AnyObject], value: NSIndexPath)->Bool{
        for item in array{
            if item as! NSObject == value{
                return true
            }
        }
        
        return false
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout method
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        let titleSize = self.titles[indexPath.item].sizeByFont(UIFont.systemFontOfSize(14))
        return CGSizeMake(titleSize.width+20, topViewHeight)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
