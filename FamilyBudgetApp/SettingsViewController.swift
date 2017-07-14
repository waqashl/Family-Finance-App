
//
//  SettingsViewController.swift
//  FamilyBudgetApp
//
//  Created by mac on 6/12/17.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UserDelegate, WalletDelegate, WalletMemberDelegate {

    
    @IBOutlet weak var SearchMemberViewTitle: UILabel!
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var SearchMemberView: UIView!
    @IBOutlet weak var SettingsTableView: UITableView!
    
    var backView = UIView()
    var searchedUsers = [User]()
    var walletMembers = [User]()
    var memberTypes = [String:MemberType]()
    var selectedWallet : UserWallet?
    var currentUser : User?
    
    var isKeyboardOpen = false
    var isUserSearch = false
    
    var tap = UITapGestureRecognizer()
    
    var sections = ["Wallet","Wallet Settings","Members","leaveBtn"]
    var settingsSetionCells = ["Add Member","Assign Admin","Transfer OwnerShip","Notification","Close Wallet"]
    
    var searchtableSection = [String]()
    
    var userSettingsOptions = ["Change Password","Edit Name", "Edit Display Picture"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backView = UIView(frame: self.view.frame)
        backView.isUserInteractionEnabled = true
        tap = UITapGestureRecognizer(target: self, action: #selector(self.ViewTap))
        backView.addGestureRecognizer(tap)
        backView.backgroundColor = .lightGray
        backView.alpha = 0.5
        backView.isUserInteractionEnabled = true
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        SettingsTableView.dataSource = self
        SettingsTableView.delegate = self
        
        SearchMemberView.isHidden = true
        SearchMemberView.frame.origin.y += self.SearchMemberView.frame.height
        searchBar.autocapitalizationType = .none

        searchBar.delegate = self
        Delegate.sharedInstance().addUserDelegate(self)
        Delegate.sharedInstance().addWalletDelegate(self)
        Delegate.sharedInstance().addWalletMemberDelegate(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        HelperObservers.sharedInstance().getUserAndWallet { (flag) in
            if flag {
                
                if Resource.sharedInstance().currentUserId == Resource.sharedInstance().currentWalletID {
                    self.sections = ["Wallet","Wallet Settings","User","User Settings","SignOut"]
                    self.settingsSetionCells = ["Notification"]
                    
                }
                else {
                    self.sections = ["Wallet","Wallet Settings", "Members"]
                    self.walletMembers = Resource.sharedInstance().currentWallet!.members
                    self.memberTypes = Resource.sharedInstance().currentWallet!.memberTypes
                    self.currentUser = Resource.sharedInstance().currentUser!
                    self.selectedWallet = Resource.sharedInstance().userWallets[Resource.sharedInstance().currentWalletID!]
//                    self.selectedWallet! = Resource.sharedInstance().currentWallet?
//                    
                    if self.memberTypes[Resource.sharedInstance().currentUserId!] == .admin {
                        self.settingsSetionCells = ["Add Member","Notification","Change Name", "Change Icon"]
                        self.sections.append("leaveBtn")
                    }
                    else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .member {
                        self.settingsSetionCells = ["Notification"]
                        self.sections.append("leaveBtn")
                    }
                    else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .owner {
                        self.settingsSetionCells += ["Change Name", "Change Icon", "Delete Wallet"]
                    }
                    self.sections += ["User","User Settings","SignOut"]
                }
                

            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func ViewTap() {
        if isKeyboardOpen {
            isKeyboardOpen = false
            self.view.endEditing(true)
        }
        else {
            removeView()
        }
    }
    
    func updateSettingCells(){
        self.sections = ["Wallet","Wallet Settings", "Members"]
        self.walletMembers = Resource.sharedInstance().currentWallet!.members
        self.memberTypes = Resource.sharedInstance().currentWallet!.memberTypes
        
        self.selectedWallet = Resource.sharedInstance().userWallets[Resource.sharedInstance().currentWalletID!]
        //                    self.selectedWallet! = Resource.sharedInstance().currentWallet?
        //
        if self.memberTypes[Resource.sharedInstance().currentUserId!] == .admin {
            self.settingsSetionCells = ["Add Member","Notification"]
            self.sections.append("leaveBtn")
        }
        else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .member {
            self.settingsSetionCells = ["Notification"]
            self.sections.append("leaveBtn")
        }
        else if self.memberTypes[Resource.sharedInstance().currentUserId!] == .owner {
            self.settingsSetionCells += ["Delete Wallet"]
            settingsSetionCells[4] = selectedWallet!.isOpen ? "Close Wallet" : "Open Wallet"
        }
        self.sections += ["User","User Settings","SignOut"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func BackBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var SizeOfKeyboard = CGFloat()
    
    func keyboardWillShow(notification: NSNotification) {
        
        if !isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                SizeOfKeyboard = keyboardSize.height
                SearchMemberView.frame.origin.y -= SizeOfKeyboard/2
                isKeyboardOpen = true
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
    
        if isKeyboardOpen {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                SizeOfKeyboard = keyboardSize.height
                isKeyboardOpen = false
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == SettingsTableView ? sections.count : searchtableSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == SettingsTableView {
            
            switch sections[indexPath.section] {
            case "Wallet":
                return 100
            case "Members":
                return 200
            case "User":
                return 100
            default:
                return 50
            }
        }
        else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == SettingsTableView {
            return sections[section] == "Wallet Settings" ? settingsSetionCells.count : sections[section] == "User Settings" ? userSettingsOptions.count : 1
        }
        else {
            return searchtableSection[section] == "searchUsers" ? searchedUsers.count : walletMembers.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == SettingsTableView {
            
            switch sections[section] {
            case "Wallet":
                return "WALLET Settings"
            case "Members":
                return "Wallet Members"
            case "User":
                return "User Settings"
            default:
                return nil
            }
            
        }
        else {
            return searchtableSection[section] == "searchUsers" ? "Search Results" : "Wallet Members"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == SettingsTableView {
            return 30
        }
        else {
            return 25
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == searchTableView {
            if section == 0 {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
                let label = UILabel(frame: view.frame)
                label.text = searchedUsers.count == 0 ? "No users to show." : ""
                label.textAlignment = .center
                view.addSubview(label)
                
                return view
            }
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == SettingsTableView {
            
            switch sections[indexPath.section] {
            case "Wallet":
                let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell") as! SettingsTableViewCell
                cell.icon.text = Resource.sharedInstance().currentWallet!.icon
                cell.icon.textColor = Resource.sharedInstance().currentWallet!.color
                cell.settingName.text = Resource.sharedInstance().currentWallet!.name
                cell.icon.layer.cornerRadius = cell.icon.layer.frame.height/2
                cell.icon.layer.borderWidth = 1
                cell.icon.layer.borderColor = cell.icon.textColor.cgColor
                
                for view in cell.borderLine {
                    view.backgroundColor = cell.icon.textColor
                }
                
                cell.selectionStyle = .none
                return cell
                
            case "User":
                let cell = tableView.dequeueReusableCell(withIdentifier: "user") as! UserInfoTableViewCell
                
                cell.userdp.image = Resource.sharedInstance().currentUser?.image ?? #imageLiteral(resourceName: "dp-male")
                cell.userName.text = Resource.sharedInstance().currentUser?.userName
                cell.userEmail.text = Resource.sharedInstance().currentUser?.getUserEmail()
                cell.selectionStyle = .none

                return cell
                
            case "Wallet Settings":
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCells") as! SettingsTableViewCell
                cell.icon.text = "A"
                cell.settingName.text = settingsSetionCells[indexPath.row]
                if settingsSetionCells[indexPath.row] == "Notification" {
                    cell.switchBtn.isHidden = false
                    cell.switchBtn.addTarget(self, action: #selector(self.NotificationSwitchBtn(_sender:)), for: .valueChanged)
                }
                cell.selectionStyle = .none
                return cell
                
            case "User Settings":
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCells") as! SettingsTableViewCell
                cell.icon.text = "A"
                cell.switchBtn.isHidden = true
                cell.settingName.text = userSettingsOptions[indexPath.row]
                cell.selectionStyle = .none
                return cell
                
            case "Change Name":
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCells") as! SettingsTableViewCell
                cell.icon.text = "A"
                cell.switchBtn.isHidden = true
                cell.settingName.text = settingsSetionCells[indexPath.row]
                cell.selectionStyle = .none
                return cell
                
            case "Change Icon":
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCells") as! SettingsTableViewCell
                cell.icon.text = "A"
                cell.switchBtn.isHidden = true
                cell.settingName.text = settingsSetionCells[indexPath.row]
                cell.selectionStyle = .none
                return cell
                
            case "Members":
                let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! SettingMembersTableViewCell
                cell.membersCollectionView.dataSource = self
                cell.membersCollectionView.delegate = self
                cell.membersCollectionView.reloadData()
                cell.selectionStyle = .none
                return cell
            
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveCell") as! DeleteTableViewCell
                cell.selectionStyle = .none
                
                cell.DeleteBtn.setTitle(sections[indexPath.section] == "leaveBtn" ? "Leave Wallet" : "Sign Out", for: .normal)
                
                return cell
            }
            
        }
        else {
            if searchtableSection[indexPath.section] == "searchUsers" {
                
                if searchedUsers.count != 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "searchedUsers") as! UserSearchResultTableViewCell
                    cell.selectionStyle = .none
                    let this = searchedUsers[indexPath.row]
                    cell.memberType.text = memberTypes[this.getUserID()] == .owner ? "Owner" : memberTypes[this.getUserID()] == .admin ? "Admin" : "\(cell.memberType.isHidden = true)"

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
//                if SearchMemberViewTitle.text == "Add Members" {
                if memberTypes[this.getUserID()] == .owner {
                    cell.memberTypeBtn.setTitle("Owner", for: UIControlState.disabled)
                    cell.memberTypeBtn.isEnabled = false
                    cell.RemoveMemberBtn.isEnabled = false
                    cell.memberTypeBtn.isHidden = self.SearchMemberViewTitle.text == "Add Members"
                    cell.RemoveMemberBtn.isHidden = self.SearchMemberViewTitle.text! == "Assign Admin" || self.SearchMemberViewTitle.text! == "Transfer OwnerShip"
                }
                else if memberTypes[this.getUserID()] == .admin {
                    cell.memberTypeBtn.isHidden = self.SearchMemberViewTitle.text! == "Add Members"
                    cell.RemoveMemberBtn.isHidden = self.SearchMemberViewTitle.text! == "Assign Admin" || self.SearchMemberViewTitle.text! == "Transfer OwnerShip"
                    let btntext = self.SearchMemberViewTitle.text == "Asign Admin" ? "Remove from Admin" : "Make Owner"
                    cell.memberTypeBtn.setTitle(btntext, for: UIControlState.normal)
                }
                else {
                    cell.RemoveMemberBtn.isHidden = self.SearchMemberViewTitle.text! == "Assign Admin" || self.SearchMemberViewTitle.text! == "Transfer OwnerShip"
                    cell.memberTypeBtn.isHidden = self.SearchMemberViewTitle.text == "Add Members"
                    let btntext = self.SearchMemberViewTitle.text == "Asign Admin" ? "Make Admin" : "Make Owner"
                    cell.memberTypeBtn.setTitle(btntext, for: UIControlState.normal)
                }
                cell.memberType.text = memberTypes[this.getUserID()] == .owner ? "Owner" : memberTypes[this.getUserID()] == .admin ? "Admin" : "\(cell.memberType.isHidden = true)"
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
                cell.memberTypeBtn.layer.borderColor = darkThemeColor.cgColor
                
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
                isUserSearch = true
                AddView(showView: SearchMemberView)
                SearchMemberViewTitle.text = "Add Members"
            }
                
            else if settingsSetionCells[indexPath.row] == "Assign Admin" {
                searchtableSection = ["Members"]
                isUserSearch = false
                AddView(showView: SearchMemberView)
                SearchMemberViewTitle.text = "Assign Admin"
            }
                
            else if settingsSetionCells[indexPath.row] == "Transfer OwnerShip" {
                searchtableSection = ["Members"]
                isUserSearch = false
                AddView(showView: SearchMemberView)
                SearchMemberViewTitle.text = "Transfer OwnerShip"
            }
                
            else if settingsSetionCells[indexPath.row] == "Close Wallet" {
                let message = selectedWallet!.isOpen ? "Do you want to close this Wallet" : "Do you want to open this Wallet"
                let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    self.selectedWallet!.isOpen = !self.selectedWallet!.isOpen
                    WalletManager.sharedInstance().updateWallet(self.selectedWallet!)
                    self.updateSettingCells()
                    tableView.reloadData()
                })
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(yes)
                alert.addAction(no)
                self.present(alert, animated: true, completion: nil)
                
            }
                
            else if settingsSetionCells[indexPath.row] == "Delete Wallet" {
                let alert = UIAlertController(title: "", message: "Do you want to delete this wallet", preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                    WalletManager.sharedInstance().removeWallet(Resource.sharedInstance().currentWallet!)
                    Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
                    self.dismiss(animated: true, completion: nil)
                })
                let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
                alert.addAction(yes)
                alert.addAction(no)
                self.present(alert, animated: true, completion: nil)
            }
            
            else if settingsSetionCells[indexPath.row] == "Change Name" {
                let alert = UIAlertController(title: "Edit Name", message: "Please Enter New Wallet Name", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textfield) in
                    textfield.placeholder = "Wallet Name"
                })
                let Save = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                    let walletName = alert.textFields![0]
                    var error = ""
                    if walletName.text == "" {
                        error = "Wallet Name cannot be empty"
                    }
                    if error == "" {
                        let wallet = Resource.sharedInstance().currentWallet!
                        let update = UserWallet(id: wallet.id, name: walletName.text!, icon: wallet.icon, currencyID: wallet.currencyID, creatorID: wallet.creatorID, balance: wallet.balance, totInc: wallet.totalIncome, totExp: wallet.totalExpense, creationDate: wallet.creationDate.timeIntervalSince1970, isPersonal: wallet.isPersonal, memberTypes: wallet.memberTypes, isOpen: wallet.isOpen, color: wallet.color.stringRepresentation)
                        
                        WalletManager.sharedInstance().updateWallet(update)
                        
                    }
                    else {
                        let alert2 = UIAlertController(title: "", message: error, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler : { (action) in
                            self.present(alert, animated: true, completion: nil)
                        })
                        alert2.addAction(okAction)
                        self.present(alert2, animated: true, completion: nil)
                    }
                })
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(Save)
                alert.addAction(Cancel)
                self.present(alert, animated: true, completion: nil)
            }
            
            else if settingsSetionCells[indexPath.row] == "Change Icon" {
                
                // Present icon and color popover here....
                
                
            }
        }
        else if sections[indexPath.section] == "SignOut" {
            
            Authentication.sharedInstance().logOutUser(callback: { (err) in
                if err == nil {
                    self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                }
            })
            
        }
            
        else if sections[indexPath.section] == "leaveBtn" {
            
            let alert = UIAlertController(title: "", message: "Do you want to leave this wallet", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                WalletManager.sharedInstance().removeMemberFromWallet(self.selectedWallet!.id, memberID: Resource.sharedInstance().currentUserId!)
                Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
                self.dismiss(animated: true, completion: nil)
            })
            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
            
        }
        // User Settings
        else if tableView == SettingsTableView && sections[indexPath.section] == "User Settings" {
            
            if userSettingsOptions[indexPath.row] == "Change Password" {
                let alert = UIAlertController(title: "", message: "Edit Name", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textfield) in
                    textfield.placeholder = "Enter Current Password"
                })
                alert.addTextField(configurationHandler: { (textfield) in
                    textfield.placeholder = "Enter New Password"
                })
                alert.addTextField(configurationHandler: { (textfield) in
                    textfield.placeholder = "Re-Enter New Password"
                })
                let Save = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                    let currentPass = alert.textFields![0]
                    let newPass = alert.textFields![1]
                    let retypePass = alert.textFields![2]
                    var error = ""
                    if currentPass.text == "" {
                        error = "Current Password Cannot be empty"
                    }
                    else if newPass.text == "" || newPass.text!.characters.count < 6 {
                        error = "New Password Cannot be less than 6 Characters"
                    }
                    else if retypePass.text == "" || retypePass.text!.characters.count < 6 {
                        error = "Re-type Password Cannot be less than 6 Characters"
                    }
                    else if retypePass.text != newPass.text{
                        error = "New and Re-type Password must be same"
                    }
                    if error == "" {
//                        self.currentUser! = currentPass.text!
//                        UserManager.sharedInstance().updateUserState(self.currentUser!)
                    }
                    else {
                        let alert2 = UIAlertController(title: "", message: error, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler : { (action) in
                            self.present(alert, animated: true, completion: nil)
                        })
                        alert2.addAction(okAction)
                        self.present(alert2, animated: true, completion: nil)
                    }
                })
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(Save)
                alert.addAction(Cancel)
                self.present(alert, animated: true, completion: nil)
            }
                
        //  Edit Name
            else if userSettingsOptions[indexPath.row] == "Edit Name" {
                let alert = UIAlertController(title: "Edit Name", message: "Please Enter Your Name", preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textfield) in
                    textfield.placeholder = "Enter User Name"
                })
                let Save = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                    let userName = alert.textFields![0]
                    var error = ""
                    if userName.text == "" {
                         error = "User Name cannot be empty"
                    }
                    if error == "" {
                        let user = Resource.sharedInstance().currentUser!
                        let update = User(id: user.getUserID(), email: user.getUserEmail(), userName: userName.text!, imageURL: user.imageURL, gender: user.gender)
                        UserManager.sharedInstance().updateUserState(update)
                    }
                    else {
                        let alert2 = UIAlertController(title: "", message: error, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler : { (action) in
                            self.present(alert, animated: true, completion: nil)
                        })
                        alert2.addAction(okAction)
                        self.present(alert2, animated: true, completion: nil)
                    }
                })
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(Save)
                alert.addAction(Cancel)
                self.present(alert, animated: true, completion: nil)
            }
            else if userSettingsOptions[indexPath.row] == "Edit Display Picture" {
                
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
            cell.memberType.isHidden = false
            cell.memberType.text = "Admin"
            cell.memberType.backgroundColor = darkThemeColor
        }
        else if Resource.sharedInstance().currentWallet!.memberTypes[member.getUserID()] == .owner{
            cell.memberType.isHidden = false
            cell.memberType.text = "Owner"
            cell.memberType.backgroundColor = .black
        }
        else {
            cell.memberType.isHidden = true
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 70)
    }
    
    func AddView(showView : UIView) {
        self.view.addSubview(backView)
        showView.isHidden = false
        showView.alpha = 0
        self.view.bringSubview(toFront: showView)

        UIView.animate(withDuration: 0.4) { 
            showView.frame.origin.y -= showView.frame.height
            showView.alpha = 1
        }
        
        searchTableView.reloadData()
    }
    
    func removeView() {
        
        UIView.animate(withDuration: 0.4, animations: { 
            self.SearchMemberView.frame.origin.y += self.SearchMemberView.frame.height
            self.SearchMemberView.alpha = 0
            
        }) { (flag) in
            self.SearchMemberView.isHidden = true
            self.backView.removeFromSuperview()
        }
        
        
    }
    
    // Notification Switch
    func NotificationSwitchBtn(_sender : Any) {

    }
    
    func memberTypeChanged(sender: UIButton) {
        
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
    
    func TransferOwnerShip(sender: UIButton) {
        
        print("Transfer Owner Ship")
        let thisUser = walletMembers[sender.tag]
        
        if sender.currentTitle == "Make Owner" {
            
            memberTypes[thisUser.getUserID()] = .owner
            sender.setTitle("Remove from Owner", for: .normal)
        }
        else if sender.currentTitle == "Remove from Owner" {
            
            memberTypes[thisUser.getUserID()] = .member
            sender.setTitle("Make Owner", for: .normal)
        }
    }
    
    func removeMember(sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to remove this member", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (success) in
            self.memberTypes.removeValue(forKey: self.walletMembers[sender.tag].getUserID())
            self.walletMembers.remove(at: sender.tag)
            self.searchTableView.reloadData()
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Search Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchedUsers = []
        
        let results = Resource.sharedInstance().users.filter { (user) -> Bool in
            
            return user.value.getUserEmail().contains(searchText) && !(memberTypes.contains(where: { (_user) -> Bool in
                return _user.key == user.key
            }))
        }
        
        print("search results = ", results.count)
        for i in 0..<results.count {
            searchedUsers.append(results[i].value)
        }
        searchTableView.reloadSections([0], with: .left)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        SearchMemberView.frame.origin.y -= SizeOfKeyboard
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        SearchMemberView.center.y += SizeOfKeyboard/2
    }
    
// Wallet Delegate
    
    
    func walletAdded(_ wallet: UserWallet) {
        
    }
    
    func walletUpdated(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            
            self.SettingsTableView.reloadSections([sections.index(of: "Wallet")!], with: .fade)
            
        }
    }
    
    func WalletDeleted(_ wallet: UserWallet) {
        if wallet.id == Resource.sharedInstance().currentWalletID {
            Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func userAdded(_ user: User) {
        
    }
    
    func userUpdated(_ user: User) {
        if user.getUserID() == Resource.sharedInstance().currentUserId {
            self.SettingsTableView.reloadSections([sections.index(of: "User")!], with: .fade)
        }
    }
    
    func userDetailsAdded(_ user: CurrentUser) {
        
    }
    
    func userDetailsUpdated(_ user: CurrentUser) {
        if user.getUserID() == Resource.sharedInstance().currentUserId {
            self.SettingsTableView.reloadSections([sections.index(of: "User")!], with: .fade)
        }
    }
    
    func memberLeft(_ member: User, ofType: MemberType, wallet: Wallet) {
        if member.getUserID() == Resource.sharedInstance().currentUserId && wallet.id == Resource.sharedInstance().currentWalletID {
            Resource.sharedInstance().currentWalletID = Resource.sharedInstance().currentUserId
            self.dismiss(animated: true, completion: nil)
        }
        else if Resource.sharedInstance().currentWalletID == wallet.id {
            self.SettingsTableView.reloadSections([sections.index(of: "Members")!], with: .fade)
        }
    }
    
    func memberAdded(_ member: User, ofType: MemberType, wallet: Wallet) {
        if Resource.sharedInstance().currentWalletID == wallet.id {
            self.SettingsTableView.reloadSections([sections.index(of: "Members")!], with: .fade)
        }
    }
    
    func memberUpdated(_ member: User, ofType: MemberType, wallet: Wallet) {
        if Resource.sharedInstance().currentWalletID == wallet.id {
            self.SettingsTableView.reloadSections([sections.index(of: "Members")!], with: .fade)
        }
    }
    
}
