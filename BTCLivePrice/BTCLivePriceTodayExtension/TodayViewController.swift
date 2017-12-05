//
//  TodayViewController.swift
//  BTCLivePriceTodayExtension
//
//  Created by KARTHIK B S on 05/12/17.
//  Copyright © 2017 KARTHIK B S. All rights reserved.
//

import UIKit
import NotificationCenter
import Foundation

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var textlabel: UILabel!
    //the json file url
    let URL_HEROES = "https://blockchain.info/ticker";
    
    var timer = Timer()
    
     func updateInfo(btcprice:String) {
        print("updateInfo \(btcprice)")
        textlabel.text = "BTC in USD \(btcprice)"
    }
    
    @objc func updateBTCLivePrice(){
        
        //creating a NSURL
        let url = NSURL(string: URL_HEROES)
        
        print("updateBTCLivePrice")
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            var BTC_USD:String?
            
            if let dictionary = json as? [String: Dictionary<String, Any>]{
                
                print("Json remote data key: \(String(describing: dictionary["USD"]))")
                
                let USD_DICT:Dictionary = dictionary["USD"]!
                
                for (key, value) in USD_DICT{
                    // access all key / value pairs in dictionary
                    print("nestedDictionary key: \(key) value:\(value)")
                    if key=="15m"{
                        BTC_USD = String(describing: value)
                        break;
                    }
                }
                
                OperationQueue.main.addOperation({
                    //calling another function after fetching the json
                    //it will show the names to label
                    if let btc = BTC_USD {
                        self.updateInfo(btcprice: btc)
                    }else{
                        print("Empty")
                    }
                })
            }
        }).resume()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateBTCLivePrice), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
