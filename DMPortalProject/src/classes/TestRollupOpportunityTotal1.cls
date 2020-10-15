/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the first Unit Test class for the              */
/*  Rollup Opportunity Totals Trigger.  There are two test classes      */
/*  due to the total number of SQL statements required to test all      */
/*  of the code sufficiently.                                           */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestRollupOpportunityTotal1 {
    
    static testMethod void testRollupOpportunityTotal1() {
        
        // Declare Local Variables
        Account                                 account;
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        final Date                              oldDate = date.newInstance(2000,1,1);
        List<Opportunity>                       opportunityList = new List<Opportunity>();
        final Date                              today = System.today();
        
        // Get Account Record Type Ids
        accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        accountRecordTypeId = accountRecordTypes.get(accountRecordType).getRecordTypeId();

        // Create two Accounts
        Account a1 = new Account (BillingState = 'CA', Industry = 'Interior Design', Name = 'Acme', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Account a2 = new Account (BillingState = 'CA', Hierarchy_TTM_Sales__c = 500, Industry = 'Interior Design', Name = 'ABC',
            RecordTypeId = accountRecordTypeId, Site = 'HQ', TTM_Sales__c = 500);
        Insert a1;
        Insert a2;
        
        // Create an old open Opportunity for the first Account
        Opportunity o1 = new Opportunity (AccountId = a1.Id, Amount = 100, CloseDate = oldDate, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 1', Secondary_Owner__c = 'Alexis Machado', StageName = 'Qualification',
            Type = 'Existing Business');
        opportunityList.add(o1);
        
        // Create an old closed Opportunity for the first Account
        Opportunity o2 = new Opportunity (AccountId = a1.Id, Amount = 1000, CloseDate = oldDate, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 2', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        opportunityList.add(o2);
        
        // Create a new open Opportunity for the first Account
        Opportunity o3 = new Opportunity (AccountId = a1.Id, Amount = 10000, CloseDate = today, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 3', Secondary_Owner__c = 'Alexis Machado', StageName = 'Qualification',
            Type = 'Existing Business');
        opportunityList.add(o3);
        
        // Create a new closed Opportunity for the first Account
        Opportunity o4 = new Opportunity (AccountId = a1.Id, Amount = 100000, CloseDate = today, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 4', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        opportunityList.add(o4);
        
        // Create an old closed Opportunity for the second Account
        Opportunity o5 = new Opportunity (AccountId = a2.Id, Amount = 5000, CloseDate = oldDate, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 5', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        opportunityList.add(o5);
        
        // Insert the Opportunities
        insert opportunityList;
        
        // Assert that the totals are correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(100000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(100000, account.TTM_Sales__c);
        
        // Assert that the total is correct for Account 2
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(500, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(500, account.TTM_Sales__c);
        
        // Close the open current Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.StageName = 'Order Entered';
        update o3;

        // Assert that the totals are correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(110000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(110000, account.TTM_Sales__c);      

        // Update the new Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.Amount = 9000;
        update o3;

        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(109000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(109000, account.TTM_Sales__c);      

        // Delete the new Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        delete o3;

        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(100000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(100000, account.TTM_Sales__c);      

        // Unelete the new Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        undelete o3;

        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(109000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(109000, account.TTM_Sales__c);      

        // Update the new Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.Amount = null;
        update o3;

        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(100000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(100000, account.TTM_Sales__c);      

        // Update the new Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.Amount = 8000;
        update o3;

        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(108000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(108000, account.TTM_Sales__c);      

        // "Accidentally" set the Account 1 TTM Sales to null
        a1.TTM_Sales__c = null;
        a1.Hierarchy_TTM_Sales__c = null;
        update a1;
        
        // Delete the new Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        delete o3;
        
        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(100000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(100000, account.TTM_Sales__c);      

        // "Accidentally" reset the Account 1 TTM Sales to null
        a1.TTM_Sales__c = null;
        a1.Hierarchy_TTM_Sales__c = null;
        update a1;
        
        // Undelete the new Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        undelete o3;
        
        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(108000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(108000, account.TTM_Sales__c);      
    }
}