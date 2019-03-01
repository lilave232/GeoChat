//
//  FriendsPickerTableView.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-27.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Alamofire

class FriendsPickerTableView: UITableViewController, UISearchResultsUpdating, addFriendProtocol {
    /*
    "Name":titleText.text!,
    "Username":UserDefaults.standard.object(forKey: "Username")!,
    "Longitude":Location!.coordinate.longitude,
    "Latitude":Location!.coordinate.latitude,
    "Private":privacySettingsTextField.text!,
    "Image":imagePressed
    */
    var Name = ""
    var Username = ""
    var Longitude:CLLocationDegrees? = nil
    var Latitude:CLLocationDegrees? = nil
    var Private = ""
    var imagePressed = ""
    
    func addFriend(User: String) {
        selectedFriends.append(User)
        print(selectedFriends)
    }
    
    func removeFriend(User: String) {
        let array = selectedFriends.filter { $0 != User }
        selectedFriends = array
        print(selectedFriends)
    }
    
    var searchController = UISearchController()
    var resultsController = UITableViewController()
    
    var selectedFriends:[String] = []
    var Friends:[String] = []
    var filteredFriends = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        if (Friends.count == 0) {
            GetFriends(Username: UserDefaults.standard.string(forKey: "Username"))
        }
        print(Name)
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
    
    @IBAction func createButton(_ sender: Any) {
        CreateChat()
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
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "pickFriendCell")! as! FriendsPickerCell
        cell.delegate = self
        if tableView == resultsController.tableView {
            cell.Label!.text = filteredFriends[indexPath.row]
        } else {
            cell.Label!.text = Friends[indexPath.row]
        }
        return cell
    }
    
    func GetFriends(Username: String?) {
        let parameters: Parameters=[
            "Username":Username!,
        ]
        let URL_USER_GET_FRIENDS = AppDelegate.URLConnection + "/GetFriends"
        Alamofire.request(URL_USER_GET_FRIENDS, method: .post, parameters: parameters).responseJSON
            {
                response in
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
        let URL_USER_REMOVE_FRIEND = AppDelegate.URLConnection + "/RemoveFriend"
        Alamofire.request(URL_USER_REMOVE_FRIEND, method: .post, parameters: parameters).responseJSON
            {
                response in
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
    
    func CreateChat () {
        //if (json(from: selectedFriends)!)
        if (Name == "") {
            Name = selectedFriends.joined(separator: ",") + "," + Username
            if (Name.count > 100000) {
                Name = String(Name.prefix(100000))
                if(Name.suffix(1) == ",") {
                    Name = String(Name.prefix(99999))
                }
            }
        }
        let parameters: Parameters=[
            "Name":Name,
            "Username":Username,
            "Longitude":Longitude!,
            "Latitude":Latitude!,
            "Private":Private,
            "Image":imagePressed,
            "Members":json(from: selectedFriends)!,
        ]
        let URL_USER_CREATE_CHAT = AppDelegate.URLConnection + "/CreatePrivateChat"
        Alamofire.request(URL_USER_CREATE_CHAT, method: .post, parameters: parameters).responseJSON
            {
                response in
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let desiredVC = storyboard.instantiateViewController(withIdentifier: "Chat") as! ChatView
                        desiredVC.chat_title = self.Name
                        desiredVC.chat_id = jsonData.value(forKey: "message") as! String
                        desiredVC.chat_type = self.Private
                        self.navigationController?.tabBarController!.selectedIndex = 1
                        self.navigationController?.tabBarController!.selectedViewController?.show(desiredVC, sender: nil)
                        self.navigationController?.popToRootViewController(animated: true)
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
}
