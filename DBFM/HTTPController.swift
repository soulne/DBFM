//
//  HTTPController.swift
//  DBFM
//
//  Created by 杨富彬 on 15/11/6.
//  Copyright © 2015年 bin. All rights reserved.
//

import UIKit
import Alamofire

class HTTPController: NSObject {
    
    //定义一个代理
    var delegate:HttpProtocol?
    
    
    //接收网址，回调代理的方法传回数据
    func onSearch(url:String){
        
        Alamofire.request(Method.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers) { response -> Void in
            self.delegate?.didRecieveResults(response.result.value!)
        }
    }
}

//定义HTTP协议
protocol HttpProtocol{
    //定义一个方法接收参数：anyobject
    
    func didRecieveResults(results:AnyObject)
}