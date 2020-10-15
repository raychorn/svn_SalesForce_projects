/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the Recalculate        */
/*  Account Totals class.  It does not test its Scheduler class.        */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestRecalculateAccountTotalsBatch {
    
    static testMethod void testRecalculateAccountTotalsBatch() {
        
        // Declare Local Variables
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        String                                  query;
        String                                  queryDate;
        Date                                    today = date.today();

        // Set Query Date
        queryDate = String.valueOf(date.newInstance(date.today().year()+1, date.today().month(), date.daysInMonth(date.today().year()+1, date.today().month())).addDays(1));
        
        // Get Account Record Type Ids
        accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        accountRecordTypeId = accountRecordTypes.get(accountRecordType).getRecordTypeId();

        // Create Accounts
        Account a1 = new Account (Account_Level__c = 'Gold', BillingState = 'CA', Name = 'Acme', Industry = 'Interior Design', Membership_Level_Last_Changed__c = today.addDays(-100), Program_Type__c = 'DTP', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a1;
        Account a2 = new Account (Account_Level__c = 'Green', BillingState = 'CA', Name = 'Acme', Industry = 'Interior Design', Membership_Level_Last_Changed__c = today.addDays(-100), Program_Type__c = 'DTP', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a2;

        // Set the query
        query = 'SELECT AccountId, Amount FROM Opportunity WHERE IsWon = true AND Rollup_Stop_Date__c = ' + queryDate + ' AND (AccountId = \'' + a1.Id + '\' OR AccountId = \'' + a2.id + '\')';

        // Create an expiring Opportunity for the first Account
        Opportunity o1 = new Opportunity (AccountId = a1.Id, Amount = 1000, CloseDate = today, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 1', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o1;
        
        // Create a non-expiring Opportunity for the first Account
        Opportunity o2 = new Opportunity (AccountId = a1.Id, Amount = 500, CloseDate = today.addDays(32), Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 2', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o2;
        
        // Create a non-Expiring Opportunity for the second Account
        Opportunity o3 = new Opportunity (AccountId = a2.Id, Amount = 2000, CloseDate = today.addDays(32), Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 3', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o3;

        // Assert that the Accounts have their proper values
        System.assertEquals(1500, [SELECT TTM_Sales__c FROM Account WHERE Id = :a1.Id].TTM_Sales__c);
        System.assertEquals(2000, [SELECT TTM_Sales__c FROM Account WHERE Id = :a2.Id].TTM_Sales__c);

        // Execute the batchable test
        Test.startTest();

        // Execute and stop the batchable test
        RecalculateAccountTotals    rAT = new RecalculateAccountTotals(query);
        ID batchProcessId = Database.executeBatch(rAT); 
        Test.StopTest();
        
        // Assert that the Accounts have their proper values
        System.assertEquals(1500, [SELECT TTM_Sales__c FROM Account WHERE Id = :a1.Id].TTM_Sales__c);
        System.assertEquals(2000, [SELECT TTM_Sales__c FROM Account WHERE Id = :a2.Id].TTM_Sales__c);
    }
}