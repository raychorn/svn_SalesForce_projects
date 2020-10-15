/*---------------------------------------------------------------------------------*/
/*                                                                                 */
/*  This class calculates Account TTM totals.                                      */
/*                                                                                 */
/*  ARGUMENTS:                                                                     */
/*  accountIds:         The IDs of the Accounts that need calculated totals.       */
/*                                                                                 */
/*---------------------------------------------------------------------------------*/

public class CalculateAccountTotals {
    
    public static void calculateAccountTotals(Set<ID> accountIds) {
        
        // Declare local variables
        Account             account; // An Account holding variable
        List<Account>       accountList = new List<Account>(); // A list of Accounts for Hierarchy TTM Processing
        Map<Id, Account>    accounts; // Map of Account IDs to the Accounts to store updated totals
        AggregateResult[]   accountTotals;  // The summarized Account TTM totals
        AggregateResult[]   hierarchyTotals;  // The summarized Account Hierarchy TTM totals
        final Date          today = System.today();  // Today
        
        // Get rolled up total of Opportunities that are included in the TTM rollups
        accountTotals = [SELECT AccountId, SUM(Amount)total FROM Opportunity WHERE IsWon = true AND Rollup_Stop_Date__c > :today AND AccountId IN :accountIds GROUP BY AccountId];
        
        // Get the Accounts to be updated
        accounts = new Map<Id, Account>([SELECT Id, ParentId, TTM_Sales__c FROM Account WHERE Id IN :accountIds]);
        
        // Loop through the grouped results and update the TTM totals on the Accounts
        for (Integer i = 0; i < accountTotals.size(); i++)
        {
            if (accounts.containsKey((Id)accountTotals[i].get('AccountId')))
            {
                account = accounts.get((Id)accountTotals[i].get('AccountId'));
                account.TTM_Sales__c = ((decimal)accountTotals[i].get('total') == null ? 0 : (decimal)accountTotals[i].get('total'));
                accounts.put(account.Id, account.clone(true, true));
            }
        }
        
        // Update the Accounts
        accountList = accounts.values();
        System.debug('Updating: ' + accountList);
        Database.SaveResult[] saveResultList = database.update(accountList, false);
        for (Integer m = 0; m < saveResultList.size(); m++) {
            if (!saveResultList[m].IsSuccess()) {
                Database.Error err = saveResultList[m].getErrors()[0];
                System.debug(err.getMessage());
            }
        }

        // Add IDs of potential parents
        for (Integer j = 0; j < accountList.size(); j++)
        {
            if (accountList[j].ParentId != null)
            {
                accountIds.add(accountList[j].ParentId);
            }
        }
        
        // Get rolled up totals of Accounts in the hierarchy
        hierarchyTotals = [SELECT ParentId, SUM(TTM_Sales__c)total FROM Account WHERE ParentId IN :accountIds GROUP BY ParentId];
        
        // Get the Accounts to be updated
        accounts = new Map<Id, Account>([SELECT Id, Hierarchy_TTM_Sales__c, ParentId, TTM_Sales__c FROM Account WHERE Id IN :accountIds]);
        
        // Get the list of Accounts from the Map
        accountList = accounts.values();
        
        // Loop through the Accounts adding each Account's TTM sales to its Hierarchy Totals
        for (Integer k = 0; k < accountList.size(); k++)
        {
            if (accountList[k].TTM_Sales__c == null) 
            {
                accountList[k].Hierarchy_TTM_Sales__c = 0;
            } else {
                accountList[k].Hierarchy_TTM_Sales__c = accountList[k].TTM_Sales__c;
            }
            accounts.put(accountList[k].Id, accountList[k].clone(true, true));
        }
        
        // Loop through the child Accounts adding the TTM Sales to the Parent Hierarchy
        if (hierarchyTotals.size() > 0)
        {
            for (integer l = 0; l < hierarchyTotals.size(); l++)
            {
                if (accounts.containsKey((Id)hierarchyTotals[l].get('ParentId')))
                {
                    account = accounts.get((Id)hierarchyTotals[l].get('ParentId'));
                    account.Hierarchy_TTM_Sales__c += ((decimal)hierarchyTotals[l].get('total') == null ? 0 : (decimal)hierarchyTotals[l].get('total'));
                    accounts.put(account.Id, account.clone(true, true));
                }
            }
        }

        // Update the Accounts
        System.debug('Updating: ' + accounts.values());
        Database.SaveResult[] saveResultList2 = database.update(accounts.values(), false);
        for (Integer m = 0; m < saveResultList2.size(); m++) {
            if (!saveResultList2[m].IsSuccess()) {
                Database.Error err = saveResultList2[m].getErrors()[0];
                System.debug(err.getMessage());
            }
        }
    }
}