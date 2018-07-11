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
    
    func controlsRefresh() {
        self.tableView.reloadData()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        self.currentDateLabel.text = self.rates
            .sorted { (rate1, rate2) in
                (formatter.date(from: rate1.date) ?? Date.init())
                    > (formatter.date(from: rate2.date) ?? Date())
            }.first?.date
    }
    
    //MARK: - Networking
    
    func getRateData() {
        request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                let jsonRates = JSON(value)
                
                for jsonRate in jsonRates.arrayValue {
                    let rate = Rate(
                        name: jsonRate["txt"].stringValue,
                        value: jsonRate["rate"].floatValue,
                        date: jsonRate["exchangedate"].stringValue
                    )
                    
                    self.rates.append(rate)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self.controlsRefresh()
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
        
        let rate = self.rates[indexPath.row]
     
        cell.nameLabel.text = rate.name
        cell.rateLabel.text = "\(rate.value)"
        
        return cell
    }
}
