//
//  UserProfileViewController.swift
//  Everest
//
//  Created by Kavita Gaitonde on 10/13/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController{

    var user: User?
    var userId : String?
    var currentListType : Constants.ListType = .listTypeAccount

    @IBOutlet weak var nameLabel        : UILabel!
    @IBOutlet weak var dateLabel        : UILabel!
    @IBOutlet weak var scoreLabel       : UILabel!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var userActionTableView: UITableView!
    fileprivate var userProfileManager      : UserProfileManager?
    var actions : [Action]?

    //  MARK: -- Initialization codes
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
        
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    
    func initialize() -> Void {
        userProfileManager     = UserProfileManager.init()
        actions = [Action]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MomentCell", bundle: nil)
        self.userActionTableView.register(nib, forCellReuseIdentifier: "MomentCell")
        self.userActionTableView.estimatedRowHeight = self.userActionTableView.rowHeight
        self.userActionTableView.rowHeight = UITableViewAutomaticDimension

        if userId == nil || userId == "" {
            userId = User.currentUser?.id
        }
        
        
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ActionCreated"), object: nil, queue: OperationQueue.main, using: {(Notification) -> () in
//            //TODO: go to user profile screen to show newly added actions.
//            
//            self.user = User.currentUser
//            self.loadViewForSelectedMode()
//            
//        })
        

        if userId != nil {
            FireBaseManager.shared.fetchMomentsForUser (startAtMomentId: nil, userId: userId!, completion: { (moments: [Moment]?, error: Error?) in
                if error != nil {
                    print ("Error fetch moments for user")
                } else {
                    print ("Success moments for user")
                }
            })
            
            self.userProfileManager?.fetchUserDetails(userId: self.userId!, completion: { (user: User?, error : Error?) in
                self.user = user
                self.loadViewForSelectedMode()
                
            })
        }else {
            self.user = User.currentUser
            self.loadViewForSelectedMode()
        }
        
        if userId != User.currentUser?.id {
            self.userProfileManager?.fetchUserDetails(userId: self.userId!, completion: { (user: User?, error : Error?) in
                self.user = user
                self.loadViewForSelectedMode()

            })
        }else {
            self.user = User.currentUser
            self.loadViewForSelectedMode()
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   

    
    func loadViewForSelectedMode(){
        
        self.userProfileManager?.fetchAllMomentsForTheUser(user: self.user, completion: { (completed : Bool, error: Error?) in
            print("\(completed)")
            if completed == true {
                self.userActionTableView.reloadData()
            }
        })
        
        self.userActionTableView.reloadData()

        nameLabel.text = user?.name
        dateLabel.text = "Joined on "+(user?.createdDate)!
        scoreLabel.text = "\(user?.score ?? 0)"
        if (user?.profilePhotoUrl != nil) {
            profileImageView.setImageWith(URL(string: (user?.profilePhotoUrl!)!)!)
        } else {
            profileImageView.image = nil
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "createMomentViewController") {
//            let cell = sender as! ActionCell
//            if let indexPath = self.actionsTableView.indexPath(for: cell) {
//                let vc = segue.destination as! CreateMomentViewController
//                vc.action = self.actions?[indexPath.row]
//                self.actionsTableView.deselectRow(at: indexPath, animated: true)
//            }
        }
    }
    
    
    // MARK: - Actions tableview delegate and datasource methods
    


    @IBAction func logoutClicked(_ sender: Any) {
        LoginManager.shared.logoutUser { (error) in
            //TODO: Handle error
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate, MomentCellDelegate, AddMomentCellDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MomentCell", for: indexPath) as! MomentCell
        
        if self.userProfileManager?.actionsAndMomentsDataSource != nil && (self.userProfileManager?.actionsAndMomentsDataSource?.count)! > 0 {
            
            if let dictionary = self.userProfileManager?.actionsAndMomentsDataSource?[indexPath.section] {
                let key = Array(dictionary.keys)
                if let momentsArray = dictionary[key[0]] {
                    
                    if indexPath.row == momentsArray.count {
                        let addMomentCell = tableView.dequeueReusableCell(withIdentifier: "AddMomentCell", for: indexPath) as! AddMomentCell
                        addMomentCell.addMomentCellDelegate = self
                        addMomentCell.selectedActId = key[0]
                        return addMomentCell
                    }
                    let moment = momentsArray[indexPath.row]
                    cell.momentCellDelegate = self
                    cell.moment = moment
                }
            }
        }

        return cell
    }
    
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userProfileManager?.actionsAndMomentsDataSource != nil && (self.userProfileManager?.actionsAndMomentsDataSource?.count)! > 0 {
            if let dictionary = self.userProfileManager?.actionsAndMomentsDataSource?[section] {
                let key = Array(dictionary.keys)
                if let momentsArray = dictionary[key[0]] {
                    print("Moment array count \(momentsArray.count)")
                    return momentsArray.count+1
                }
            }
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if self.userProfileManager?.actionsAndMomentsDataSource != nil && (self.userProfileManager?.actionsAndMomentsDataSource?.count)! > 0 {
            if let dictionary = self.userProfileManager?.actionsAndMomentsDataSource?[indexPath.section] {
                let key = Array(dictionary.keys)
                if let momentsArray = dictionary[key[0]] {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let momentsDetailVC = storyboard.instantiateViewController(withIdentifier: "MomentsViewController") as! MomentsViewController
                    momentsDetailVC.momentId = momentsArray[indexPath.row].id
                    self.navigationController?.pushViewController(momentsDetailVC, animated: true)
                }
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let useractions = self.user?.actions {
            return useractions.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        

        if let action = self.user?.actions?[section] {
            let id = action.id
            return MainManager.shared.availableActs[id]?.title
        }
        
        return "Add new action and start creating moments!!"
    }
    
    
    func addMomentCell(cell: AddMomentCell, addNewMomentToAction action: String) {
        
        let action = self.user?.actions?.filter( { return $0.id == action } ).first
        let storyboard = UIStoryboard.init(name: "UserProfile", bundle: nil)
        let addMomentVC = storyboard.instantiateViewController(withIdentifier: "CreateMomentViewController") as! CreateMomentViewController
        addMomentVC.action = action
        self.navigationController?.pushViewController(addMomentVC, animated: true)
    }
}
