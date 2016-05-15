//
//  OrderButton.swift
//  DBFM
//
//  Created by 杨富彬 on 15/11/9.
//  Copyright © 2015年 bin. All rights reserved.
//

import UIKit

class OrderButton: UIButton {
    var order = 1
    
    let order1 = UIImage(named: "order1")
    let order2 = UIImage(named: "order2")
    let order3 = UIImage(named: "order3")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(OrderButton.onClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    func onClick(sender:UIButton){
        order += 1
        if order == 1 {
            self.setImage(order1, forState: UIControlState.Normal)
        }else if order == 2{
            self.setImage(order2, forState: UIControlState.Normal)
        }else if order == 3{
            self.setImage(order3, forState: UIControlState.Normal)
        }else if order > 3{
            order = 1
            self.setImage(order1, forState: UIControlState.Normal)
        }
    }
}
