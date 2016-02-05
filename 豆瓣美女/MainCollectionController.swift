//
//  SecondCollectionViewController.swift
//  豆瓣美女
//
//  Created by lu on 15/12/3.
//  Copyright © 2015年 lu. All rights reserved.
//

import Foundation

//
//  MainCollectionViewController.swift
//  豆瓣美女
//
//  Created by lu on 15/11/12.
//  Copyright © 2015年 lu. All rights reserved.
//

import UIKit
import Foundation
import UIKit
import Alamofire
import Kanna
import JGProgressHUD
import SDWebImage

private let reuseIdentifier = "Cell"
private let imageBaseUrl = "http://www.dbmeinv.com/dbgroup/rank.htm?pager_offset="
private let pageBaseUrl = "http://www.dbmeinv.com/dbgroup/show.htm?cid="
class MainCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout, TopMenuDelegate{
    
    var photos = NSMutableOrderedSet()
    var photosBig = NSMutableOrderedSet()
    //    var layout: MainCollectionViewLayout?
    var populatingPhotos = false //是否在获取图片
    var currentPage = 1 //当前页数
    var isGot = false   //标志是否已经获取到数据
    var menuView:ZNTopMenuView!
    var currentType: PageType = .daxiong
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //让界面显示1秒
        //        NSThread.sleepForTimeInterval(0.5)
        configureRefresh()
        
        //初始化滑动栏
        initTop()
        //        initPageBaseUrl()
        getPageUrl()
        //设置视图
        setupView()
        
        //添加所有的按钮
        addBarItem()
        
