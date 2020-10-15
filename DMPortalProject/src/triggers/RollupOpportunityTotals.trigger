/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Trigger rolls up Closed Opportunities to the Account where     */
/*  those Opportunities fall in the Trailing Month rollup date range    */
/*  as indicated by the Rollup Stop Date field.                         */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger RollupOpportunityTotals on Opportunity (after insert, after update, after delete, after undelete) {
    
    /*// Declare local variables
    Account                                 account = new Account();
    Set<Id>                                 accountIds = new Set<Id>();
    Map<Id, Account>                        accountMap = new Map<Id, Account>();
    List<String>                            apexErrorRecipientIds = new List<String>();
    List<Apex_Error_Recipients__c>          apexErrorRecipients = new List<Apex_Error_Recipients__c>();
    Boolean                                 executeTrigger = false;
    Set<Id>                                 failedIds = new Set<Id>();
    Messaging.SingleEmailMessage            mail = new Messaging.SingleEmailMessage();
    List<Opportunity>                       opportunities = new List<Opportunity>();
    date                                    startingCloseDate;
    final Date                              today = System.today();
    Boolean                                 updateIsSuccess = true;
    
    // Set the Starting Close Date, after which the Opportunity needs to roll up
    startingCloseDate = date.newInstance(today.year()-1, today.month(), 1);
    
    // Loop through the array, populating the Account IDs and determining whether the Trigger needs to run
    for (Integer i = 0; i < (Trigger.isDelete ? Trigger.old.size() : Trigger.new.size()); i++) {        
        
        System.debug('Evaluating Insert, Rollup Stop Date > today and Account ID not null: ' + (Trigger.isInsert && Trigger.new[i].Rollup_Stop_Date__c > today && Trigger.new[i].AccountId != null));
        System.debug('Evaluating Delete, Rollup Stop Date > today: ' + (Trigger.isDelete && Trigger.old[i].Rollup_Stop_Date__c > today));
        System.debug('Evaluating Undelete, Rollup Stop Date > today: ' + (Trigger.isUndelete && Trigger.new[i].Rollup_Stop_Date__c > today));
        System.debug('Trigger Is Update: ' + Trigger.isUpdate);
        System.debug('Old Rollup Stop Date = ' + (Trigger.isUpdate || Trigger.isDelete ? String.valueOf(Trigger.old[i].Rollup_Stop_Date__c) : 'N/A'));
        System.debug('New Rollup Stop Date = ' + (!Trigger.isDelete ? String.valueOf(Trigger.new[i].Rollup_Stop_Date__c) : 'N/A'));
        System.debug('Old Amount = ' + (Trigger.isUpdate || Trigger.isDelete ? String.valueOf(Trigger.old[i].Amount) : 'N/A'));
        System.debug('New Amount = ' + (!Trigger.isDelete ? String.valueOf(Trigger.new[i].Amount) : 'N/A'));
        System.debug('Old Account ID = ' + (Trigger.isUpdate || Trigger.isDelete ? String.valueOf(Trigger.old[i].AccountId) : 'N/A'));
        System.debug('New Account ID = ' + (!Trigger.isDelete ? String.valueOf(Trigger.new[i].AccountId) : 'N/A'));
        System.debug('Evaluating all Update conditions: ' + (Trigger.isUpdate && (((Trigger.old[i].Rollup_Stop_Date__c <= today || Trigger.old[i].Rollup_Stop_Date__c == null) &&
            Trigger.new[i].Rollup_Stop_Date__c > today) || (Trigger.old[i].Rollup_Stop_Date__c > today &&
            (Trigger.new[i].Rollup_Stop_Date__c <= today || Trigger.new[i].Rollup_Stop_Date__c == null)) ||
            (Trigger.old[i].Amount != Trigger.new[i].Amount) || (Trigger.old[i].AccountId != Trigger.new[i].AccountId))));
        if ((Trigger.isInsert && Trigger.new[i].Rollup_Stop_Date__c > today && Trigger.new[i].AccountId != null) ||
        (Trigger.isDelete && Trigger.old[i].Rollup_Stop_Date__c > today) || (Trigger.isUndelete && Trigger.new[i].Rollup_Stop_Date__c > today) ||
        (Trigger.isUpdate && (((Trigger.old[i].Rollup_Stop_Date__c <= today || Trigger.old[i].Rollup_Stop_Date__c == null) &&
        Trigger.new[i].Rollup_Stop_Date__c > today) || (Trigger.old[i].Rollup_Stop_Date__c > today &&
        (Trigger.new[i].Rollup_Stop_Date__c <= today || Trigger.new[i].Rollup_Stop_Date__c == null)) ||
        (Trigger.old[i].Amount != Trigger.new[i].Amount) || (Trigger.old[i].AccountId != Trigger.new[i].AccountId)))) {
        
            executeTrigger = true;
            
            if ((Trigger.isDelete || Trigger.isUpdate) && Trigger.old[i].AccountId != null) {
                accountIds.add(Trigger.old[i].AccountId);
            }
            
            if ((Trigger.isUndelete || Trigger.isInsert || Trigger.isUpdate) && Trigger.new[i].AccountId != null) {
                accountIds.add(Trigger.new[i].AccountId);
            }
            
        }
    }

    // Only proceed if the Trigger needs to be executed
    if (executeTrigger) {

        // Get the Accounts
        accountMap = new Map<Id, Account>([SELECT Id, Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id IN :accountIds]);

        // Loop through the Trigger, adjusting the Account totals
        for (Integer j = 0; j < (Trigger.isDelete ? Trigger.old.size() : Trigger.new.size()); j++) {
        
            if (Trigger.isUpdate || Trigger.isDelete) {
                System.debug('Evaluating Trigger Old: ' + Trigger.old[j]);
            }

            if (!Trigger.isDelete) {
                System.debug('Evaluating Trigger New: ' + Trigger.new[j]);
            }

            // If the Opportunity needs to be switched from one Account to another
            if (Trigger.isUpdate && (Trigger.old[j].AccountId != Trigger.new[j].AccountId) &&
            !RollupOpportunityTotalsHelper.switchingAccountsInProcess().contains(Trigger.new[j].Id)) {
                
                // Set the helper class in process for switching accounts
                RollupOpportunityTotalsHelper.setSwitchingAccountsInProcess(Trigger.new[j].Id);
                
                if (Trigger.old[j].AccountId != null && Trigger.old[j].Rollup_Stop_Date__c > today && accountMap.containsKey(Trigger.old[j].AccountId)) {
                    account = accountMap.get(Trigger.old[j].AccountId);
            
                    if (account.TTM_Sales__c != null) {
                        account.TTM_Sales__c -= Trigger.old[j].Amount;
                    } else {
                        account.TTM_Sales__c = -Trigger.old[j].Amount;
                    }
                    if (account.Hierarchy_TTM_Sales__c != null) {
                        account.Hierarchy_TTM_Sales__c -= Trigger.old[j].Amount;
                    } else {
                        account.Hierarchy_TTM_Sales__c = -Trigger.old[j].Amount;
                    }               
                    accountMap.put(account.Id, account.clone(true,true));
                }
    
                if (Trigger.new[j].AccountId != null && Trigger.new[j].Rollup_Stop_Date__c > today && accountMap.containsKey(Trigger.new[j].AccountId)) {
                    account = accountMap.get(Trigger.new[j].AccountId);
                    
                    if (account.TTM_Sales__c != null) {
                        account.TTM_Sales__c += Trigger.new[j].Amount;
                    } else {
                        account.TTM_Sales__c = Trigger.new[j].Amount;
                    }
                    
                    if (account.Hierarchy_TTM_Sales__c != null) {
                        account.Hierarchy_TTM_Sales__c += Trigger.new[j].Amount;
                    } else {
                        account.Hierarchy_TTM_Sales__c = Trigger.new[j].Amount;
                    }               
                    
                    accountMap.put(account.Id, account.clone(true,true));
                }
                    
            // If the Opportunity needs to be removed from the totals
            } else if (((Trigger.isDelete && Trigger.old[j].Rollup_Stop_Date__c > today) || 
            (Trigger.isUpdate && (Trigger.old[j].Rollup_Stop_Date__c > today && (Trigger.new[j].Rollup_Stop_Date__c <= today ||
            Trigger.new[j].Rollup_Stop_Date__c == null)))) && Trigger.old[j].Amount != null && accountMap.containsKey(Trigger.old[j].AccountId) &&
            !RollupOpportunityTotalsHelper.removeFromTotalsInProcess().contains(Trigger.old[j].Id)) {
                
                // Set the helper class in process for switching accounts
                RollupOpportunityTotalsHelper.setRemoveFromTotalsInProcess(Trigger.old[j].Id);
                
                account = accountMap.get(Trigger.old[j].AccountId);
                if (account.TTM_Sales__c != null) {
                    account.TTM_Sales__c -= Trigger.old[j].Amount;
                } else {
                    account.TTM_Sales__c = -Trigger.old[j].Amount;
                }

                if (account.Hierarchy_TTM_Sales__c != null) {
                    account.Hierarchy_TTM_Sales__c -= Trigger.old[j].Amount;
                } else {
                    account.Hierarchy_TTM_Sales__c = -Trigger.old[j].Amount;
                }

                accountMap.put(account.Id, account.clone(true,true));

            // If the Opportunity needs to be added to the totals
            } else if (((((Trigger.isUndelete || Trigger.isInsert)) && Trigger.new[j].Rollup_Stop_Date__c > today) ||
            (Trigger.isUpdate && ((Trigger.old[j].Rollup_Stop_Date__c <= today || Trigger.old[j].Rollup_Stop_Date__c == null) &&
            Trigger.new[j].Rollup_Stop_Date__c > today))) && Trigger.new[j].Amount != null && accountMap.containsKey(Trigger.new[j].AccountId) &&
            !RollupOpportunityTotalsHelper.addToTotalsInProcess().contains(Trigger.new[j].Id)) {
                
                // Set the helper class in process for switching accounts
                RollupOpportunityTotalsHelper.setAddToTotalsInProcess(Trigger.new[j].Id);
                
                account = accountMap.get(Trigger.new[j].AccountId);
                if (account.TTM_Sales__c != null) {
                    account.TTM_Sales__c += Trigger.new[j].Amount;
                } else {
                    account.TTM_Sales__c = Trigger.new[j].Amount;
                }

                if (account.Hierarchy_TTM_Sales__c != null) {
                    account.Hierarchy_TTM_Sales__c += Trigger.new[j].Amount;
                } else {
                    account.Hierarchy_TTM_Sales__c = Trigger.new[j].Amount;
                }

                accountMap.put(account.Id, account.clone(true,true));
                    
            // If the change in amount needs to be applied to the totals.  DO NOT add the change to the totals if the Rollup Stop Date has
            // also changed, because it will be properly handled in the next loop when the Rollup Stop Date is set; running this part
            // of the IF statement would double-process the change.  Since Rollup Stop Date is not changed directly, this part of the IF
            // statement must evaluate the criteria composing the Rollup Stop Date.
            } else if (Trigger.isUpdate && (Trigger.old[j].Amount != Trigger.new[j].Amount) && Trigger.old[j].IsWon == Trigger.new[j].IsWon &&
            (((Trigger.old[j].CloseDate < startingCloseDate || Trigger.old[j].CloseDate == null) &&
            (Trigger.new[j].CloseDate < startingCloseDate || Trigger.new[j].CloseDate == null)) ||
            (Trigger.old[j].CloseDate >= startingCloseDate && Trigger.new[j].CloseDate >= startingCloseDate)) &&
            accountMap.containsKey(Trigger.new[j].AccountId) && !RollupOpportunityTotalsHelper.amountChangedInProcess().contains(Trigger.new[j].Id)) {
            
                // Set the helper class in process for switching accounts
                RollupOpportunityTotalsHelper.setAmountChangedInProcess(Trigger.new[j].Id);
                
                account = accountMap.get(Trigger.new[j].AccountId);
                if (Trigger.old[j].Amount != null) {
                    if (Trigger.new[j].Amount != null) {
                        if (account.TTM_Sales__c != null) {
                            account.TTM_Sales__c += (Trigger.new[j].Amount - Trigger.old[j].Amount);
                        } else {
                            account.TTM_Sales__c = (Trigger.new[j].Amount - Trigger.old[j].Amount);
                        }

                        if (account.Hierarchy_TTM_Sales__c != null) {
                            account.Hierarchy_TTM_Sales__c += (Trigger.new[j].Amount - Trigger.old[j].Amount);
                        } else {
                            account.Hierarchy_TTM_Sales__c = (Trigger.new[j].Amount - Trigger.old[j].Amount);
                        }
                    } else {
                        if (account.TTM_Sales__c != null) {
                            account.TTM_Sales__c -= Trigger.old[j].Amount;
                        } else {
                            account.TTM_Sales__c = -Trigger.old[j].Amount;
                        }

                        if (account.Hierarchy_TTM_Sales__c != null) {
                            account.Hierarchy_TTM_Sales__c -= Trigger.old[j].Amount;
                        } else {
                            account.Hierarchy_TTM_Sales__c = -Trigger.old[j].Amount;
                        }
                    }
                } else {
                    if (Trigger.new[j].Amount != null) {
                        if (account.TTM_Sales__c != null) {
                            account.TTM_Sales__c += Trigger.new[j].Amount;
                        } else {
                            account.TTM_Sales__c = Trigger.new[j].Amount;
                        }

                        if (account.Hierarchy_TTM_Sales__c != null) {
                            account.Hierarchy_TTM_Sales__c += Trigger.new[j].Amount;
                        } else {
                            account.Hierarchy_TTM_Sales__c = Trigger.new[j].Amount;
                        }
                    }
                }

                accountMap.put(account.Id, account.clone(true,true));
            }
        }
            
        // Update the Account totals
        System.debug('Updating Accounts with new values: ' + accountMap.values());
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