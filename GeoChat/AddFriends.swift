//
//  AddFriends.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-12.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit

import Foundation
import UIKit
import Alamofire

class AddFriends: UITableViewController, UISearchResultsUpdating {
    
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    
    var Users:[String] = []
    var Friends:[String] = []
    var filteredUsers = [String]()
    var Exclusions:[String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        GetFriends(Username: UserDefaults.standard.string(forKey: "Username"))
        GetUsers(Username: UserDefaults.standard.string(forKey: "Username"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: resultsController)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.title = "Add Friends"
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredUsers = Users.filter({ (array:String) -> Bool in
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
            return filteredUsers.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "addFriendCell")! as! AddFriendsCell
        if tableView == resultsController.tableView {
            if (Friends.contains(filteredUsers[indexPath.row])) {
                cell.grey = false
                cell.addButton.tintColor = UIColor.green
            } else {
                cell.grey = true
                cell.addButton.tintColor = UIColor.lightGray
            }
            if (!Exclusions.contains(filteredUsers[indexPath.row])) {
                cell.friendsLabel.text = filteredUsers[indexPath.row]
            } else {
                filteredUsers.remove(at: indexPath.row)
                self.resultsController.tableView.reloadData()
            }
        } else {
            cell.friendsLabel.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func GetUsers(Username: String?) {
        let parameters: Parameters=[
            "Username":Username!,
        ]
        let URL_USER_ALL_USERS = AppDelegate.URLConnection + "/GetAllUsers"
        Alamofire.request(URL_USER_ALL_USERS, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "users") as! [NSDictionary]
                        self.Users = []
                        array.forEach(
                            {(dictionary) in
                                let user = dictionary.value(forKey: "Username") as? String
                                self.Users.append(user!)
                        })
                    }else{
                        print("Friend Could Not Be Removed")
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    func GetFriends(Username: String?) {
        let parameters: Parameters=[
            "Username":Username!,
        ]
        let URL_USER_GET_FRIENDS = AppDelegate.URLConnection + "/GetFriends"
        Alamofire.request(URL_USER_GET_FRIENDS, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "values") as! [NSDictionary]
                        self.Friends = []
                        array.forEach(
                            {(dictionary) in
                                let friend = dictionary.value(forKey: "Friend") as? String
                                self.Friends.append(friend!)
                        })
                        let array2 = jsonData.value(forKey: "requested") as! [NSDictionary]
                        array2.forEach(
                            {(dictionary) in
                                let friend = dictionary.value(forKey: "Friend") as? String
                                self.Friends.append(friend!)
                        })
                        let array1 = jsonData.value(forKey: "requests") as! [NSDictionary]
                        array1.forEach(
                            {(dictionary) in
                                let friend = dictionary.value(forKey: "Friend") as? String
                                self.Exclusions.append(friend!)
                        })
                    }else{
                        print("Error Or No Friends")
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
}
