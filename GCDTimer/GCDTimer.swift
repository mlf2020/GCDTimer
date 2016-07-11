//
//  GCDTimer.swift
//  GCDTimer
//
//  Created by Menglingfeng on 16/7/8.
//  Copyright © 2016年 Menglingfeng. All rights reserved.
//

import UIKit


class GCDTimer : NSObject{

    //是否正在倒计时中
    var isCounting = false
    var isPaused = false
    
    //队列
    lazy var queue : dispatch_queue_t = {
        let global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        return global
    }()
    
    //timer
    lazy var timer : dispatch_source_t = {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue)
        return timer
    }()

     func startTimer(withInterval timerInterval : NSTimeInterval,
                                       progressHandler handler:((NSTimeInterval)->Void)?,
                                       completion:(()->Void)?){
        guard timerInterval > 0 else{
            return
        }
        
        var countDownTime = timerInterval
        //1 * NSEC_PER_SEC 间隔1s leeway：精准度，0为最精准
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0)
        dispatch_source_set_event_handler(timer) {
            
            if countDownTime <= 0{
                //取消timer
                dispatch_source_cancel(self.timer)
                dispatch_async(dispatch_get_main_queue(), {
                    self.isCounting = false
                    completion?()
                })
            }else{
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.isCounting = true
                    countDownTime -= 1
                    handler?(countDownTime)
                })
            }
        }
        
        //启动
        dispatch_resume(timer)

    }
    
    func pause(after time : NSTimeInterval){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            
            self.pause()
        }
    }
    
    func pause(){
        dispatch_suspend(timer)
        isPaused = true
    }
    
    func start(){
        if isPaused {
            dispatch_resume(timer)
            isPaused = false
        }
    }
}

 func formatTime(time : NSTimeInterval) -> String{
    
    guard time > 0 else{
        return "00:00:00"
    }
    
    let intTime = Int(time)
    
    let seconds = intTime % 60
    let minutes = (intTime / 60) % 60
    let hours = intTime / 3600
    
    let doubleHour : Bool = hours > 9 ? true : false
    var format = doubleHour ? "%02d:%02d:%02d" : "%01d:%02d:%02d"
    if hours == 0{
       format = "%02d:%02d:%02d"
    }
    
    return String(format: format, arguments: [hours,minutes,seconds])
}

func highlightNumberBackground(withNumberString number : String,color : UIColor!) -> NSMutableAttributedString?{
    
    //根据:截取字符串
    let numbers = number.componentsSeparatedByString(":")
    
    guard numbers.count > 0 else{
       return nil
    }
    
   let attributeNumbers = numbers.flatMap { (string) -> NSAttributedString in

        let attribute = NSAttributedString(string: string, attributes: [NSBackgroundColorAttributeName : color])
        return attribute
    }
    
    let attributeEmptyStr = NSMutableAttributedString()
    let attributedString = attributeNumbers.reduce(attributeEmptyStr, combine: { (attributeEmptyStr, attributeStr) -> NSMutableAttributedString in
        
        attributeEmptyStr.appendAttributedString(attributeStr)
        attributeEmptyStr.appendAttributedString(NSAttributedString(string: ":"))
        return attributeEmptyStr
    })
    
    //移除最后一个：
    attributedString.deleteCharactersInRange(NSMakeRange(attributedString.length - 1, 1))
    
    return attributedString
}

extension UILabel {


    
    func startCountDown(withTimeInterval time : NSTimeInterval,
                                         shouldHighlightColor color: UIColor?,
                                 progressHandler handler:((NSTimeInterval)->Void)?,
                                 completion:(()->Void)?) -> GCDTimer{
        
        //创建计时器
        let timer = GCDTimer()
        
        timer.startTimer(withInterval: time, progressHandler: {[weak self] (timeleft) in
            
            guard let strong = self else{
               return
            }
            if color != nil{

                //设置高亮的背景色
                strong.attributedText = highlightNumberBackground(withNumberString: formatTime(timeleft),color: color)
            
            }else{
               strong.text = formatTime(timeleft)
            }
            
            
            }, completion: completion)
        
        return timer
    }

}


extension UIButton {
    
    func startCountDown(withTime time : NSTimeInterval,
                       forState state : UIControlState,
            shouldHighlightColor color: UIColor?,
               progressHandler handler:((NSTimeInterval)->Void)?,
                            completion:(()->Void)?) -> GCDTimer{
        //创建计时器
        let timer = GCDTimer()
        
        timer.startTimer(withInterval: time, progressHandler: {[weak self] (timeleft) in
            
            guard let strong = self else{
                return
            }
            
            if color != nil{
                
                //设置高亮的背景色
                strong.setAttributedTitle(highlightNumberBackground(withNumberString: formatTime(timeleft),color: color), forState: state)
            }else{
               strong.setTitle(formatTime(timeleft), forState: state)
            }
            
            }, completion: completion)
        
        return timer
    }
    
}


extension UIImage{
    
    func drawRectWithRoundedCorner(radius radius: CGFloat, _ sizetoFit: CGSize) -> UIImage {
        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        CGContextAddPath(UIGraphicsGetCurrentContext(),
                         UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners,
                            cornerRadii: CGSize(width: radius, height: radius)).CGPath)
        CGContextClip(UIGraphicsGetCurrentContext())
        
        self.drawInRect(rect)
        CGContextDrawPath(UIGraphicsGetCurrentContext(), .FillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return output
    }
    
    
    class func imageWithColor(color : UIColor, andSize size : CGSize) -> UIImage! {
        
        let rect = CGRectMake(0, 0, size.width, size.height)
        //        UIGraphicsBeginImageContext(rect.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        let ctx = UIGraphicsGetCurrentContext()
        color.set()
        CGContextFillRect(ctx , rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    


}









