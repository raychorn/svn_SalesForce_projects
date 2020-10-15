/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the                    */
/*  Rollup Account Totals Trigger.                                      */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestRollupAccountTotal {
    
/*    static testMethod void testRollupAccountTotal() {
        
        // Declare Local Variables
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
        Account a2 = new Account (BillingState = 'CA', Industry = 'Interior Design', Name = 'ABC', RecordTypeId = accountRecordTypeId,
            Site = 'HQ', TTM_Sales__c = 500);
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
        
        // Assert that the total is correct for Account 1
        System.assertEquals(100000, [SELECT TTM_Sales__c FROM Account WHERE Id = :a1.Id].TTM_Sales__c);
        
        // Assert that the total is correct for Account 2
        System.assertEquals(0, [SELECT TTM_Sales__c FROM Account WHERE Id = :a2.Id].TTM_Sales__c);
        
        // Close the open current Opportunity for Account 1
        o3.StageName = 'Order Entered';
        update o3;

        // Assert that the total is correct for Account 1
        System.assertEquals(110000, [SELECT TTM_Sales__c FROM Account WHERE Id = :a1.Id].TTM_Sales__c);     
    }*/
}