//
//  ViewController.swift
//  TableviewTask
//
//  Created by MACBOOK PRP on 09/08/18.
//  Copyright © 2018 Bharath. All rights reserved.
//

import UIKit
import SDWebImage

class DataCell:UITableViewCell
{
    @IBOutlet weak var DiagnoView: UIView!
    @IBOutlet weak var DiagnoImg: UIImageView!
    @IBOutlet weak var DiagnoName: UILabel!
    @IBOutlet weak var DoctorName: UILabel!
    @IBOutlet weak var TotalViews: UILabel!
    @IBOutlet weak var DateLab: UILabel!
}


class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate
{
    @IBOutlet weak var DiagnosisSearchBar: UISearchBar!
    @IBOutlet weak var DiagnosisTabl: UITableView!
    var DataDict = [String: String]()
    var Cell:DataCell!
    
    var arrData = [Any]()
    var searchResults = [Any]()
    var arrDataViews = [Any]()
    var SearchDataViews = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //hello hi
        
       //Fetch data from local json file
        if let path = Bundle.main.path(forResource: "JsonFile", ofType: "txt") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["past_cases"] as? [Any] {
                    arrData = person
                    for i in 0..<arrData.count
                    {
                        let jsonResult = arrData[i] as? Dictionary<String, AnyObject>
                        let Views: Int = (jsonResult!["total_views"] as? Int)!
                        arrDataViews.append(Views)
                    }
                }
            } catch {
                // handle error
            }
        }
        

        //Set up for the automatic tableview height
        DiagnosisTabl.rowHeight = UITableViewAutomaticDimension
        DiagnosisTabl.estimatedRowHeight = 130
        DiagnosisTabl.tableFooterView = UIView()
        DiagnosisTabl.tag = 1
        
        self.addDoneButtonOnKeyboard()
    }
    
    // Done button for search bar
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.DiagnosisSearchBar.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction()
    {
        DiagnosisSearchBar?.resignFirstResponder()
        SearchDataResults()
    }
    
    // MARK:  Searchbar Delegate Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        SearchDataResults()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool
    {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        DiagnosisSearchBar?.resignFirstResponder()
        SearchDataResults()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        SearchDataResults()
    }
    
    //Search Results
    func SearchDataResults()
    {
        if searchResults.count != 0
        {
            self.searchResults.removeAll()
            self.SearchDataViews.removeAll()
            DiagnosisTabl.tag = 1
        }
        for i in 0..<arrData.count
        {
            let jsonResult = arrData[i] as? Dictionary<String, AnyObject>
            let string: String = jsonResult!["name"] as? String ?? ""
            let stringname: String = jsonResult!["admin"] as? String ?? ""
            
            let rangeValue: NSRange = (string as NSString).range(of: DiagnosisSearchBar.text!, options: .caseInsensitive)
            let rangeValue2: NSRange = (stringname as NSString).range(of: DiagnosisSearchBar.text!, options: .caseInsensitive)
            if rangeValue.length > 0 || rangeValue2.length > 0
            {
                DiagnosisTabl.tag = 2
                searchResults.append(arrData[i])
                
                let Views: Int = arrDataViews[i] as! Int
                SearchDataViews.append(Views)
            }
            else
            {
                
            }
        }
        DiagnosisTabl.reloadData()
    }
    
    
    // MARK:  TableView Delegate Methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView.tag == 1
        {
            return arrData.count
        }
        else
        {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let identifier = "DataCell"
        Cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DataCell
        if Cell == nil
        {
            tableView.register(UINib(nibName: "DataCell", bundle: nil), forCellReuseIdentifier: identifier)
            Cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DataCell
        }
        Cell?.selectionStyle = UITableViewCellSelectionStyle.none
        DiagnosisTabl.separatorStyle = .none
        DiagnosisTabl.separatorColor = UIColor.clear
        
        Cell.DiagnoView.layer.cornerRadius = 4.0
        Cell.DiagnoImg.layer.cornerRadius = Cell.DiagnoImg.frame.size.width/2
        
        if tableView.tag == 1
        {
            if let jsonResult = arrData[indexPath.row] as? Dictionary<String, AnyObject>
            {
                if let StrImage = jsonResult["image"] as? String
                {
                    Cell.DiagnoImg.sd_setImage(with: URL(string: StrImage), placeholderImage: UIImage(named: "Placeholder"))
                }
                else
                {
                    Cell.DiagnoImg.image = UIImage(named: "Placeholder")
                }
                
                Cell.DiagnoName.text = jsonResult["name"] as? String ?? ""
                Cell.DoctorName.text = jsonResult["admin"] as? String ?? ""
                
                if let quantity = arrDataViews[indexPath.row] as? NSNumber
                {
                    Cell.TotalViews.text = String(describing: quantity)
                }
                else if let quantity = arrDataViews[indexPath.row] as? String
                {
                    Cell.TotalViews.text = quantity
                }
                
                let DateString:String = jsonResult["liveatdate"] as? String ?? ""
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyy"
                let yourDate = formatter.date(from: DateString)
              
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "dd MMM yy"
                Cell.DateLab.text = formatter2.string(from: yourDate!)
            }
        }
        else
        {
            if let jsonResult = searchResults[indexPath.row] as? Dictionary<String, AnyObject>
            {
                if let StrImage = jsonResult["image"] as? String
                {
                    Cell.DiagnoImg.sd_setImage(with: URL(string: StrImage), placeholderImage: UIImage(named: "Placeholder"))
                }
                else
                {
                    Cell.DiagnoImg.image = UIImage(named: "Placeholder")
                }
                
                Cell.DiagnoName.text = jsonResult["name"] as? String ?? ""
                Cell.DoctorName.text = jsonResult["admin"] as? String ?? ""
                
                if let quantity = SearchDataViews[indexPath.row] as? NSNumber
                {
                    Cell.TotalViews.text = String(describing: quantity)
                }
                else if let quantity = SearchDataViews[indexPath.row] as? String
                {
                    Cell.TotalViews.text = quantity
                }
                
                let DateString:String = jsonResult["liveatdate"] as? String ?? ""
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyy"
                let yourDate = formatter.date(from: DateString)
               
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "dd MMM yy"
                Cell.DateLab.text = formatter2.string(from: yourDate!)
            }
        }
        return Cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.tag == 1
        {
            var Val:Int = (arrDataViews[indexPath.row] as? Int)!
            Val = Val+1
            arrDataViews.remove(at: indexPath.row)
            arrDataViews.insert(Val, at: indexPath.row)
            DiagnosisTabl.reloadData()
        }
        else
        {
            var Val:Int = (SearchDataViews[indexPath.row] as? Int)!
            Val = Val+1
            SearchDataViews.remove(at: indexPath.row)
            SearchDataViews.insert(Val, at: indexPath.row)
            
            if let jsonResult = searchResults[indexPath.row] as? Dictionary<String, AnyObject>
            {
                let stringid: String = jsonResult["group_id"] as? String ?? ""
                for i in 0..<arrData.count
                {
                    if let jsonResult2 = arrData[i] as? Dictionary<String, AnyObject>
                    {
                        let stringid2: String = jsonResult2["group_id"] as? String ?? ""
                        
                        if stringid == stringid2
                        {
                            arrDataViews.remove(at: i)
                            arrDataViews.insert(Val, at: i)
                        }
                    }
                }
            }
            
            DiagnosisTabl.reloadData()
            
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

