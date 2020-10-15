/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This batch class upgrades / downgrades Accounts and their           */
/*  hierarchies.  Note that Parent Account upgrades are handled         */
/*  by Workflow Rules and Field Updates.                                */
/*                                                                      */
/*----------------------------------------------------------------------*/

global class UpgradeDowngradeHierarchy implements Database.Batchable<sObject>{

    global final string query;

    global UpgradeDowngradeHierarchy(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        // Declare local variables
        Set<Id>                                                 accountIds = new Set<Id>();
        List<Account>                                           accountList = new List<Account>();
        Map<Id, Account>                                        accountMap = new Map<Id, Account>();
        List<Account>                                           accountUpdateList = new List<Account>();
        Integer                                                 counter = 0;
        Membership_Level_Puchase_Requirements__c                lowestLevel;
        Membership_Level_Puchase_Requirements__c                mLPR;
        List<Membership_Level_Puchase_Requirements__c>          mLPRList = new List<Membership_Level_Puchase_Requirements__c>();
        Map<String, Membership_Level_Puchase_Requirements__c>   mLPRMap = new Map<String, Membership_Level_Puchase_Requirements__c>();
        Membership_Level_Puchase_Requirements__c                mLPRTemp;
        Date                                                    newExpirationDateExpired;
        Date                                                    newExpirationDateTwoYears;
        Date                                                    newExpirationDateManualOrUp;
        final Integer                                           thisYear = date.today().year();
        final Date                                              today = date.today();
        
        // Set the date variables
        if (date.today().month() == 1) {
            if (date.today().day() == 1 ) {
                newExpirationDateExpired = date.newInstance(date.today().year(), 12, 31);
                newExpirationDateTwoYears = date.newInstance(date.today().year() + 1, 12, 31);
            } else {
                newExpirationDateExpired = date.newInstance(date.today().year() + 1, 1, 31);
                newExpirationDateTwoYears = date.newInstance(date.today().year() + 2, 1, 31);
            }
        } else {
            if (date.today().day() == 1 ) {
                newExpirationDateExpired = date.newInstance(date.today().year() + 1, date.today().month() - 1, date.daysInMonth(date.today().year() + 1, date.today().month() - 1));
                newExpirationDateTwoYears = date.newInstance(date.today().year() + 2, date.today().month() - 1, date.daysInMonth(date.today().year() + 2, date.today().month() - 1));
            } else {
                newExpirationDateExpired = date.newInstance(date.today().year() + 1, date.today().month(), date.daysInMonth(date.today().year() + 1, date.today().month()));
                newExpirationDateTwoYears = date.newInstance(date.today().year() + 2, date.today().month(), date.daysInMonth(date.today().year() + 2, date.today().month()));
            }
        }

        newExpirationDateManualOrUp = date.newInstance(thisYear + 1, date.today().month(), date.daysInMonth(thisYear + 1, date.today().month()));
        
        mLPRMap = Membership_Level_Puchase_Requirements__c.getAll();
        mLPRList = mLPRMap.Values();
        for (Integer i = 0; i < mLPRList.size(); i++) {
            if (mLPRList[i].Purchase_Requirement__c == 0) {
                lowestLevel = mLPRList[i];
            }
        }
        
        for (sObject s : scope) {
            Account a = (Account)s;
            
            //System.debug('Batch processing ' + a.Id);
            
            // Get the current Membership Level Purchase Requirement record
            mLPR = mLPRMap.get(a.Account_Level__c);
            mLPRTemp = lowestLevel;
                
            // If the Account is expiring
            if (a.Account_Level_Last_Evaluated__c != null) {
                
                // If the Account is not "Always" automatically upgraded or downgraded, just extend the expiration
                if (a.Automatic_Upgrade_Downgrade__c != 'Always') {
                    if (mLPR.Purchase_Requirement__c != 0 ) {
                        a.Account_level_Expire__c = newExpirationDateExpired;
                    }
                
                // If the account is "Always" automatically upgraded or downgraded, get the new level
                } else {
                
                    for (Integer i = 0; i < mLPRList.size(); i++) {
                        if (a.Hierarchy_TTM_Sales__c >= mLPRList[i].Purchase_Requirement__c &&
                        mLPRList[i].Purchase_Requirement__c > mLPRTemp.Purchase_Requirement__c) {
                            mLPRTemp = mLPRList[i];
                        }
                    }
                    
                    // Set the new Account Level
                    a.Account_Level__c = mLPRTemp.Name;

                    // If it is staying above the bottom level
                    if (mLPR.Purchase_Requirement__c != 0 && mLPRTemp.Purchase_Requirement__c != 0) {
                        
                        // Extend the expiration date by a year and add the ID to the Set for children to be updated
                        a.Account_level_Expire__c = newExpirationDateExpired;
                        accountIds.add(a.Id);
                    
                    // If it is downgrading to the lowest level
                    } else if (mLPR.Purchase_Requirement__c != 0 && mLPRTemp.Purchase_Requirement__c == 0) {
                    
                        // Extend the expiration date by two years and add the ID to the Set for children to be updated
                        a.Account_level_Expire__c = newExpirationDateTwoYears;
                        accountIds.add(a.Id);
                    
                    // If it is staying at the lowest level
                    } else {

                        // Expire the Account and add the ID to the Set for children to be updated
                        a.Account_level_Expire__c = null;
                        accountIds.add(a.Id);
                    }
                }
                
            // If the Account Level Expire needs to be extended because of a manual change
            } else {
                // If changed to anything but the lowest level
                if (mLPR.Purchase_Requirement__c != 0) {
                    a.Account_level_Expire__c = newExpirationDateManualOrUp;
                    accountIds.add(a.Id);
                
                // If it was changed manually to the lowest level
                } else {
                    a.Account_level_Expire__c = null;
                    accountIds.add(a.Id);
                }
            }
            a.Account_Level_Last_Evaluated__c = today;
            accountMap.put(a.Id, a.clone(true, true));
        }
        
        // Get the children of the Accounts that need to be changed
        accountList = [SELECT Id, Account_Level__c, Account_level_Expire__c, Account_Level_Last_Evaluated__c, Automatic_Upgrade_Downgrade__c, ParentId FROM Account WHERE ParentId IN :accountIds];
        
        // Loop through the child Accounts setting the Level, Expiration Date and Last Evaluated accordingly
        for (Integer j = 0; j < accountList.size(); j++) {
            
            System.debug('Processing support account ' + accountList[j].Id);
            
            if (accountMap.containsKey(accountList[j].ParentId)) {
                
                
                
                // Set the Level
               /////////////////////////////////////////////////////////////////Start////////////////////////////////////////////////
               //Modification Date:      17 Sept, 2011
               //Modification Reason:    System throwiing NullPointerException during "elseif" statement
               //Modification:           Overwrite "elseif" statement with more filters to remove null pointer exception
                        
               // Original Code
               /* if (accountMap.get(accountList[j].ParentId).Account_Level__c != null) {
                    if (accountList[j].Account_Level__c == null && accountList[j].Automatic_Upgrade_Downgrade__c == 'Always') {
                        accountList[j].Account_Level__c = accountMap.get(accountList[j].ParentId).Account_Level__c;
                    } else if ((accountMap.get(accountList[j].ParentId) != null 
                        && mLPRMap.get(accountList[j].Account_Level__c) != null 
                        && mLPRMap.get(accountMap.get(accountList[j].ParentId).Account_Level__c) != null 
                        && mLPRMap.get(accountMap.get(accountList[j].ParentId).Account_Level__c).Purchase_Requirement__c > mLPRMap.get(accountList[j].Account_Level__c).Purchase_Requirement__c &&
                    accountList[j].Automatic_Upgrade_Downgrade__c != 'Never') || (mLPRMap.get(accountMap.get(accountList[j].ParentId).Account_Level__c).Purchase_Requirement__c < mLPRMap.get(accountList[j].Account_Level__c).Purchase_Requirement__c &&
                    accountList[j].Automatic_Upgrade_Downgrade__c == 'Always')) {
                        accountList[j].Account_Level__c = accountMap.get(accountList[j].ParentId).Account_Level__c;             
                    }
                }
                */


			  //New Code
              if (accountMap.get(accountList[j].ParentId).Account_Level__c != null) {
               
                    if (accountList[j].Account_Level__c == null && accountList[j].Automatic_Upgrade_Downgrade__c == 'Always') {
                    
                        accountList[j].Account_Level__c = accountMap.get(accountList[j].ParentId).Account_Level__c;
                        
                    } 
                    Else if(accountList[j].Account_Level__c !=null  
                            && mLPRMap.containsKey (accountList[j].Account_Level__c) 
                            && mLPRMap.get(accountMap.get(accountList[j].ParentId).Account_Level__c) != null 
                            && mLPRMap.containsKey (accountMap.get(accountList[j].ParentId) .Account_Level__c)){

                                    If ((mLPRMap.get(accountMap.get(accountList[j].ParentId).Account_Level__c).Purchase_Requirement__c > mLPRMap.get(accountList[j].Account_Level__c).Purchase_Requirement__c 
                                                && accountList[j].Automatic_Upgrade_Downgrade__c != 'Never') 
                                                ||
                                                (mLPRMap.get(accountMap.get(accountList[j].ParentId).Account_Level__c).Purchase_Requirement__c < mLPRMap.get(accountList[j].Account_Level__c).Purchase_Requirement__c 
                                                && accountList[j].Automatic_Upgrade_Downgrade__c == 'Always'))  {
                                                            
                                                            accountList[j].Account_Level__c = accountMap.get(accountList[j].ParentId).Account_Level__c;             
                                                        
                                                        }


                        }

                }
                
                
                ////////////////////////////////////////////////////////////////////End//////////////////////////////////////////////////////
                
                
                
               // Set the Level
               /////////////////////////////////////////////////////////////////Start////////////////////////////////////////////////
               //Modification Date:      19 Sept, 2011
               //Modification Reason:    System throwiing NullPointerException  
               //Modification:           Overwrite with more filters to remove null pointer exception
                 
                // Set the Expiration Date
                // Original Code
               /* if (mLPRMap.get(accountList[j].Account_Level__c).Purchase_Requirement__c == 0) {
                    accountList[j].Account_level_Expire__c = null;
                } else {
                    accountList[j].Account_level_Expire__c = accountMap.get(accountList[j].ParentId).Account_level_Expire__c;
                }*/
                
				//New Code
                if (accountList[j].Account_Level__c!=null && mLPRMap!=null 
                		&& mLPRMap.containsKey(accountList[j].Account_Level__c) 
                		&& mLPRMap.get(accountList[j].Account_Level__c).Purchase_Requirement__c != 0) {
                			
                	accountList[j].Account_level_Expire__c = accountMap.get(accountList[j].ParentId).Account_level_Expire__c;
                	
                } else {
                	
                    accountList[j].Account_level_Expire__c = null;
                                        
                }

               ////////////////////////////////////////////////////////////////////End//////////////////////////////////////////////////////
                               
                
                // Set the Last Evaluated Date
                accountList[j].Account_Level_Last_Evaluated__c = today;
                
                // Add the child to the list of Accounts to be updated
                accountMap.put(accountList[j].Id, accountList[j].clone(true, true));
            }
        }
        
        // Get all of the Accounts in the Map
        accountList = accountMap.values();
        
        // Loop through the List, updating the Accounts in batches of 200
        for (Integer k = 0; k < accountList.size(); k++) {
            accountUpdateList.add(accountList[k]);
            counter++;
            if (counter == 200 || k == accountList.size() - 1) {
                update accountUpdateList;
                accountUpdateList.clear();
                counter = 0;
            }
        }
        
    }

    global void finish(Database.BatchableContext BC) {
    }
}