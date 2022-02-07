//
//  UserListNoteTableCell.swift
//  TAWKIOSTask
//
//  Created by Hardik on 07/02/22.
//

import Foundation
import UIKit
import CoreData

class UserListNoteTableCell: UITableViewCell {

    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblDetails : UILabel!
    @IBOutlet var backView : UIView!
    
    @IBOutlet weak var noteImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 10
        imgUser.layer.cornerRadius = imgUser.frame.size.height / 2
        imgUser.layer.masksToBounds = true
        noteImageView.isHidden = true
    }
    
    func configureCell(objUser:UserListModel,index:Int,name:String) {
        self.lblName.text = objUser.login
        self.lblDetails.text = objUser.node_id
        if objUser.avatar_url == nil {
            DispatchQueue.main.async { /// execute on main thread
                self.imgUser.image = UIImage(data: objUser.imgData! as Data)
            }
        }else {
            downloadImageAsync(strURL: objUser.avatar_url ?? "")
        }
        
        checkAndShow(name: name)
        
    }
    func checkAndShow(name:String){
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "login contains[c] '\(name)'")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Profile")
        fetchRequest.predicate = predicate
        do {
            let result = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in result {
                print("data----------\(data)")
                if name == data.value(forKey: "login") as! String {
                    self.noteImageView.isHidden = false

                }
                else{
                    self.noteImageView.isHidden = true
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error)")
            self.noteImageView.isHidden = true
        }
    }
    
    
    
    func downloadImageAsync(strURL:String) {
        if let url = URL(string: strURL) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async { /// execute on main thread
                    self.imgUser.image = UIImage(data: data)
                }
            }
            task.resume()
        }else {
            self.imgUser.image = UIImage(named: "ic_user")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
