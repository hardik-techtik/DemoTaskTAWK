//
//  ProfileViewModel.swift
//  TAWKIOSTask
//
//  Created by Hardik on 07/02/22.
//

import Foundation
import CoreData
import UIKit

class ProfileViewModel {
    
    
    var userName = ""
    var objProfile : UserProfileModel?
    
    
    func getUserProfileFromAPI(completionHandler: @escaping ((_ response : Bool) -> Void)) {
        let param : String = "\(userName)"
        Network.shared.request(router: .getUserProfile(body: param)) { (result: Result<UserProfileModel, ErrorType>) in
            guard let res = try? result.get() else {
                return
            }
            self.objProfile = res
            completionHandler(true)
        }
    }
    
    func loadDataWhileOffline(completionHandler: @escaping ((_ response : NSManagedObject) -> Void)) {
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "login contains[c] '\(userName)'")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Profile")
        fetchRequest.predicate = predicate
        do {
            let result = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in result {
                print("data----------\(data)")
                
                if userName == data.value(forKey: "login") as! String {
                    let profileData = data as NSManagedObject
                    completionHandler(profileData)
                    break
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error)")
        }
    }
    
    
    
    
    //MARK: update data with textview note data
    func updateProfileData(note:String,userName:String,completionHandler: @escaping ((_ response : Bool) -> Void)) {
        
        var managedContext:NSManagedObjectContext!

        managedContext = objAppDelegate.persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: "Profile", in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = entity
            let predicate = NSPredicate(format: "(login = %@)", userName)
            request.predicate = predicate
            do {
                let results =
                    try managedContext.fetch(request)
                let objectUpdate = results[0] as! NSManagedObject
                objectUpdate.setValue(note, forKey: "note")
                do {
                    try managedContext.save()
                    completionHandler(true)
                }catch let error as NSError {
                    print(error.description)
                }
            }
            catch let error as NSError {
                print(error.description)
            }

    }
    
    // MARK: -  download asynchornous image
    func downloadImageAsync(strURL:String,completionHandler: @escaping ((_ response : UIImage) -> Void))
    {
        let optionalImage = UIImage(named: "ic_user")!
        if let url = URL(string: strURL) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async { /// execute on main thread
                    completionHandler(UIImage(data: data) ?? optionalImage)
                }
            }
            task.resume()
        }else{
            completionHandler(optionalImage)
        }
    }
    
   
    
}
