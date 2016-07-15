//
//  ViewController.swift
//  Example
//
//  Created by Owen on 16/7/13.
//  Copyright © 2016年 Owen. All rights reserved.
//

import UIKit
import AudioWave
class ViewController: UIViewController ,AudioWaveDataSource{
    var audioWave: AudioWave?
    @IBOutlet weak var waveContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordAction(sender: AnyObject) {
        self.audioWave?.dataSource = nil
        self.audioWave?.stop()
        self.audioWave?.removeFromSuperview()
        self.audioWave = nil
        self.audioWave = AudioWave(frame: CGRectMake(self.waveContainer.bounds.origin.x, self.waveContainer.bounds.origin.y, self.waveContainer.bounds.size.width - 2, self.waveContainer.bounds.size.height))
        self.waveContainer.addSubview(self.audioWave!)
        //        self.audioWave?.backgroundColor = UIColor.redColor()
        self.audioWave?.dataSource = self
        self.audioWave?.start()
    }
    
    private var waveArr = [Int32]()
    func audioWave(audioWave: AudioWave) -> [Int32]{
        let currentDb = randomInRange(0...100)

        let count = self.waveArr.count
        self.waveArr.append(Int32(currentDb))
        
        if count > Int(audioWave.sampleNum){
            self.waveArr.removeAtIndex(0)
        }
        
        return self.waveArr
    }
    
    
    func randomInRange(range: Range<Int>) -> Int {
        let count = UInt32(range.endIndex - range.startIndex)
        return  Int(arc4random_uniform(count)) + range.startIndex
    }


}

