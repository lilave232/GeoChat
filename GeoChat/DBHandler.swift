//
//  DBHandler.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-03-07.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire

class DBHandler {
    
    //var Friends:[String] = []
    //var FriendsDB:[String] = []
    //var FriendsOnline:[String] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func GetFriendsFromDB() -> [String] {
        var FriendsDB:[String] = []
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friends")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                FriendsDB.append(data.value(forKey: "username") as! String)
            }
        } catch {
            print("Failed")
        }
        return FriendsDB
        //self.tableView.reloadData()
        //GetFriends(Username: UserDefaults.standard.string(forKey: "Username"))
    }
    
    func adjustFriendsDB(Online:[String],Database:[String]) -> [String] {
        for friend in Online {
            if (!Database.contains(friend)) {
                let context = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "Friends", in: context)
                let newFriend = NSManagedObject(entity: entity!, insertInto: context)
                newFriend.setValue(friend, forKey: "username")
                do {
                    try context.save()
                    print("Friend Added")
                } catch {
                    print("Failed saving")
                }
            }
        }
        for friend in Database {
            if (!Online.contains(friend)) {
                let context = appDelegate.persistentContainer.viewContext
                let friendFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Friends")
                friendFetch.fetchLimit = 1
                friendFetch.predicate = NSPredicate(format: "username = %@", friend)
                if let result = try? context.fetch(friendFetch) {
                    for object in result as! [NSManagedObject] {
                        context.delete(object)
                    }
                }
                do {
                    try context.save()
                    print("Friend Deleted")
                } catch {
                    print("Failed saving")
                }
            }
        }
        if (Online.count == 0) {
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friends")
            //request.predicate = NSPredicate(format: "age = %@", "12")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                    print("Friend Deleted")
                }
            } catch {
                print("Failed")
            }
        }
        return Online
    }
    
    func deleteAllRecords(entity:String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}
