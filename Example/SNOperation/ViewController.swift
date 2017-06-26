//
//  ViewController.swift
//  SNOperation
//
//  Created by ftdjsxo on 06/23/2017.
//  Copyright (c) 2017 ftdjsxo. All rights reserved.
//

import UIKit
import SNOperation

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var textArea: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textArea.text = "Making Request"
        
        SimpleNetworkOperation(url: "http://www.mocky.io/v2/594d20e1110000a723a3d280").operation(requestMethodType: .get,
                                                                                                 completion: completion,
                                                                                                 headerParams: nil, queryStringParameters: [String : String]())
    }
    
    func completion(jsonData :Any?, stausCode : Int?, error :Error?){
        DispatchQueue.main.async {

            self.resultLabel.text = self.resultLabel.text?.appending("  [CODE]: ").appending(stausCode!.description)
            let newValue = ""
            
            if let dict = jsonData as? [String : Any]{
                for entry in dict{
                    self.textArea.text = newValue.appending("Key: ").appending(entry.key).appending(" Value: ").appending((entry.value as? String)!)
                    
                }
            }else{
                self.textArea.text = "Unparsable response"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

