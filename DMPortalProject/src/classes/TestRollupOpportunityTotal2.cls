/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the second Unit Test class for the             */
/*  Calculate Account Totals Triggers.  There are two test classes      */
/*  due to the total number of SQL statements required to test all      */
/*  of the code sufficiently.                                           */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestRollupOpportunityTotal2 {
    
    static testMethod void testRollupOpportunityTotal2() {
        
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
        
        // Create a new closed Opportunity for the first Account
        Opportunity o3 = new Opportunity (AccountId = a1.Id, Amount = 10000, CloseDate = today, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 3', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        opportunityList.add(o3);
        
        // Create another new closed Opportunity for the first Account
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
        System.assertEquals(110000, Account.TTM_Sales__c);
        System.assertEquals(110000, Account.Hierarchy_TTM_Sales__c);
        
        // Update the new Opportunity for Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.CloseDate = oldDate;
        update o3;

        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(100000, Account.TTM_Sales__c);
        System.assertEquals(100000, Account.Hierarchy_TTM_Sales__c);

        // "Accidentally" reset the Account 1 TTM Sales to null
        a1.TTM_Sales__c = null;
        a1.Hierarchy_TTM_Sales__c = null;
        update a1;
        
        // Update both the close date and the amount
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.CloseDate = today;
        o3.Amount = 6000;
        update o3;
        
        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(106000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(106000, account.TTM_Sales__c);      

        // "Accidentally" reset the Account 1 TTM Sales to null
        a1.TTM_Sales__c = null;
        a1.Hierarchy_TTM_Sales__c = null;
        update a1;
        
        // Update the amount
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.Amount = 7000;
        update o3;
        
        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(107000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(107000, account.TTM_Sales__c);      

        // "Accidentally" reset the Account 1 TTM Sales to null
        a1.TTM_Sales__c = null;
        a1.Hierarchy_TTM_Sales__c = null;
        update a1;
        
        // Update the amount
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.Amount = null;
        update o3;
        
        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(100000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(100000, account.TTM_Sales__c);      

        // "Accidentally" reset the Account 1 TTM Sales to null
        a1.TTM_Sales__c = null;
        a1.Hierarchy_TTM_Sales__c = null;
        update a1;
        
        // Update the amount
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o3.Amount = 1000;
        update o3;
        
        // Assert that the total is correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(101000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(101000, account.TTM_Sales__c);      

        // Create a Dangler
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        Opportunity o6 = new Opportunity (Amount = 4000, CloseDate = today, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 6', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o6;
        
        // Update the dangler to be part of an Account
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o6.AccountId = a1.Id;
        update o6;
        
        // Assert that the totals are correct for Account 1
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(105000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(105000, account.TTM_Sales__c);      

        // Reparent the former Dangler from Account 1 to Account 2
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o6.AccountId = a2.Id;
        update o6;
        
        // Assert that the totals are correct for the Accounts
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(101000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(101000, account.TTM_Sales__c);      
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(4000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(4000, account.TTM_Sales__c);        

        // "Accidentally" reset the Account totals to null
        a1.TTM_Sales__c = 0;
        a1.Hierarchy_TTM_Sales__c = 0;
        update a1;
        a2.TTM_Sales__c = 0;
        a2.Hierarchy_TTM_Sales__c = 0;
        update a2;
        
        // Reparent the former Dangler from Account 2 to Account 1
        RollupOpportunityTotalsHelper.resetTriggersInProcess();
        o6.AccountId = a1.Id;
        update o6;
        
        // Assert that the totals are correct for the Accounts
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(105000, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(105000, account.TTM_Sales__c);      
        account = [SELECT Hierarchy_TTM_Sales__c, TTM_Sales__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(0, account.Hierarchy_TTM_Sales__c);
        System.assertEquals(0, account.TTM_Sales__c);       
    }
}