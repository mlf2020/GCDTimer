//
//  ViewController.swift
//  GCDTimer
//
//  Created by XieLibin on 16/7/8.
//  Copyright © 2016年 Menglingfeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        setGCDTimer()

//        GCDTimer.sharedInstance.start()
        
       _ = label.startCountDown(withTimeInterval: 70, shouldHighlightColor: UIColor.purpleColor(), progressHandler: { (timerleft) in
        
            print(timerleft)
        }) {
            
            print("=-=-=-=-=-=label完成=-=-=-=-=")
        }
    
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            
//            timer.pause()
        }
        
        
        
//        button.startCountDown(withTime: 70, forState: .Normal, progressHandler: { (timeLeft) in
//            
//            
//            }) { 
//                
//                print("button -----  完成了")
//        }

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
//        GCDTimer.start()
    }
    
    func setGCDTimer(){
        
        var count = 100
        //队列
        let global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        //timer
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global)
        
        //1 * NSEC_PER_SEC 间隔1s leeway：精准度，0为最精准
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0)
        
        dispatch_source_set_event_handler(timer) { 
            
            if count <= 0{
                //取消timer
                dispatch_source_cancel(timer)
                print("=-=-=-=-=-=-=-=-=-=-=-=倒计时结束了--=-=-=-=-=-=-=-=-=-=-=-")
                
            }else{
                print("-----------\(count)------")
                count -= 1
            }
        }
        
        //启动
        dispatch_resume(timer)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

