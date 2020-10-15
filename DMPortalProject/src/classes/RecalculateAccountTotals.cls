/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This batch class recalculates Account Rollup totals.  It is         */
/*  designed to be run on the first of every month when Opportunities   */
/*  "expire" and should no longer be rolled into the TTM totals.        */
/*                                                                      */
/*----------------------------------------------------------------------*/

global class RecalculateAccountTotals implements Database.Batchable<sObject>{

    global final string query;

    global RecalculateAccountTotals(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id>             accountIds = new Set<Id>();
        List<Opportunity>   opportunities = new List<Opportunity>();

        for (sObject s : scope) {
            Opportunity o = (Opportunity)s;
            if (o.AccountId != null) {
                accountIds.add(o.AccountId);
            }
        }

        // Update the Accounts
        CalculateAccountTotals.calculateAccountTotals(accountIds);
        
    }

    global void finish(Database.BatchableContext BC) {
    }
}