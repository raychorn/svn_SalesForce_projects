/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Trigger calls the class to update Account TTM Totals if        */
/*  Account TTM Totals have changed.                                    */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger CalculateAccountTotalsOnAccount on Account (after update, after delete, after undelete) {
    
    // Declare local variables
    Set<Id>     accountIds = new Set<Id>(); // A Set of IDs for Accounts that need calculated totals
    final date  today = System.today(); // Today
    
    // Loop through the Accounts getting the Account IDs for Accounts that may be affected by the records
    for (Integer i = 0; (Trigger.isDelete ? i < Trigger.old.size() : i < Trigger.new.size()); i++)
    {
        if (Trigger.isDelete)
        {
            if(Trigger.old[i].ParentId != null && Trigger.old[i].TTM_Sales__c > 0)
            {
                accountIds.add(Trigger.old[i].ParentId);
            }
        } else {
            if (Trigger.isUpdate)
            {
                if (Trigger.old[i].ParentId != Trigger.new[i].ParentId)
                {
                    if(Trigger.old[i].ParentId != null)
                    {
                        accountIds.add(Trigger.old[i].ParentId);
                    }

                    if(Trigger.new[i].ParentId != null)
                    {
                        accountIds.add(Trigger.new[i].ParentId);
                    }
                }
            } else {
                if(Trigger.new[i].ParentId != null && Trigger.new[i].TTM_Sales__c > 0)
                {
                    accountIds.add(Trigger.new[i].ParentId);
                }
            }
        }
    }
    
    // If there are Accounts to be processed, pass them into the calculation Class.
    if (accountIds.size() > 0)
    {
        CalculateAccountTotals.calculateAccountTotals(accountIds);
    }
}