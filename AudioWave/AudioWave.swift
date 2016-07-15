//
//  AudioWave.swift
//  AudioWave
//
//  Created by Owen on 16/7/13.
//  Copyright © 2016年 Owen. All rights reserved.
//

import Foundation


public class AudioWave: UIView {
    //数据源代理
    public weak  var dataSource: AudioWaveDataSource?
    //刷新频率,单位秒
    public var intervalTime = 0.025 {
        didSet {
            self.secondsInWidth = floor(Double(self.bounds.size.width) / (self.sampleWidth / self.intervalTime))
            self.setNeedsDisplay()
        }
        
    }
    //sampel宽度
    public var sampleWidth = 3.0 {
        didSet {
            self.sampleNum = Int(ceil(Double(self.bounds.size.width) / self.sampleWidth))
            self.secondsInWidth = floor(Double(self.bounds.size.width) / (self.sampleWidth / self.intervalTime))
            self.setNeedsDisplay()
        }
    }
    //sampel个数
    public private(set) var sampleNum = 0
    
    public  var waveColor = UIColor.redColor()
    public  var xLineColor = UIColor.yellowColor()
    public  var timePointColor = UIColor.whiteColor()
    
    
    //轮训次数
    private var scheduledCount = 0
    //wave的数据源
    private var waveDataSource = [Double]()
    //刷新定时器
    private var timer : dispatch_source_t?
    //起始位置时间
    private var beginTime = 0.0
    //起始打点时间
    private var beginTimePoint = 0
    //宽度里显示的完整秒数
    private var secondsInWidth: Double = 0
    
    // MARK: - Life cycle
    deinit{
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    // Only override drawRect: if you perform custom drasampleWidthng.
    // An empty implementation adversely affects performance during animation.
    public override func drawRect(rect: CGRect) {
        //设置背景色
        self.backgroundColor!.setFill()
        UIRectFill(self.bounds);
        
        
        
        var timePoint = 0.0 + beginTime;
        let count = self.waveDataSource.count
        let countInSecnond = Int(1.0 / self.intervalTime)
        for i in 0 ..< scheduledCount{
            //draw wave
            if i < count{
                let wavePoint = self.waveDataSource[i]
                var height = 0.0
                height = ((Double(wavePoint) + 0) / 100.0) * (Double(self.bounds.size.height) - 20.0)
                let rect = CGRectMake(CGFloat(Double(i)*sampleWidth + 1.0), CGFloat(((Double(self.bounds.size.height) - 20.0)-height)/2.0 + 20.0), CGFloat(sampleWidth - 2.0), CGFloat(height));
                self.waveColor.setFill()
                UIRectFill(rect);
                
            }
            
            let time = Double(i) * self.intervalTime;
            //            time = Double(String(format: "%.1f", time))!
            //            time = time * 10.0
            //            time = round(time) / 10
            if Double(i) * sampleWidth > Double(self.bounds.width) {
                self.beginTime =   timePoint - time
                //                beginTime = beginTime * 10.0
                //                beginTime = round(beginTime) / 10
                self.beginTimePoint += 1
                break;
            }
            //            if time - timePoint {
            //            let x = Double(i) * sampleWidth - 0.5;
            //
            //            let  bezierPath =  UIBezierPath(rect:  CGRectMake(CGFloat(x), 0, 1, 6))
            //            UIColor.whiteColor().setFill()
            //            bezierPath.fill()
            
            //            if( fabs((time) - (timePoint)) < DBL_EPSILON ){
            //draw time point
            if( (i + self.beginTimePoint) % countInSecnond == 0 ){
                timePoint += 1.0
                
                //time point line
                let x = Double(i) * self.sampleWidth - 0.5;
                let  bezierPath =  UIBezierPath(rect:  CGRectMake(CGFloat(x), 0, 1, 6))
                self.timePointColor.setFill()
                bezierPath.fill()
                
                
                //time point number
                let widthMax = ((1.0 / self.intervalTime) * self.sampleWidth)
                let textAtX = Double(i) * self.sampleWidth - (widthMax / 2.0)
                
                
                let context: CGContextRef = UIGraphicsGetCurrentContext()!
                var timeSpace = 0.0
                timeSpace = Double(self.scheduledCount) * self.intervalTime - self.secondsInWidth
                if timeSpace < 0 {
                    timeSpace = 0.0
                }
                let textContent: String = self.formatRecordTime(time + timeSpace)//String(format: "%.0f", time + sss)
                var textRect = CGRectMake(CGFloat(textAtX), 8, CGFloat(widthMax), 12)
                let textStyle = NSMutableParagraphStyle()
                if self.beginTimePoint == 0  && i == 0{
                    //                    textStyle.alignment = NSTextAlignment.Left
                    //                    textRect = CGRectMake(CGFloat(textAtX) + 2, 8, CGFloat(widthMax), 12)
                    textRect = CGRectMake(CGFloat(textAtX) + 12, 8, CGFloat(widthMax), 12)
                }
                //                else {
                //                    textStyle.alignment = NSTextAlignment.Center
                //                }
                textStyle.alignment = NSTextAlignment.Center
                
                let textFontAttributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(8.0), NSForegroundColorAttributeName: self.timePointColor, NSParagraphStyleAttributeName: textStyle]
                CGContextSaveGState(context)
                CGContextClipToRect(context, textRect)
                textContent.drawInRect(textRect, withAttributes: textFontAttributes)
                CGContextRestoreGState(context)
                
            }
        }
        
        self.xLineColor.setFill()
        let  centerLine =  UIBezierPath(rect:  CGRectMake(0, round(((self.bounds.size.height - 20)/2)-0.5) + 20, self.bounds.size.width, 1))
        centerLine.fill()
    }
    
    // MARK: - Public methods
    public func start(){
        if self.timer != nil {
            dispatch_source_cancel(self.timer!)
            self.timer = nil
        }
        self.timer =  dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                             0, 0, dispatch_get_main_queue())
        
        dispatch_source_set_timer(self.timer!, dispatch_walltime(nil, 0),UInt64(Double(NSEC_PER_SEC) * self.intervalTime), 0)
        dispatch_source_set_event_handler(self.timer!, {[weak self] () -> Void in
            self?.updateValue()
            })
        dispatch_resume(self.timer!)
        
    }
    
    public func stop(){
        
        dispatch_source_cancel(self.timer!)
        self.timer = nil
        
    }
    
    
    
    // MARK: - Private methods
    private func commonInit(){
        self.backgroundColor = UIColor.darkGrayColor()
        self.sampleNum = Int(ceil(Double(self.bounds.size.width) / self.sampleWidth))
        self.secondsInWidth = floor(Double(self.bounds.size.width) / (self.sampleWidth / self.intervalTime))
        
    }
    
    private func updateValue(){
        if self.dataSource != nil {
            self.waveDataSource = self.dataSource!.audioWave(self)
        }
        self.scheduledCount += 1
        self.setNeedsDisplay()
    }
    
    
    private func formatRecordTime(time: NSTimeInterval) -> String {
        let hours = (Int(time) / 3600) % 60;
        let minutes = (Int(time) / 60) % 60;
        let seconds = Int(time) % 60;
        if(hours == 0){
            return String(format: "%02d:%02d",minutes,seconds)
        }
        return String(format: "%02d:%02d:%02d",hours,minutes,seconds)
    }
    
}


public protocol AudioWaveDataSource : NSObjectProtocol {
    func audioWave(audioWave: AudioWave) -> [Double];
    
}

