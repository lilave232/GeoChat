//
//  RequestsTableView.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-14.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class RequestsTableView: UITableViewController, UISearchResultsUpdating {
    
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    
    var Friends:[String] = []
    var filteredFriends = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        if (Friends.count == 0) {
            GetFriends(Username: UserDefaults.standard.string(forKey: "Username"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: resultsController)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.title = "Pending Requests"
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredFriends = Friends.filter({ (array:String) -> Bool in
            if array.contains(searchController.searchBar.text!) {
                return true
            } else {
                return false
            }
        })
        
        resultsController.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == resultsController.tableView {
            return filteredFriends.count
        } else {
            return Friends.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if tableView == resultsController.tableView {
            cell.textLabel!.text = filteredFriends[indexPath.row]
        } else {
            cell.textLabel!.text = Friends[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let Delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            if tableView == self.resultsController.tableView {
                self.RemoveFriend(Username: UserDefaults.standard.string(forKey: "Username"), Friend: self.filteredFriends[editActionsForRowAt.row])
                self.filteredFriends.remove(at: editActionsForRowAt.row)
                self.Friends.remove(at: editActionsForRowAt.row)
                self.searchController.isActive = false
            } else {
                self.RemoveFriend(Username: UserDefaults.standard.string(forKey: "Username"), Friend: self.Friends[editActionsForRowAt.row])
                self.Friends.remove(at: editActionsForRowAt.row)
                self.searchController.isActive = false
            }
        }
        Delete.backgroundColor = .red
        
        let Confirm = UITableViewRowAction(style: .normal, title: "Confirm") { action, index in
            if tableView == self.resultsController.tableView {
                self.confirmRequest(Username: UserDefaults.standard.string(forKey: "Username"), Friend: self.filteredFriends[editActionsForRowAt.row])
                self.filteredFriends.remove(at: editActionsForRowAt.row)
                self.Friends.remove(at: editActionsForRowAt.row)
                self.searchController.isActive = false
            } else {
                self.confirmRequest(Username: UserDefaults.standard.string(forKey: "Username"), Friend: self.Friends[editActionsForRowAt.row])
                self.Friends.remove(at: editActionsForRowAt.row)
                self.searchController.isActive = false
            }
        }
        Confirm.backgroundColor = .green
        
        return [Delete,Confirm]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func GetFriends(Username: String?) {
        let parameters: Parameters=[
            "Username":Username!,
        ]
        let URL_USER_GET_FRIENDS = AppDelegate.URLConnection + ":8081/GetFriends"
        Alamofire.request(URL_USER_GET_FRIENDS, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "requests") as! [NSDictionary]
                        self.Friends = []
                        array.forEach(
                            {(dictionary) in
                                let friend = dictionary.value(forKey: "Friend") as? String
                                self.Friends.append(friend!)
                        })
                    }else{
                        print("Error Or No Friends")
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    func confirmRequest(Username: String?, Friend:String?) {
        let parameters: Parameters=[
            "Username":Username!,
            "Friend":Friend!,
        ]
        let URL_USER_CONFIRM_REQUEST = AppDelegate.URLConnection + ":8081/ConfirmRequest"
        Alamofire.request(URL_USER_CONFIRM_REQUEST, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        print("Friend Added")
                    }else{
                        print("Error Or No Friends")
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    func RemoveFriend(Username: String?, Friend: String?) {
        let parameters: Parameters=[
            "Username":Username!,
            "Friend":Friend!,
        ]
        let URL_USER_REMOVE_FRIEND = AppDelegate.URLConnection + ":8081/RemoveFriend"
        Alamofire.request(URL_USER_REMOVE_FRIEND, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        self.GetFriends(Username: Username!)
                    }else{
                        print("Friend Could Not Be Removed")
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
}
