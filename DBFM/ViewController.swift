//
//  ViewController.swift
//  DBFM
//
//  Created by 杨富彬 on 15/11/5.
//  Copyright © 2015年 bin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MediaPlayer
import AVKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HttpProtocol,ChannelProtocol {
// Ekoimage组件 歌曲封面
    @IBOutlet var iv: EkoImage!
    // 歌曲列表
    @IBOutlet var tv: UITableView!
    //背景
    @IBOutlet var bg: UIImageView!
    
    //网络操作类的实例
    var eHttp: HTTPController = HTTPController()
    
    //定义一个变量接收频道的歌曲数据
    var tableData:[JSON] = []
    
    //定义一个变量接收频道数据
    var channelData:[JSON] = []
    

    //定义图片缓存字典
    var imageCache = Dictionary<String,UIImage>()
    
    //申明一个媒体播放器示例
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    var audioPlayers : AVPlayerViewController = AVPlayerViewController()
    
    //定义一个计时器
    var timer:NSTimer?
    
    @IBOutlet var playerTime: UILabel!
    @IBOutlet var progress: UIImageView!
    
    
    @IBOutlet var btnNext: UIButton!
    
    @IBOutlet var btnPre: UIButton!
    @IBOutlet var btnPlay: EkoButton!
    
    //当前播放歌曲的索引
    var currIndex:Int = 0
    
    //播放顺序按钮
    @IBOutlet var btnOrder:OrderButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iv.onRotation()
        
        //设置背景模糊
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        bg.addSubview(blurView)
        
        //设置tableview的数据源和代理
        tv.dataSource = self
        tv.delegate = self
        

        
        //为网络操作类设置代理
        eHttp.delegate = self
        //获取频道数据
        eHttp.onSearch("http://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
        
        //让tableview的背景透明
        tv.backgroundColor = UIColor.clearColor()
        
        self.btnPlay.addTarget(self, action: "onPlay:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnNext.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnPre.addTarget(self, action: "onClick:", forControlEvents: UIControlEvents.TouchUpInside)
        self.btnOrder.addTarget(self, action: "onOrder:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //播放结束通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playFinish", name: MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer)
    }
    
    var isAutoFinish = true
    
    //人为结束的三种情况 1.点击上一首下一首 2.选择频道列表 3. 点击了歌曲列表的某行
    
    func playFinish(){
        if self.isAutoFinish{
        switch(btnOrder.order){
        case 1:
            currIndex++
            if currIndex > tableData.count - 1 {
                currIndex = 0
            }
            onSelectRow(currIndex)
        case 2:
            currIndex = random() % tableData.count
            onSelectRow(currIndex)
        case 3:
            onSelectRow(currIndex)
        default:
            "default"
        }
        }else{
            isAutoFinish = true
        }
    }
    
    func onOrder(btn:OrderButton){
        var message = ""
        switch(btn.order){
        case 1:
            message = "顺序播放"
        case 2:
            message = "随机播放"
        case 3:
            message = "单曲循环"
        default:
            message = ""
        }
    }
    
    func onClick(btn:UIButton){
        if btn == btnNext{
            self.currIndex++
            if self.currIndex > self.tableData.count - 1 {
                self.currIndex = 0
            }
           
        }else{
            self.currIndex--
            if self.currIndex  < 0{
                self.currIndex = self.tableData.count - 1
            }
            
        }
        onSelectRow(self.currIndex)
        isAutoFinish = false
    }
    
    func onPlay(btn:EkoButton){
        if btn.isPlay{
            self.audioPlayer.play()
        }else{
            self.audioPlayer.pause()
        }
    }
    //设置tableview的数据行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    //配置tableview的单元格cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCellWithIdentifier("douban", forIndexPath: indexPath)
        
        //让单元格透明
        cell.backgroundColor = UIColor.clearColor()
        
        //获取每一行的数据
        let rowData:JSON = tableData[indexPath.row]
       
        //设置cell的标题
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["artist"].string
        
//        cell.imageView?.image = UIImage(named: "thumb")
//         封面的网址
        let url = rowData["picture"].string
        
        
            onGetCacheImage(url!, imgView: cell.imageView!)
            
        
        
        return cell
    }
    //点击了哪一首歌曲
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        onSelectRow(indexPath.row)
        isAutoFinish = false
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //设置cell的显示动画为3D缩放 xy方向的缩放动画，初始值为0.1 结束值为1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25) { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    
    //选中了哪一行
    func onSelectRow(index:Int){
        //构建一个indexpath
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        //选中的效果
        tv.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        //获取行数据
        var rowData:JSON = self.tableData[index] as JSON
        //获取图片的地址
        let imgUrl = rowData["picture"].string
        //设置封面以及背景
        onSetImage(imgUrl!)
        
        //获取音乐的文件地址
        let url:String = rowData["url"].string!
        
        //播放音乐
        onSetAudio(url)
        print(url)
//        onSetAv(url)
    }
    
    //设置歌曲的封面以及北京
    func onSetImage(url:String){
        onGetCacheImage(url, imgView: self.iv)
        onGetCacheImage(url, imgView: self.bg)
    }
    
    //播放音乐的方法
    func onSetAudio(url:String){
       
        isAutoFinish = true
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: url)
        self.audioPlayer.play()
        //先停止计时器
        timer?.invalidate()
        //计时器归零
        playerTime.text = "00:00"
        //启动计时器
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onUpdate", userInfo: nil, repeats: true)
        btnPlay.onPlay()
        
    }
    
    func onSetAv(url:String){
        self.audioPlayers.player?.pause()
        let musicUrl = NSURL(string: url)
        self.audioPlayers.player = AVPlayer(URL: musicUrl!)
        self.audioPlayers.player?.play()
        
        
    }
    
    func onUpdate(){
      
        
        //获取当前歌曲的播放时间
        let c = audioPlayer.currentPlaybackTime
        
        
        
        
        if c > 0.0{
            
            //歌曲总时间
            let t = audioPlayer.duration
            //计算百分比
            let pro:CGFloat = CGFloat(c/t)
            //按百分比显示进度条宽度
            print(pro)
            progress.frame.size.width = view.frame.size.width * pro
            
            //小算法，实现时间格式转换
            let all:Int = Int(c)
            let m:Int = all % 60
            let f:Int = Int(all/60)
            var time:String = ""
            if f < 10 {
                time = "0\(f)"
            }else{
                time = "\(f)"
            }
            
            if m<10 {
                time += ":0\(m)"
            }else{
                time += ":\(m)"
            }
        playerTime.text = time
    
        }
    }
    
    
    // 图片缓存策略方法
    func onGetCacheImage(url:String,imgView:UIImageView){
        //通过图片地址去缓存仲取图片
        let image = self.imageCache[url] as UIImage?
        if image == nil {
            //如果缓存中没有这张图片，就通过网络获取
            Alamofire.request(Method.GET, url).response(completionHandler: { (_, _, data, error) -> Void in
                //将获取的图片数据赋予给imgview
                let img = UIImage(data: data! as NSData)
                imgView.image = img
                
                self.imageCache[url] = img
            })
        }else {
            imgView.image = image!
        }
    }
    
    //自定义网络协议的获取数据func
    func didRecieveResults(results:AnyObject){
//        print("\(results)")
        isAutoFinish = false
        let json = JSON(results)
        
        if let channels = json["channels"].array{
            self.channelData = channels
        }else if let song = json["song"].array{
            self.tableData = song
            //刷新tv的数据
            self.tv.reloadData()
            
            onSelectRow(0)
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //获取跳转目标
        let channelC:ChannelViewController = segue.destinationViewController as! ChannelViewController
        //设置代理
        channelC.delegate = self
        //传输频道数据
        channelC.channelData = self.channelData
    }
    
    //频道列表协议的回调方法
    func onChangeChannel(channel_id:String){
        //拼错频道列表的歌曲数据网络地址
//        http://douban.fm/j/mine/playlist?type=n&channel= 频道ID &from=mainsite
        let url:String = "http://douban.fm/j/mine/playlist?type=n&channel=\(channel_id)&from=mainsite"
        eHttp.onSearch(url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

