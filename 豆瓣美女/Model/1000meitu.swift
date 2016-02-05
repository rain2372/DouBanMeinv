//
//  1000meitu.swift
//  1000meitu
//
//  Created by lu on 15/8/24.
//  Copyright (c) 2015年 lu. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

//宏定义区
let MENU_HEIGHT:CGFloat = topViewHeight
let ERROR_OFFLINE: Int  = -1009
let ERROR_LAST: Int     = -1

//存放图片信息的类
class PhotoInfo: NSObject {
    var forumUrl: String = ""
    var imageUrl: String = ""
}

//工具函数
class PhotoUtil {
    static let imageSource: String = "5442.com"
    
    //通过id获取类型，因为网站上url的id从0开始 ["唯美", "动漫","风景","可爱","小清新","游戏", "风光", "非主流"]
    static func selectTypeByNumber(number: Int)->PageType{
        switch number{
        case 0:
            return .daxiong
        case 1:
            return .qiaotun
        case 2:
            return .heisi
        case 3:
            return .meitui
        case 4:
            return .yanzhi
        case 5:
            return .dazahui
        default:
            return .daxiong
        }
    }
    
    //网站做的比较奇怪
//    static func selectNumberByType(type: PageType)->Int{
//        switch type{
//        case .qingchun:
//            return 1
//        case .xiaohua:
//            return 2
//        case .chemo:
//            return 3
//        case .qipao:
//            return 4
//        case .mingxing:
//            return 5
//        case .xinggan:
//            return 6
//        default:
//            return 1
//        }
//    }
}

@objc public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}


    enum Router {//必须实现URLRequestConvertible
        static let baseURLString: String = "http://www.5442.com/tag"
        case PhotoPage(PageType, Int)
   
        //这里组装要请求的网页地址
        var URLRequest: String{
            var url: String

            switch self{
            case .PhotoPage(let type, let page):
                url = Router.baseURLString + "/" + type.rawValue
                if page > 1{
                    url += "/\(page)"
                }
                url += ".html"
            }
            
            return url
        }
        
        //组装每个类型的图片基本地址
        var pageSource: String{
            var url: String
            switch self{
            case .PhotoPage(let type, _):
                url = Router.baseURLString + "/" + type.rawValue + "/"
            }
            
            return url
        }
    }

    //图片有六大类
    enum PageType: String {
        case daxiong = "2" //1
        case qiaotun  = "6"  //2
        case heisi = "7"    //3
        case meitui    = "3"    //4
        case yanzhi = "4" //5
        case dazahui  = "5" //6
    }
