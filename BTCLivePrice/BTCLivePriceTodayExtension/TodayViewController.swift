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
    
    /* Structure related to decoding the json and filling the LiveUpdate object, JSON format sample to be decoded
        {
            "USD" : {"15m" : 12693.91, "last" : 12693.91, "buy" : 12696.64, "sell" : 12691.18, "symbol" : "$"},
            "AUD" : {"15m" : 16727.61, "last" : 16727.61, "buy" : 16731.21, "sell" : 16724.02, "symbol" : "$"},
            "BRL" : {"15m" : 41136.54, "last" : 41136.54, "buy" : 41145.38, "sell" : 41127.69, "symbol" : "R$"},
        }
     */
    struct LiveUpdates :Decodable{
        struct Currency {
            let currencyname: String
            let fifteenmin: Float
            let last: Float
            let buy: Float
            let sell: Float
            let symbol: String
        }
        
        struct CurrencyKey: CodingKey {
            var stringValue: String
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            
            var intValue: Int? { return nil }
            init?(intValue: Int) { return nil }
            
            var floatValue: Float? { return nil }
            init?(floatValue: Float) { return nil }
            
            static let fifteenmin = CurrencyKey(stringValue: "15m")!
            static let last = CurrencyKey(stringValue: "last")!
            static let buy = CurrencyKey(stringValue: "buy")!
            static let sell = CurrencyKey(stringValue: "sell")!
            static let symbol = CurrencyKey(stringValue: "symbol")!
            
        }
        
        var currencies: [Currency]
        
        init(currencies: [Currency] = []) {
            self.currencies = currencies
        }
        
        public init(from decoder: Decoder) throws {
            var currencies = [Currency]()
            let container = try decoder.container(keyedBy: CurrencyKey.self)
            for key in container.allKeys {
                // Note how the `key` in the loop above is used immediately to access a nested container.
                let currencyContainer = try container.nestedContainer(keyedBy: CurrencyKey.self, forKey: key)
                
                let fifteenmin = try currencyContainer.decodeIfPresent(Float.self, forKey: .fifteenmin)
                let last = try currencyContainer.decodeIfPresent(Float.self, forKey: .last)
                let buy = try currencyContainer.decodeIfPresent(Float.self, forKey: .buy)
                let sell = try currencyContainer.decodeIfPresent(Float.self, forKey: .sell)
                let symbol = try currencyContainer.decodeIfPresent(String.self, forKey: .symbol)
                
                
                // The key is used again here and completes the collapse of the nesting that existed in the JSON representation.
                let currency = Currency(currencyname:key.stringValue, fifteenmin: fifteenmin!, last: last!, buy: buy!, sell: sell!, symbol:symbol!)
                currencies.append(currency)
            }
            
            self.init(currencies: currencies)
        }
        
    }
    
    
    
    /////
    @objc func updateBTCLivePrice(){
        
        //creating a NSURL
        let url = NSURL(string: URL_HEROES)
        
        print("updateBTCLivePrice")
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            let decoder = JSONDecoder()
            let JsonData = data
            var BTC_USD:String?
            
            let decodedStore = try! decoder.decode(LiveUpdates.self, from: JsonData!)
            
            for currency in decodedStore.currencies {
                print("currency:\(currency.currencyname), \t15m: \(currency.fifteenmin), buy: \(currency.buy) ,sell:\(currency.sell) ")
                if currency.currencyname=="USD"{
                    if !currency.fifteenmin.isZero{
                        BTC_USD = String(currency.fifteenmin)
                        break
                    }
                }
            }
            
            
//            let json = try? JSONSerialization.jsonObject(with: data!, options: [])

//
//            if let dictionary = json as? [String: Dictionary<String, Any>]{
//
//                print("Json remote data key: \(String(describing: dictionary["USD"]))")
//
//                let USD_DICT:Dictionary = dictionary["USD"]!
//
//                for (key, value) in USD_DICT{
//                    // access all key / value pairs in dictionary
//                    print("nestedDictionary key: \(key) value:\(value)")
//                    if key=="15m"{
//                        BTC_USD = String(describing: value)
//                        break;
//                    }
//                }
//
                OperationQueue.main.addOperation({
                    //calling another function after fetching the json
                    //it will show the names to label
                    if let btc = BTC_USD {
                        self.updateInfo(btcprice: btc)
                    }else{
                        print("Empty")
                    }
                })
//            }
            
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
