/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the Set Rollup         */
/*  stop date Trigger.                                                  */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestSetRollupStopDate {
    
    static testMethod void testSetRollupStopDate() {
        
        // Declare Local Variables
        Opportunity                             opportunity;
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        List<Opportunity>                       opportunityList = new List<Opportunity>();
        
        // Get Account Record Type Ids
        accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        accountRecordTypeId = accountRecordTypes.get(accountRecordType).getRecordTypeId();

        // Create two Accounts
        Account a1 = new Account (BillingState = 'CA', Industry = 'Interior Design', Name = 'Acme', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Account a2 = new Account (BillingState = 'CA', Hierarchy_TTM_Sales__c = 500, Industry = 'Interior Design', Name = 'ABC',
            RecordTypeId = accountRecordTypeId, Site = 'HQ', TTM_Sales__c = 500);
        Insert a1;
        Insert a2;
        
        // Create an Opportunity closing in December
        Opportunity o1 = new Opportunity (AccountId = a1.Id, Amount = 100, CloseDate = date.newInstance(2000,12,1), Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 1', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        opportunityList.add(o1);
        
        // Create an Opportunity not closing in December
        Opportunity o2 = new Opportunity (AccountId = a1.Id, Amount = 1000, CloseDate = date.newInstance(2000,1,1), Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 2', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        opportunityList.add(o2);
        
        // Insert the Opportunities
        insert opportunityList;
        
        // Assert that the Rollup Stop Date is correct for Opportunity 1
        opportunity = [SELECT Rollup_Stop_Date__c FROM Opportunity WHERE Id = :o1.Id];
        System.assertEquals(date.newInstance(2002,1,1), opportunity.Rollup_Stop_Date__c);
        
        // Assert that the Rollup Stop Date is correct for Opportunity 2
        opportunity = [SELECT Rollup_Stop_Date__c FROM Opportunity WHERE Id = :o2.Id];
        System.assertEquals(date.newInstance(2001,2,1), opportunity.Rollup_Stop_Date__c);
        
        // Update Opportunity 1
        o1.StageName = 'Negotiation';
        update o1;

        // Assert that the Rollup Stop Date is correct for Opportunity 1
        opportunity = [SELECT Rollup_Stop_Date__c FROM Opportunity WHERE Id = :o1.Id];
        System.assertEquals(null, opportunity.Rollup_Stop_Date__c);     
    }
}