/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Trigger rolls up Training Month totals within an Account       */
/*  hierarchy.                                                          */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger RollupAccountHierarchyTotals on Account (after update) {
    
/*    // Declare local variables
    Account                         account = new Account();
    Set<Id>                         accountIds = new Set<Id>();
    List<Account>                   accounts = new List<Account>();
    Map<Id, Account>                accountMap = new Map<Id, Account>();
    List<String>                    apexErrorRecipientIds = new List<String>();
    List<Apex_Error_Recipients__c>  apexErrorRecipients = new List<Apex_Error_Recipients__c>();
    Boolean                         executeTrigger = false;
    Set<Id>                         failedIds = new Set<Id>();
    Messaging.SingleEmailMessage    mail = new Messaging.SingleEmailMessage();
    List<Account>                   supportAccounts = new List<Account>();
    Boolean                         updateIsSuccess = true;

    // Loop through the array determining whether the Trigger needs to run, populating accounts and arrays accordingly.
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (Trigger.old[i].ParentId != Trigger.new[i].ParentId || Trigger.old[i].Hierarchy_TTM_Sales__c != Trigger.new[i].Hierarchy_TTM_Sales__c) {
            
            // Recalculate the old Parent if one existed
            if (Trigger.old[i].ParentId != null) {
                accountIds.add(Trigger.old[i].ParentId);
            }
            
            // Recalculate the new Parent if one exists.  If it is the same as the Old value, this is fine because adding the value to the Set
            // a second time will simply cause it to "replace itself"
            if (Trigger.new[i].ParentId != null) {
                accountIds.add(Trigger.new[i].ParentId);
            }
        }
    }
    
    // Indicate whether the Trigger should run
    if (accountIds.size() > 0) {
        executeTrigger = true;
    }
    
    // Only execute the Trigger if needed
    if (executeTrigger) {
        
        // Write the scope to the Debug Log
        System.debug('Recalculating hierarchy totals for: ' + accountIds);
        
        // Get the Accounts that need to be recalculated
        accountMap = new Map<Id, Account>([SELECT Id, Hierarchy_TTM_Sales__c FROM Account WHERE Id IN :accountIds]);
        
        // Write the Map to the Debug Log
        System.debug('Accounts prior to recalculation: ' + accountMap);
        
        // Loop through the Accounts, adding their Hierarchy TTM Sales to the parents where needed
        for (Integer k = 0; k < Trigger.new.size(); k++) {

            // If the Parent has changed, subtract the old amount from the old Parent (if applicable) and add the new Amount to the new
            // Parent (if applicable)
            if (Trigger.old[k].ParentId != Trigger.new[k].ParentId) {
            
                // Delete the old amount from the old Parent if applicable
                if (Trigger.old[k].ParentId != null && accountMap.containsKey(Trigger.old[k].ParentId) &&
                Trigger.old[k].Hierarchy_TTM_Sales__c != null) {
                    account = accountMap.get(Trigger.old[k].ParentId);
                    if (account.Hierarchy_TTM_Sales__c != null) {
                        account.Hierarchy_TTM_Sales__c -= Trigger.old[k].Hierarchy_TTM_Sales__c;
                    } else {
                        account.Hierarchy_TTM_Sales__c = -Trigger.old[k].Hierarchy_TTM_Sales__c;
                    }
                    accountMap.put(account.Id, account.clone(true,true));
                }
                
                // Add the new amount to the new Parent if applicable
                if (Trigger.new[k].ParentId != null && accountMap.containsKey(Trigger.new[k].ParentId) &&
                Trigger.new[k].Hierarchy_TTM_Sales__c != null) {
                    account = accountMap.get(Trigger.new[k].ParentId);
                    if (account.Hierarchy_TTM_Sales__c != null) {
                        account.Hierarchy_TTM_Sales__c += Trigger.new[k].Hierarchy_TTM_Sales__c;
                    } else {
                        account.Hierarchy_TTM_Sales__c = Trigger.new[k].Hierarchy_TTM_Sales__c;
                    }
                    accountMap.put(account.Id, account.clone(true,true));
                }
            
            // if the Parent has not changed but the Hierarchy TTM has, adjust the Parent's total
            } else if (Trigger.old[k].Hierarchy_TTM_Sales__c != Trigger.new[k].Hierarchy_TTM_Sales__c) {
            
                if (Trigger.new[k].ParentId != null && accountMap.containsKey(Trigger.new[k].ParentId)) {
                    account = accountMap.get(Trigger.new[k].ParentId);
                    if (account.Hierarchy_TTM_Sales__c != null) {
                        if (Trigger.new[k].Hierarchy_TTM_Sales__c != null) {
                            if (Trigger.old[k].Hierarchy_TTM_Sales__c != null) {
                                account.Hierarchy_TTM_Sales__c += (Trigger.new[k].Hierarchy_TTM_Sales__c - Trigger.old[k].Hierarchy_TTM_Sales__c);
                            } else {
                                account.Hierarchy_TTM_Sales__c += Trigger.new[k].Hierarchy_TTM_Sales__c;
                            }
                        } else {
                            if (Trigger.old[k].Hierarchy_TTM_Sales__c != null) {
                                account.Hierarchy_TTM_Sales__c -= Trigger.old[k].Hierarchy_TTM_Sales__c;
                            }
                        }
                    } else {
                        if (Trigger.new[k].Hierarchy_TTM_Sales__c != null) {
                            if (Trigger.old[k].Hierarchy_TTM_Sales__c != null) {
                                account.Hierarchy_TTM_Sales__c = (Trigger.new[k].Hierarchy_TTM_Sales__c - Trigger.old[k].Hierarchy_TTM_Sales__c);
                            } else {
                                account.Hierarchy_TTM_Sales__c = Trigger.new[k].Hierarchy_TTM_Sales__c;
                            }
                        } else {
                            if (Trigger.old[k].Hierarchy_TTM_Sales__c != null) {
                                account.Hierarchy_TTM_Sales__c = -Trigger.old[k].Hierarchy_TTM_Sales__c;
                            }
                        }
                    }
                    accountMap.put(account.Id, account.clone(true,true));
                }
            }
        }
        
        // Update the Account totals
        System.debug('Updating Hierarchy Totals: ' + accountMap.values());
        Database.SaveResult[] saveResultList = database.update(accountMap.values(), false);
        for (Integer l = 0; l < saveResultList.size(); l++) {
            if (!saveResultList[l].IsSuccess()) {
                updateIsSuccess = false;
                failedIds.add(accountMap.values()[l].Id);
                Database.Error err = saveResultList[l].getErrors()[0];
                System.debug(err.getMessage());
            }
        }
        
        if (!updateIsSuccess) {

            // Get the error recipients
            apexErrorRecipients = Apex_Error_Recipients__c.getAll().values();
            for (Integer m = 0; m < apexErrorRecipients.size(); m++) {
                apexErrorRecipientIds.add(apexErrorRecipients[m].Name);
            }
        
            // Populate the email
            mail.setToAddresses(apexErrorRecipientIds);
            mail.setSenderDisplayName('APEX ERRORS');
            mail.setSubject('APEX ERRORS ON OPPORTUNITY TRIGGER RollupOpportunityTotals');
            mail.setPlainTextBody('The following Accounts were not successfully updated: ' + failedIds);
            mail.setHtmlBody('The following Accounts were not successfully updated: ' + failedIds);
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    
    }*/
}