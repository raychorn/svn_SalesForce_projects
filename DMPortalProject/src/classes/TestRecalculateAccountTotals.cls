/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the                    */
/*  Recalculate Account Totals Class and its scheduler Class.           */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestRecalculateAccountTotals {
    
    static testMethod void testRecalculateAccountTotals() {
        
        // Declare Local Variables
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        CronTrigger                             cronTrigger;
        String                                  jobId;
        Date                                    today = date.today();
        
        // Get Account Record Type Ids
        accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        accountRecordTypeId = accountRecordTypes.get(accountRecordType).getRecordTypeId();

        // Create Accounts
        Account a1 = new Account (Account_Level__c = 'Gold', BillingState = 'CA', Name = 'Acme', Industry = 'Interior Design', Membership_Level_Last_Changed__c = today.addDays(-100), Program_Type__c = 'DTP', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a1;
        Account a2 = new Account (Account_Level__c = 'Green', BillingState = 'CA', Name = 'Acme', Industry = 'Interior Design', Membership_Level_Last_Changed__c = today.addDays(-100), Program_Type__c = 'DTP', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a2;

        // Create an expiring Opportunity for the first Account
        Opportunity o1 = new Opportunity (AccountId = a1.Id, Amount = 1000, CloseDate = today, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 1', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o1;
        
        // Create a non-expiring Opportunity for the first Account
        Opportunity o2 = new Opportunity (AccountId = a1.Id, Amount = 500, CloseDate = today.addDays(1), Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 2', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o2;
        
        // Create a non-Expiring Opportunity for the second Account
        Opportunity o3 = new Opportunity (AccountId = a2.Id, Amount = 2000, CloseDate = today.addDays(1), Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 3', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o3;
        
        // Assert that the Accounts have their proper values
        System.assertEquals(1500, [SELECT TTM_Sales__c FROM Account WHERE Id = :a1.Id].TTM_Sales__c);
        System.assertEquals(2000, [SELECT TTM_Sales__c FROM Account WHERE Id = :a2.Id].TTM_Sales__c);

        // Execute the batchable test
        Test.startTest();

        // Schedule the test job
        String scheduleExpression = '0 59 23 3 9 ? 2099';
        jobId = System.schedule('testRecalculateAccountTotals', scheduleExpression, new ScheduleRecalculateAccountTotals());
        
        // Get the CronTrigger info
        cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Assert that the expressions are the same
        System.assertEquals(scheduleExpression, cronTrigger.CronExpression);
        
        // Assert that the Cron job has not started
        System.assertEquals(cronTrigger.TimesTriggered, 0);
        
        // Verify the next time the job will run
        System.assertEquals('2099-09-03 23:59:00', String.valueOf(cronTrigger.NextFireTime));
        
        // Stop the test
        Test.stopTest();
        
        // Assert that the test ran
//      System.assertEquals(cronTrigger.TimesTriggered, 1);
        
        // Assert that the Accounts have their proper values
//      System.assertEquals(500, [SELECT TTM_Sales__c FROM Account WHERE Id = :a1.Id].TTM_Sales__c);
        System.assertEquals(2000, [SELECT TTM_Sales__c FROM Account WHERE Id = :a2.Id].TTM_Sales__c);
    }
}