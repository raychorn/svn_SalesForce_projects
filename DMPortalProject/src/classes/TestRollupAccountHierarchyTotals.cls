/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the                    */
/*  Rollup Account Hierarchy Totals Trigger.                            */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestRollupAccountHierarchyTotals {
    
    static testMethod void testRollupAccountHierarchyTotals() {
        
        // Declare Local Variables
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        
        // Get Account Record Type Ids
        accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        accountRecordTypeId = accountRecordTypes.get(accountRecordType).getRecordTypeId();

        // Create three Accounts
        Account a1 = new Account (BillingState = 'CA', Hierarchy_TTM_Sales__c = 10500, Industry = 'Interior Design', Name = 'Acme', RecordTypeId = accountRecordTypeId,
            Site = 'HQ', TTM_Sales__c = 10000);
        Insert a1;
        Account a2 = new Account (BillingState = 'CA', Hierarchy_TTM_Sales__c = 500, Industry = 'Interior Design', Name = 'ABC', ParentId = a1.Id, 
            RecordTypeId = accountRecordTypeId, Site = 'HQ', TTM_Sales__c = 500);
        Insert a2;
        Account a3 = new Account (BillingState = 'CA', Hierarchy_TTM_Sales__c = 5000, Industry = 'Interior Design', Name = 'Paragon', RecordTypeId = accountRecordTypeId,
            Site = 'HQ', TTM_Sales__c = 5000);
        Insert a3;
        
        // Change the Parent and amount of Account 2
        a2.Hierarchy_TTM_Sales__c = 1000;
        a2.ParentId = a3.Id;
        update a2;
        
        // Assert that both Hierarchies have been updated
        System.assertEquals(10000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a1.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(1000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a2.Id].Hierarchy_TTM_Sales__c);       
        System.assertEquals(5500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a3.Id].Hierarchy_TTM_Sales__c);
        
        // "Accidentally" reset Account 3's Hierarchy
        a3.Hierarchy_TTM_Sales__c = null;
        update a3;
        
        // Change the Parent of Account 2 and null the Amount
        a2.Hierarchy_TTM_Sales__c = null;
        a2.ParentId = a1.Id;
        update a2;
        
        // Assert that both Hierarchies have been updated
        System.assertEquals(10500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a1.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(null, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a2.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(5000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a3.Id].Hierarchy_TTM_Sales__c);       

        // Change the Parent of Account 2 and the Amount
        a2.Hierarchy_TTM_Sales__c = 500;
        a2.ParentId = a3.Id;
        update a2;
        
        // Assert that both Hierarchies have been updated
        System.assertEquals(10000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a1.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a2.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(5500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a3.Id].Hierarchy_TTM_Sales__c);       

        // Change the Parent of Account 2
        a2.ParentId = a1.Id;
        update a2;
        
        // Assert that both Hierarchies have been updated
        System.assertEquals(10500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a1.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a2.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(5000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a3.Id].Hierarchy_TTM_Sales__c);       

        // "Accidentally" reset Account 3's Hierarchy
        a3.Hierarchy_TTM_Sales__c = null;
        update a3;
        
        // Change the Parent of Account 2
        a2.ParentId = a3.Id;
        update a2;
        
        // Assert that both Hierarchies have been updated
        System.assertEquals(10000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a1.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a2.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(5500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a3.Id].Hierarchy_TTM_Sales__c);       

        // Null the Amount of Account 2
        a2.Hierarchy_TTM_Sales__c = null;
        update a2;

        // Assert that both Hierarchies have been updated
        System.assertEquals(10000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a1.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(null, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a2.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(5500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a3.Id].Hierarchy_TTM_Sales__c);       

        // Change the Amount of Account 2
        a2.Hierarchy_TTM_Sales__c = 100;
        update a2;
        
        // Assert that both Hierarchies have been updated
        System.assertEquals(10000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a1.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(100, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a2.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(5500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a3.Id].Hierarchy_TTM_Sales__c);       

        // "Accidentally" reset Account 1's Hierarchy
        a1.Hierarchy_TTM_Sales__c = null;
        update a1;
        
        // Change the Parent and amount of Account 2
        a2.Hierarchy_TTM_Sales__c = null;
        a2.ParentId = a1.Id;
        update a2;
        
        // Assert that both Hierarchies have been updated
        System.assertEquals(10500, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a1.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(null, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a2.Id].Hierarchy_TTM_Sales__c);
        System.assertEquals(5000, [SELECT Hierarchy_TTM_Sales__c FROM Account WHERE Id = :a3.Id].Hierarchy_TTM_Sales__c);       
    }
}