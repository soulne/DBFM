//
//  EkoButton.swift
//  DBFM
//
//  Created by 杨富彬 on 15/11/9.
//  Copyright © 2015年 bin. All rights reserved.
//

import UIKit

class EkoButton: UIButton {
    var isPlay = true
    let imgPlay = UIImage(named: "play")
    let imgPause = UIImage(named: "pause")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    func onClick(){
        isPlay = !isPlay
        if isPlay {
            self.setImage(imgPause, forState: UIControlState.Normal)
            
        }else{
            self.setImage(imgPlay, forState: UIControlState.Normal)
        }
    }
    
    func onPlay(){
        isPlay = true
        self.setImage(imgPause, forState: UIControlState.Normal)
    }
}
