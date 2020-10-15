/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This is the helper class to track whether various parts of the      */
/*  RollupOpportunityTotals Trigger on Opportunities is running.        */
/*                                                                      */
/*  ARGUMENTS: none                                                     */
/*                                                                      */
/*----------------------------------------------------------------------*/

public class RollupOpportunityTotalsHelper {
    
    // Delare variables and initialize them to false
    private static Set<Id>  switchingAccountsInProcess = new Set<Id>();
    private static Set<Id>  removeFromTotalsInProcess = new Set<Id>();
    private static Set<Id>  addToTotalsInProcess = new Set<Id>();
    private static Set<Id>  amountChangedInProcess = new Set<Id>();
    
    // This function passes the set of Opportunities switching accounts to Triggers
    public static Set<Id> switchingAccountsInProcess() {
        return switchingAccountsInProcess;
    }
    
    // This function is called by Triggers to inform the Class that a given Opportunity is switching Accounts
    public static void setSwitchingAccountsInProcess(Id opportunityId) {
        switchingAccountsInProcess.add(opportunityId);
    }
    
    // This function passes the set of Opportunities being removed from totals to Triggers
    public static Set<Id> removeFromTotalsInProcess() {
        return removeFromTotalsInProcess;
    }
    
    // This function is called by Triggers to inform the Class that a given Opportunity is being removed from the totals
    public static void setRemoveFromTotalsInProcess(Id opportunityId) {
        removeFromTotalsInProcess.add(opportunityId);
    }
    
    // This function passes the set of Opportunities being added to totals to Triggers
    public static Set<Id> addToTotalsInProcess() {
        return addToTotalsInProcess;
    }
    
    // This function is called by Triggers to inform the Class that a given Opportunity is being removed from the totals
    public static void setAddToTotalsInProcess(Id opportunityId) {
        addToTotalsInProcess.add(opportunityId);
    }
    
    // This function passes the set of Opportunities with amounts changing to Triggers
    public static Set<Id> amountChangedInProcess() {
        return amountChangedInProcess;
    }
    
    // This function is called by Triggers to inform the Class that a given Opportunity is having amounts changed
    public static void setAmountChangedInProcess(Id opportunityId) {
        amountChangedInProcess.add(opportunityId);
    }
    
    // This function is called by the Unit Test to simulate completion of a DML statement.  This function is NOT intended for any other purpose
    public static void resetTriggersInProcess() {
        switchingAccountsInProcess.clear();
        removeFromTotalsInProcess.clear();
        addToTotalsInProcess.clear();
        amountChangedInProcess.clear();
    }
}