//
//  FriendsTableView.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-12.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreData

class FriendsTableView: UITableViewController, UISearchResultsUpdating {
    
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var Friends:[String] = []
    var FriendsDB:[String] = []
    var FriendsOnline:[String] = []
    var filteredFriends = [String]()
    let DB = DBHandler()
    
    override func viewWillAppear(_ animated: Bool) {
        FriendsDB = DB.GetFriendsFromDB()
        Friends = FriendsDB
        self.tableView.reloadData()
        GetFriends(Username: UserDefaults.standard.string(forKey: "Username"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: resultsController)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.title = "Friends"
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
        let Unfriend = UITableViewRowAction(style: .normal, title: "Unfriend") { action, index in
            if tableView == self.resultsController.tableView {
                self.RemoveFriend(Username: UserDefaults.standard.string(forKey: "Username"), Friend: self.filteredFriends[editActionsForRowAt.row])
                self.filteredFriends.remove(at: editActionsForRowAt.row)
                self.Friends.remove(at: editActionsForRowAt.row)
                self.searchController.isActive = false
            } else {
                self.RemoveFriend(Username: UserDefaults.standard.string(forKey: "Username"), Friend: self.Friends[editActionsForRowAt.row])
            }
            self.tableView.reloadData()
        }
        Unfriend.backgroundColor = .red
        
        let Message = UITableViewRowAction(style: .normal, title: "Message") { action, index in
            print("favorite button tapped")
        }
        Message.backgroundColor = .blue
        
        return [/*Message,*/ Unfriend]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func GetFriends(Username: String?) {
        let parameters: Parameters=[
            "Username":Username!,
        ]
        let URL_USER_GET_FRIENDS = AppDelegate.URLConnection + "/GetFriends"
        Alamofire.request(URL_USER_GET_FRIENDS, method: .post, parameters: parameters).responseJSON
            {
                response in
                self.Friends = []
                self.FriendsOnline = []
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "values") as! [NSDictionary]
                        array.forEach(
                            {(dictionary) in
                                let friend = dictionary.value(forKey: "Friend") as? String
                                self.FriendsOnline.append(friend!)
                        })
                    }else{
                        print("Error Or No Friends")
                    }
                    self.Friends = self.DB.adjustFriendsDB(Online: self.FriendsOnline,Database: self.FriendsDB)
                    self.tableView.reloadData()
                }
        }
    }
    
    func RemoveFriend(Username: String?, Friend: String?) {
        let parameters: Parameters=[
            "Username":Username!,
            "Friend":Friend!,
        ]
        let URL_USER_REMOVE_FRIEND = AppDelegate.URLConnection + "/RemoveFriend"
        Alamofire.request(URL_USER_REMOVE_FRIEND, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let context = self.appDelegate.persistentContainer.viewContext
                        let friendFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Friends")
                        friendFetch.fetchLimit = 1
                        friendFetch.predicate = NSPredicate(format: "username = %@", Friend!)
                        if let result = try? context.fetch(friendFetch) {
                            for object in result as! [NSManagedObject] {
                                context.delete(object)
                            }
                        }
                    }else{
                        print("Friend Could Not Be Removed")
                    }
                    self.FriendsDB = self.DB.GetFriendsFromDB()
                    self.Friends = self.FriendsDB
                    self.tableView.reloadData()
                    self.GetFriends(Username: UserDefaults.standard.string(forKey: "Username"))
                }
        }
    }
}
