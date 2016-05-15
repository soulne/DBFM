//
//  ChannelViewController.swift
//  DBFM
//
//  Created by 杨富彬 on 15/11/6.
//  Copyright © 2015年 bin. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ChannelProtocol{
    //回调方法，将频道ID传回到代理中
    func onChangeChannel(channel_id:String)
}


class ChannelViewController: UIViewController,UITableViewDelegate {

    @IBOutlet var tv: UITableView!
    
    //申明代理
    var delegate:ChannelProtocol?
    //频道列表数据
    var channelData:[JSON] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0.8
        // Do any additional setup after loading the view.
    }
    
    
    
    //设置tableview的数据行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    //配置tableview的单元格cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCellWithIdentifier("channel", forIndexPath: indexPath)
        
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        //设置cell的标题
        cell.textLabel?.text = rowData["name"].string

        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //设置cell的显示动画为3D缩放 xy方向的缩放动画，初始值为0.1 结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25) { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    
    //选中cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowData:JSON = self.channelData[indexPath.row] as JSON
        
        let channel_id:String = rowData["channel_id"].stringValue
        
        //将频道ID反向传值给主界面
        delegate?.onChangeChannel(channel_id)
        //关闭当前页面
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
