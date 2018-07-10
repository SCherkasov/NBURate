//
//  ViewController.swift
//  NBURate
//
//  Created by Stanislav Cherkasov on 09.07.2018.
//  Copyright © 2018 Stanislav Cherkasov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var currentDateLabel: UILabel!
    
    let url = "https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json"
    
    var rates: [Rate] = []
    
    let tableCell = RateTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRateData()
    }
    
    //MARK: - Networking
    
    func getRateData() {
        request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.rates = json.arrayValue.map {
                    Rate(
                        name: $0["txt"].stringValue,
                        value: $0["rate"].floatValue
                    )
                }
                
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func refreshButton(_ sender: UIButton) {
        self.tableView.reloadData()
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RateTableViewCell
     
        cell.rateLabel.text = self.rates[indexPath.row].name
        
        return cell
    }
}