        //获取第一页图片
        populatePhotos()
        //        self.collectionView?.header.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func getPageUrl()-> String{
        return pageBaseUrl + currentType.rawValue + "&pager_offset=" + "\(currentPage)"
    }
    /*!
    case qingchun = "qingchun" //1
    case xiaohua  = "xiaohua"  //2
    case chemo    = "chemo"    //3
    case qipao    = "qipao"    //4
    case mingxing = "mingxing" //5
    case xinggan  = "xinggan" //6
    */
    func initTop(){
        let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
        
        //设置menu的高度和位置，在navigationbar下面
        let menuView = ZNTopMenuView(frame: CGRectMake(0, navBarHeight + topViewHeight - 10, kScreenSize.width, topViewHeight))
        
        menuView.bgColor = UIColor.whiteColor()
        menuView.lineColor = UIColor.grayColor()
        menuView.delegate = self
        //设置显示的类别
        menuView.titles = ["大胸妹", "小翘臀", "黑丝袜", "美腿控", "有颜值", "大杂烩"]

        //关闭scrolltotop，不然点击status bar不会返回第一页
        menuView.setScrollToTop(false)
        self.menuView = menuView
        self.view.addSubview(menuView)
    }
    
    //MARK: - TopMenuDelegate 代理方法，点击触发
    func topMenuDidChangedToIndex(index:Int){
        self.navigationItem.title = self.menuView.titles[index] as String
        
        currentType = PhotoUtil.selectTypeByNumber(index)
        
        photos.removeAllObjects()
        photosBig.removeAllObjects()
        //清除所有图片，设置为第一页，刷新数据
        self.currentPage = 1
        
        self.collectionView?.reloadData()
        
        populatePhotos()//开始获取图片url，由于不是自己搭建的服务器，所以只能抓取HTML进行解析
    }
    
    func configureRefresh(){
        self.collectionView?.header = MJRefreshNormalHeader(refreshingBlock: { () in
            print("header")
            self.handleRefresh()
            self.collectionView?.header.endRefreshing()
        })
        
        self.collectionView?.footer = MJRefreshAutoFooter(refreshingBlock:
            { () in
                print("footer")
                self.populatePhotos()
                self.collectionView?.footer.endRefreshing()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
    }
    
    func setupView() {
        //设置标题
        self.navigationItem.title = "豆瓣美女"
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 0)
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.collectionView?.scrollsToTop = true
        self.collectionView?.frame = CGRectMake(10, 0, self.view.frame.width - 20, self.view.frame.height)
//        self.collectionView?.layer.borderWidth = 1.0
//        self.collectionView?.layer.borderColor = UIColor.grayColor().CGColor
//        self.collectionView?.layer.cornerRadius = 6.0
//        self.collectionView?.layer.masksToBounds = true
//        self.collectionView?.layer.shadowColor = UIColor.grayColor().CGColor
//        self.collectionView?.layer.shadowOffset = CGSizeMake(4, 4)
//        self.collectionView?.layer.shadowOpacity = 0.8
//        self.collectionView?.layer.shadowRadius = 4.0
        //        layout = MainCollectionViewLayout()
        //        layout?.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.bounds.size.width - 30)/2, height: ((view.bounds.size.width - 30)/2)/225.0*300.0)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        collectionView!.collectionViewLayout = layout
        self.collectionView!.registerClass(MainCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //向上滑动隐藏navigationbar
        //        navigationController?.hidesBarsOnSwipe = true
    }
    
    //添加navigationitem
    func addBarItem(){
        let item = UIBarButtonItem(image: UIImage(named: "Del"), style: UIBarButtonItemStyle.Plain, target: self, action: "setting:")
        item.tintColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItem = item
    }
    
    @IBAction func setting(sender: AnyObject){
        let alert = UIAlertController(title: "提示", message: "确认要清除图片缓存么?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: clearCache)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //清除缓存
    func clearCache(alert: UIAlertAction!){
        
        print("clear")
        let size = SDImageCache.sharedImageCache().getSize() / 1000 //KB
        var string: String
        if size/1000 >= 1{
            string = "清除缓存 \(size/1000)M"
        }else{
            string = "清除缓存 \(size)K"
        }
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
        hud.textLabel.text = string
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.showInView(self.view, animated: true)
        SDImageCache.sharedImageCache().clearDisk()
        hud.dismissAfterDelay(1.0, animated: true)
    }
    
    override func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true
    }
    
    //下拉刷新回调函数
    func handleRefresh() {
        photos.removeAllObjects()
        //        清除所有图片，设置为第一页，刷新数据
        self.currentPage = 1
        self.collectionView?.reloadData()
        
        populatePhotos()//开始获取图片
    }
    
    //检查image url，必须符合某种规则，img1.mm131.com/pic
    func checkImageUrl(imageUrl: String?)->Bool{
        //        if imageUrl == nil{
        //            return false
        //        }
        //
        //        if !imageUrl!.componentsSeparatedByString(imageBaseUrl).isEmpty{
        //            let array = imageUrl!.componentsSeparatedByString(imageBaseUrl)
        //            if array.count > 1 && !array[1].isEmpty{
        //                return true
        //            }
        //        }
        //
        //        return false
        return true
    }
    
    func transformUrl(urls: [String]){
        for url in urls{
            let urlBig = url.stringByReplacingOccurrencesOfString("bmiddle", withString: "large")
            print(urlBig)
            photosBig.addObject(urlBig)
        }
    }
    
    //设置HUD
//    func loadTextHUD(text: String, time: Float){
//        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//        loadingNotification.mode = MBProgressHUDMode.Text
//        loadingNotification.minShowTime = time
//        loadingNotification.labelText = text
//    }
    
    //获取信息
    func populatePhotos(){
        if populatingPhotos{//正在获取，则返回
            print("return back")
            return
        }
        
        //标记正在获取，其他线程获取则返回
        populatingPhotos = true
        let pageUrl = getPageUrl()
        Alamofire.request(.GET, pageUrl).validate().responseString{
            (request, response, result) in
            
            //
            let isSuccess = result.isSuccess
            let html = result.value
            let HUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
            
            if isSuccess == true{
                //设置等待菊花
                //                let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                //                loadingNotification.mode = MBProgressHUDMode.Indeterminate
                //                loadingNotification.labelText = "加载中..."
                HUD.textLabel.text = "加载中"
                HUD.showInView(self.view, animated: true)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    //用photos保存临时数据
                    var urls = [String]()
                    //用kanna解析html数据
                    if let doc = Kanna.HTML(html: html!, encoding: NSUTF8StringEncoding){
                        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)
                        let lastItem = self.photos.count
                        //解析imageurl
                        for node in doc.css("img"){
                            if self.checkImageUrl(node["src"]){
                                urls.append(node["src"]!)
                                self.isGot = true
                            }
                        }
                        
                        //怕没有获取到数据，做了个保护
                        if self.isGot{
                            self.photos.addObjectsFromArray(urls)
                            self.transformUrl(urls)
                        }
                        
                        //只刷新增加的数据，不能用reloadData，会造成闪屏
                        let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                        }
                        if self.isGot{
                            self.currentPage++
                            self.isGot = false
                        }
                    }
                }
            }else{
                //                let hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
                HUD.textLabel.text = "网络有问题，请检查网络"
                HUD.indicatorView = JGProgressHUDErrorIndicatorView()
                HUD.showInView(self.view, animated: true)
                HUD.dismissAfterDelay(1.0, animated: true)
            }
            
            //清除HUD
            //            MBProgressHUD.hideHUDForView(self.view, animated: true)
            HUD.dismiss()
            self.populatingPhotos = false
        }
    }
    
    //点击显示大图
    //    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //        performSegueWithIdentifier("BrowserPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo))
    //    }
    
    //给browser页面设置数据
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "BrowserPhoto"{
    //            let temp = segue.destinationViewController as! PhotoBrowserCollectionViewController
    //            temp.photoInfo = sender as! PhotoInfo
    //            temp.currentType = self.currentType
    //        }
    //    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: topViewHeight + 10)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView?.footer.hidden = self.photos.count == 0
        return self.photos.count
    }
    
    //点击查看大图
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var browser:PhotoBrowserView
        
        //网路数据源
        browser = PhotoBrowserView.initWithPhotos(withUrlArray: self.photosBig.array)
        //类型为网络
        browser.sourceType = SourceType.REMOTE
        
        //设置展示哪张图片
        browser.index = indexPath.row
        
        //显示
        browser.show()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MainCollectionViewCell
        
        //        let imageURL = (photos.objectAtIndex(indexPath.row) as! PhotoInfo).imageUrl

        cell.layer.borderWidth = 1.2
        cell.layer.borderColor = UIColor(red: 229/255, green: 230/255, blue: 234/255, alpha: 1).CGColor
        cell.layer.cornerRadius = 15.0
        cell.layer.masksToBounds = true
//        cell.layer.shadowColor = UIColor.grayColor().CGColor
//
//        cell.layer.shadowOffset = CGSizeMake(2, 2)
//        cell.layer.shadowOpacity = 1
//        cell.layer.shadowRadius = 6.0

        let imageURL = NSURL(string: (photos.objectAtIndex(indexPath.row) as! String))
        //复用时先置为nil，使其不显示原有图片
        cell.imageView.image = nil
        //用sdwebimage更加的方便，集成了cache，弃用原来的。。
        cell.imageView.sd_setImageWithURL(imageURL)
        
        return cell
    }
}
