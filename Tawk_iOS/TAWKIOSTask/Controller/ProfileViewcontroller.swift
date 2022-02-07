//
//  ProfileViewcontroller.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation
import CoreData
import UIKit

class ProfileViewcontroller: UIViewController {
    
    // MARK: -  IBOutlets 
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblFollowers : UILabel!
    @IBOutlet var lblNavTitle : UILabel!
    @IBOutlet var lblFollowing : UILabel!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblCompany : UILabel!
    @IBOutlet var lblBlog : UILabel!
    @IBOutlet var txtNotes : UITextView!

    // MARK: -  Variables 
    var profileViewModelObj = ProfileViewModel()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // flush data
        lblFollowing.text = ""
        lblFollowers.text = ""
        lblBlog.text = ""
        lblCompany.text = ""
        lblName.text = ""
        txtNotes.text = ""
        
        lblNavTitle.text = profileViewModelObj.userName
        
        NotificationCenter.default.addObserver(
                                   self,
                                   selector: #selector(self.loadOfflineData),
            name: NSNotification.Name(rawValue: "InternetConnectionError"),
                                   object: nil)

        
        if Reachability.isConnectedToNetwork(){
            callProfileAPI()
        }else{
            loadOfflineData()
        }
        
    }
    
    //MARK: - User list api call -
    func callProfileAPI() {
        showLoader()
        self.profileViewModelObj.getUserProfileFromAPI { response in
            hideLoader()
            if response {
                self.setData()
            }
        }
    }

    
    // MARK: -  load offline data with predicate 
    @objc func loadOfflineData()
    {
        
        hideLoader()
        showToastMessage(message: Messages.noInternetConnection)
        
        var name = ""
        var blog = ""
        var login = ""
        var company = ""
        var img = Data()
        var note = ""
        var followers = ""
        var following = ""
        
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "login contains[c] '\(profileViewModelObj.userName)'")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Profile")
        fetchRequest.predicate = predicate
        do {
            let result = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
                        
            for data in result {
                print("data----------\(data)")
                if profileViewModelObj.userName == data.value(forKey: "login") as! String
                {
                    name = data.value(forKey: "name") as! String
                    login = data.value(forKey: "login") as! String
                    note = data.value(forKey: "note") as! String
                    blog = data.value(forKey: "blog") as! String
                    company = data.value(forKey: "company") as! String
                    following = data.value(forKey: "following") as! String
                    followers = data.value(forKey: "followers") as! String
                    img =  data.value(forKey: "avatar_url") as! Data
                    break
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error)")
        }
        
        lblName.text = name
        lblBlog.text = blog
        lblCompany.text = company
         
        if followers == ""{
            lblFollowers.text = ""
        }else{
            lblFollowers.text = "Followers: \(followers)"
        }
        
        if following == ""{
            lblFollowing.text = ""
        }else{
            lblFollowing.text = "Followings: \(following)"
        }
        
        txtNotes.text = note

        DispatchQueue.main.async { /// execute on main thread
            self.imgUser.image = UIImage(data: (img) as Data)

        }
    }
    
    

    
    // MARK: -  Store offline profile data 
    func storeOfflineData(data:Data){
        let managedContext = objAppDelegate.persistentContainer.viewContext
            let user = Profile(context: managedContext)
            user.login = profileViewModelObj.objProfile?.login ?? ""
            user.blog = profileViewModelObj.objProfile?.blog ?? ""
            user.company = profileViewModelObj.objProfile?.company ?? ""
            user.name = profileViewModelObj.objProfile?.name ?? ""
            user.followers = "\(profileViewModelObj.objProfile?.followers ?? 0)"
            user.following = "\(profileViewModelObj.objProfile?.following ?? 0)"
            user.type  = profileViewModelObj.objProfile?.type ?? ""
            if let imageData = imgUser.image?.pngData() {
                user.avatar_url = imageData
            }
            user.note = txtNotes.text
            objAppDelegate.saveContext()
    }

    
    // MARK: -  set Online data
    func setData()
    {
        lblName.text = profileViewModelObj.objProfile?.name
        lblBlog.text = profileViewModelObj.objProfile?.blog
        lblCompany.text = profileViewModelObj.objProfile?.company
        
        if profileViewModelObj.objProfile?.following != 0{
            lblFollowing.text = "Followings: \(profileViewModelObj.objProfile?.following ?? 0)"
        }else{
            lblFollowing.text = ""
        }
        
        if profileViewModelObj.objProfile?.followers != 0{
            lblFollowers.text = "Followers: \(profileViewModelObj.objProfile?.followers ?? 0)"
        }else{
            lblFollowers.text = ""
        }
        profileViewModelObj.downloadImageAsync(strURL: profileViewModelObj.objProfile?.avatar_url ?? "") { response in
            self.imgUser.image = response
        }
        
        
        let userlistViewModelObj = UserListViewModel()
        userlistViewModelObj.loadDataWhileOffline(name: profileViewModelObj.userName ) { response in
            if response == true {
                self.txtNotes.text = "ISAvaiabvle"
            }
        }
    }

    // MARK: -  button back click
    @IBAction func btnBack(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: -  button save click
    @IBAction func btnSave(_ sender:UIButton){
        profileViewModelObj.updateProfileData(note: txtNotes.text ?? "", userName: profileViewModelObj.userName) { response in
            self.loadOfflineData()
        }
    }
    
    
}
