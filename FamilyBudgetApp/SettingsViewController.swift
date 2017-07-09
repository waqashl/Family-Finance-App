//
//  SettingsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 6/12/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {

    var searchedUsers = [User]()
    
    @IBOutlet weak var SearchMemberViewTitle: UILabel!
    var backView = UIView()
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var SearchMemberView: UIView!
    @IBOutlet weak var SettingsTableView: UITableView!
    
    var walletMembers = [User]()
    var memberTypes = [String:MemberType]()
    var sections = ["Wallet","Settings","Members","leaveBtn"]
    var settingsSetionCells = ["Add Member","Assign Admin","Transfer OwnerShip","Notification","Close Wallet"]
    var searchtableSection = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backView = UIView(frame: self.view.frame)
        backView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.ViewTap))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        backView.addGestureRecognizer(tap)
        backView.backgroundColor = .lightGray
        backView.alpha = 0.5
        backView.isUserInteractionEnabled = true
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        SettingsTableView.dataSource = self
        SettingsTableView.delegate = self
        searchBar.delegate = self
        
        SearchMemberView.isHidden = true
        searchBar.autocapitalizationType = .none

        
        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                
                self.walletMembers = Resource.sharedInstance().currentWallet!.members
                self.memberTypes = Resource.sharedInstance().currentWallet!.memberTypes
                
                if self.memberTypes[Resource.sharedInstance().currentUserId!] == .admin {
                    self.settingsSetionCells = ["Add Member","Notification"]
                }
                else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .member {
                    self.settingsSetionCells = ["Notification"]
                }
                else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .owner {
                    self.sections[3] = "Delete Wallet"
                }

            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func ViewTap() {
        removeView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func BackBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == SettingsTableView ? sections.count : searchtableSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == SettingsTableView {
            return indexPath.section == 1 || indexPath.section == 3 ? 60 : indexPath.section == 2 ? 170 : 85
        }
        else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == SettingsTableView {
            return section == 1 ? settingsSetionCells.count : 1
        }
        else {
            return searchtableSection[section] == "searchUsers" ? searchedUsers.count : walletMembers.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == SettingsTableView {
            return section == 2 ? "WALLET MEMBERS" : section == 2 ? " " :nil
        }
        else {
            return searchtableSection[section] == "searchUsers" ? "Search Results" : "Wallet Members"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == SettingsTableView {
            return section == 2 ? 30.0 : section == 1 ? 5.0 : 0
        }
        else {
            return 25
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == SettingsTableView {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell") as! SettingsTableViewCell
                cell.icon.text = Resource.sharedInstance().currentWallet!.icon
                cell.icon.textColor = Resource.sharedInstance().currentWallet!.color
                cell.settingName.text = Resource.sharedInstance().currentWallet!.name
                cell.icon.layer.cornerRadius = cell.icon.layer.frame.height/2
                cell.icon.layer.borderWidth = 1
                cell.icon.layer.borderColor = cell.icon.textColor.cgColor
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCells") as! SettingsTableViewCell
                cell.icon.text = "A"
                cell.settingName.text = settingsSetionCells[indexPath.row]
                if settingsSetionCells[indexPath.row] == "Notification" {
                    cell.switchBtn.isHidden = false
                    cell.switchBtn.target(forAction: #selector(self.NotificationSwitchBtn), withSender: nil)
                }
                cell.selectionStyle = .none
                return cell
            }
            else if indexPath.section == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! SettingMembersTableViewCell
                cell.membersCollectionView.dataSource = self
                cell.membersCollectionView.delegate = self
                cell.membersCollectionView.reloadData()
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveCell") as! DeleteTableViewCell
                cell.DeleteBtn.layer.cornerRadius = cell.DeleteBtn.layer.frame.height/2
                cell.DeleteBtn.layer.borderWidth = 1
                cell.DeleteBtn.layer.borderColor = UIColor.red.cgColor
                cell.selectionStyle = .none
                return cell
            }
        }
        else {
            if searchtableSection[indexPath.section] == "searchUsers" {
                
                if searchedUsers.count != 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "searchedUsers") as! UserSearchResultTableViewCell
                    cell.selectionStyle = .none
                    let this = searchedUsers[indexPath.row]
                    
                    this.getImage({ (data) in
                        cell.userImage.image = UIImage(data: data) ?? (this.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
                    })
                    cell.accessoryType = .none
                    cell.userName.text = this.userName
                    cell.userEmail.text = this.getUserEmail()
                    
                    cell.memberTypeBtn.isHidden = true
                    cell.RemoveMemberBtn.isHidden = true
                    
                    return cell
                    
                }
                
                
            }
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "searchedUsers") as! UserSearchResultTableViewCell
                cell.selectionStyle = .none
                let this = walletMembers[indexPath.row]
                
                this.getImage({ (data) in
                    cell.userImage.image = UIImage(data: data) ?? (this.gender == 0 ? #imageLiteral(resourceName: "dp-male") : #imageLiteral(resourceName: "dp-female"))
                })
                cell.memberTypeBtn.isEnabled = true
                if memberTypes[this.getUserID()] == .owner {
                    cell.accessoryType = .none
                    cell.memberTypeBtn.setTitle("Owner", for: UIControlState.normal)
                    cell.memberTypeBtn.isEnabled = false
                    cell.RemoveMemberBtn.isEnabled = false
                }
                else if memberTypes[this.getUserID()] == .admin {
//                    cell.accessoryType = .no
                    cell.memberTypeBtn.setTitle("Remove from Admin", for: UIControlState.normal)
                }
                else {
//                    cell.accessoryType = .checkmark
                    cell.memberTypeBtn.setTitle("Make Admin", for: UIControlState.normal)
                }
                
                cell.userName.text = this.userName
                cell.userEmail.text = this.getUserEmail()
                cell.memberTypeBtn.isHidden = false
                cell.RemoveMemberBtn.isHidden = false
                cell.memberTypeBtn.addTarget(self, action: #selector(self.memberTypeChanged), for: .touchUpInside)
                cell.RemoveMemberBtn.addTarget(self, action: #selector(self.removeMember), for: .touchUpInside)
                cell.RemoveMemberBtn.tag = indexPath.row
                cell.memberTypeBtn.tag = indexPath.row
                
                cell.memberTypeBtn.layer.cornerRadius = cell.memberTypeBtn.layer.frame.height/4
                cell.memberTypeBtn.layer.borderWidth = 1
                cell.memberTypeBtn.layer.borderColor = darkGreenThemeColor.cgColor
                
                cell.RemoveMemberBtn.layer.cornerRadius = cell.RemoveMemberBtn.layer.frame.height/4
                cell.RemoveMemberBtn.layer.borderWidth = 1
                cell.RemoveMemberBtn.layer.borderColor = UIColor.red.cgColor
                
                return cell
            }
            return UITableViewCell()
        }
    }
    
//    var settingsSetionCells = ["Add Member","Assign Admin","Transfer OwnerShip","Notification","Close Wallet"]

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && tableView == SettingsTableView {
            if settingsSetionCells[indexPath.row] == "Add Member" {
                searchtableSection = ["searchUsers","Members"]
                AddView(view: SearchMemberView)
                SearchMemberViewTitle.text = "Add Members"
            }
            else if settingsSetionCells[indexPath.row] == "Assign Admin" {
                searchtableSection = ["Members"]
                searchBar.isHidden = true
//                searchTableView.frame.size.height += searchBar.frame.height
                AddView(view: SearchMemberView)
                SearchMemberViewTitle.text = "Assign Admin"
            }
            else if settingsSetionCells[indexPath.row] == "Transfer OwnerShip" {
                searchBar.isHidden = true
                searchtableSection = ["Members"]
                searchTableView.frame.size.height += searchBar.frame.height
                AddView(view: SearchMemberView)
                SearchMemberViewTitle.text = "Transfer OwnerShip"
            }
            else if settingsSetionCells[indexPath.row] == "" {
                let alert = UIAlertController(title: "", message: "close wallet", preferredStyle: .alert)
//                let yes = UIAlertAction(title: "Yes", style: .destructive, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>)
//                let no = UIAlertAction(title: "No", style: .cancel, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>)
//                alert.addAction(yes)
//                alert.addAction(no)
//                self.present(alert, animated: true, completion: nil)
                
            }
        }
        else if tableView == searchTableView && searchtableSection[indexPath.section] == "searchUsers" {
            memberTypes[searchedUsers[indexPath.row].getUserID()] = .member
            walletMembers.append(searchedUsers[indexPath.row])
            searchedUsers.remove(at: indexPath.row)
            searchTableView.reloadSections([0,1], with: .top)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Resource.sharedInstance().currentWallet!.members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "members", for: indexPath) as! MembersCollectionViewCell
        let member = Resource.sharedInstance().currentWallet!.members[indexPath.item]
        cell.memberImage.image = member.image ?? #imageLiteral(resourceName: "dp-male")
        cell.memberName.text = member.userName
        cell.memberType.layer.cornerRadius = cell.memberType.layer.frame.height/2
        if Resource.sharedInstance().currentWallet!.memberTypes[member.getUserID()] == .admin {
            cell.memberType.text = "Admin"
            cell.memberType.backgroundColor = darkGreenThemeColor
        }
        else if Resource.sharedInstance().currentWallet!.memberTypes[member.getUserID()] == .owner{
            cell.memberType.text = "Owner"
            cell.memberType.backgroundColor = .black
        }
        else {
            cell.memberType.isHidden = true
        }
        return cell
        
    }
    
    func AddView(view : UIView) {
        self.view.addSubview(backView)
        view.isHidden = false
        self.view.bringSubview(toFront: view)
        let transform = CATransform3DTranslate(CATransform3DIdentity, 0, view.frame.maxY+200, 0)
        view.layer.transform = transform
        
        UIView.animate(withDuration: 0.5) {
            view.alpha = 1.0
            view.layer.transform = CATransform3DIdentity
        }
        searchTableView.reloadData()
    }
    
    func removeView() {
        self.SearchMemberView.isHidden = true
        self.backView.removeFromSuperview()
    }
    
    func NotificationSwitchBtn(_sender : Any) {
        print("Switch Btn Pressed")
    }
    
    func memberTypeChanged(sender: UIButton) {
        
        print("member type changed")
        let thisUser = walletMembers[sender.tag]
        
        if sender.currentTitle == "Make Admin" {
            
            memberTypes[thisUser.getUserID()] = .admin
            sender.setTitle("Remove from Admin", for: .normal)
        }
        else if sender.currentTitle == "Remove from Admin" {
            
            memberTypes[thisUser.getUserID()] = .member
            sender.setTitle("Make Admin", for: .normal)
        }
    }
    
    var deletememberIndex = Int()
    
    func removeMember(sender: UIButton) {
        deletememberIndex = sender.tag
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to remove this member", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .destructive, handler: YesPressed)
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: NoPressed)
        alert.addAction(action)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func YesPressed(action : UIAlertAction) {
        print("Kar de Romove")
        memberTypes.removeValue(forKey: walletMembers[deletememberIndex].getUserID())
        walletMembers.remove(at: deletememberIndex)
        searchTableView.reloadData()
    }
    
    func NoPressed(action : UIAlertAction) {
        print("Nhn Kr Delete")
    }
    
    // Search Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedUsers = []
        
        let results = Resource.sharedInstance().users.filter { (user) -> Bool in
            
            return user.value.getUserEmail().contains(searchText) && !(memberTypes.contains(where: { (_user) -> Bool in
                return _user.key == user.key
            }))
        }
        
//        var results = [User]()
//        
//        for key in Resource.sharedInstance().users.keys {
//            if Resource.sharedInstance().users[key]!.getUserEmail().contains(searchText) {
//                for i in 0..<walletMembers.count {
//                    if walletMembers[i].getUserID() == key {
//                        return
//                    }
//                    else{
//                        results.append(Resource.sharedInstance().users[key]!)
//                    }
//                }
//            }
//        }
        
        print("search results = ", results.count)
        for i in 0..<results.count {
            searchedUsers.append(results[i].value)
        }
        searchTableView.reloadSections([0], with: .left)
    }
  
    
}