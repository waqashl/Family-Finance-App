

import Foundation
import Firebase

class BudgetManager {
    
    fileprivate static var singleTonInstance = BudgetManager()
    
    static func sharedInstance() -> BudgetManager {
        return singleTonInstance
    }
    /**
     Add a new budget in Wallet,
     Add members to newly added budget
     Add categories to newly added budget
     
     :param: budget to add
     
     */
    func addNewBudget(_ budget: Budget) {
        
        let ref = Database.database().reference()
        let budRef = ref.child("Budgets").child(budget.walletID).childByAutoId()
        
        let startCom = Calendar.current.dateComponents([.day,.month,.year], from: budget.startDate)
        
        let budgetDate = Calendar.current.date(from: startCom)
        
        let data : NSMutableDictionary = [
            
            "allocAmount": budget.allocAmount,
            "title": budget.title,
            "period": budget.period,
            "startDate": budgetDate!.timeIntervalSince1970*1000,
            "isOpen": budget.isOpen,
            "walletID": budget.walletID
        ]
        
        if budget.comments != nil {
            data["comments"] = budget.comments
        }
        
        budRef.setValue(data)
        addMembersToBudget(budRef.key, members: budget.getMemberIDs())
        addCategoriesToBudget(budRef.key, categories: budget.getCategoryIDs())
        
        for member in budget.getMemberIDs() {
            print("Loop")
            if member != Resource.sharedInstance().currentUserId {
                guard let notifUser = Resource.sharedInstance().users[member] as? CurrentUser else {
                    continue
                }
                if let deviceID = notifUser.deviceID {
                    NotificationManager.sharedInstance().sendNotification(toDevicewith: deviceID, of: .budgetAdded, for: budget.walletID, withCallback: { (flag) in
                        print("Notification sent", flag ? "Success" : "Failed")
                        
                    })
                }
            }
        }
        
    }
    
    
    /**
     Removes budget from Wallet in Database
     
     :param: Budget to Remove
     
     */
    func removeBudgetFromWallet(_ budget: Budget) {
        let ref = Database.database().reference()
        ref.child("Budgets/\(budget.walletID)/\(budget.id)").removeValue()
        ref.child("BudgetCategories/\(budget.id)").removeValue()
        ref.child("BudgetMembers/\(budget.id)").removeValue()
    }
    
    /**
     Update budget In Wallet to Database
     
     :param: Budget to Update
     
     */
    func updateBudgetInWallet(_ budget: Budget) {
        
        let ref = Database.database().reference()
        let budRef = ref.child("Budgets/\(budget.walletID)/\(budget.id)")
        
        var data : [String:Any] = [
            
            "allocAmount": budget.allocAmount,
            "title": budget.title,
            "period": budget.period,
            "startDate": budget.startDate.timeIntervalSince1970*1000,
            "isOpen": budget.isOpen,
        ]
        
        if budget.comments != nil {
            data["comments"] = budget.comments
        }
        
        budRef.updateChildValues(data)
        
    }
    
    /**
     Update Categories in a budget to Database
     
     :param: BudgetID For reference and categoryIDs for updation
     
     */
    func addCategoriesToBudget(_ budgetID: String, categories: [String]) {
        
        let ref = Database.database().reference()
        let catRef = ref.child("BudgetCategories/\(budgetID)")
        
        var data = [String:Bool]()
        
        for category in categories {
            data[category] = true
        }
        
        catRef.setValue(data)
    }
    
    /**
     Update Members in a budget to Database
     
     :param: BudgetID For reference and memberIDs for updation
     
     */
    func addMembersToBudget(_ budgetID: String, members: [String]) {
        
        let ref = Database.database().reference()
        let memRef = ref.child("BudgetMembers/\(budgetID)")
        
        var data = [String:Bool]()
        
        for member in members {
            data[member] = true
        }
        
        memRef.setValue(data)
        
    }
    
}
