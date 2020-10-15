/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Trigger calls the class to update Account TTM Totals if        */
/*  Opportunities that fall in the Trailing Month rollup date range     */
/*  have been added or changed.                                         */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger CalculateAccountTotalsOnOpportunity on Opportunity (after insert, after update, after delete, after undelete) {
    
    // Declare local variables
    Set<Id>     accountIds = new Set<Id>(); // A Set of IDs for Accounts that need calculated totals
    final date  today = System.today(); // Today
    
    // Loop through the Opportunities getting the Account IDs for Accounts that may be affected by the records
    for (Integer i = 0; (Trigger.isDelete ? i < Trigger.old.size() : i < Trigger.new.size()); i++)
    {
        if(Trigger.isDelete ? (Trigger.old[i].Rollup_Stop_Date__c > today) : (((Trigger.isInsert || Trigger.isUndelete) &&
        Trigger.new[i].Rollup_Stop_Date__c > today) || (Trigger.isUpdate && ((Trigger.new[i].Rollup_Stop_Date__c > today &&
        Trigger.old[i].Rollup_Stop_Date__c <= today) || (Trigger.new[i].Rollup_Stop_Date__c <= today &&
        Trigger.old[i].Rollup_Stop_Date__c > today) || (Trigger.new[i].Amount != Trigger.old[i].Amount) ||
        (Trigger.new[i].IsWon != Trigger.old[i].IsWon) || (Trigger.new[i].AccountId != Trigger.old[i].AccountId)))))
        {
            if (Trigger.isDelete)
            {
                if (Trigger.old[i].AccountId != null)
                {
                    accountIds.add(Trigger.old[i].AccountId);
                }
            } else {
                if (Trigger.IsUpdate)
                {
                    if(Trigger.old[i].AccountId != null)
                    {
                        accountIds.add(Trigger.old[i].AccountId);
                    }
                }
                
                if(Trigger.new[i].AccountId != null)
                {
                    accountIds.add(Trigger.new[i].AccountId);
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