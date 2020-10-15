/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the Upgrade            */
/*  Downgrade Hierarchy Class and its scheduler Class.                  */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestUpgradeDowngradeHierarchy {
    
    static testMethod void testUpgradeDowngradeHierarchy() {
        
        // Declare Local Variables
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        CronTrigger                             cronTrigger;
        Date                                    expirationInTwoYears;
        String                                  jobId;
        Date                                    lastYear = date.today().addDays(-365);
        Date                                    newExpirationDateExpired;
        Date                                    newExpirationDateTwoYears;
        Date                                    newExpirationDateManualOrUp;
        Date                                    nextYear = date.today().addDays(365);
        final Integer                           thisYear = date.today().year();
        final Date                              today = date.today();
        Date                                    yesterday = date.today().addDays(-1);
        string                                  yesterdayString = String.valueOf(date.today().addDays(-1));
        
        // Set the date variables
        if (date.today().month() == 1) {
            newExpirationDateExpired = date.newInstance(thisYear, 12, 31);
            newExpirationDateTwoYears = date.newInstance(thisYear + 1, 12, 31);
        } else {
            newExpirationDateExpired = date.newInstance(thisYear + 1, date.today().month() - 1, date.daysInMonth(thisYear + 1, date.today().month() - 1));
            newExpirationDateTwoYears = date.newInstance(thisYear + 2, date.today().month() - 1, date.daysInMonth(thisYear + 2, date.today().month() - 1));
        }
        newExpirationDateManualOrUp = date.newInstance(thisYear + 1, date.today().month(), date.daysInMonth(thisYear + 1, date.today().month()));

        // Get Account Record Type Ids
        accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        accountRecordTypeId = accountRecordTypes.get(accountRecordType).getRecordTypeId();

        // Create Accounts
        Account a1 = new Account (Account_Level__c = 'Platinum', Account_level_Expire__c = yesterday,
            Account_Level_Last_Evaluated__c = yesterday.addDays(-32), Automatic_Upgrade_Downgrade__c = 'Never', BillingState = 'CA',
            Name = 'Acme', Industry = 'Interior Design', Membership_Level_Last_Changed__c = yesterday, Program_Type__c = 'DTP',
            RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a1;
        Account a2 = new Account (Account_Level__c = 'Platinum', Account_level_Expire__c = yesterday,
            Account_Level_Last_Evaluated__c = yesterday.addDays(-32), Automatic_Upgrade_Downgrade__c = 'Always', BillingState = 'CA',
            Name = 'ABC', Industry = 'Interior Design', Membership_Level_Last_Changed__c = yesterday, Program_Type__c = 'DTP',
            RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a2;
        Account a3 = new Account (Account_Level__c = 'Platinum', Account_level_Expire__c = yesterday,
            Account_Level_Last_Evaluated__c = yesterday.addDays(-32), Automatic_Upgrade_Downgrade__c = 'Always', BillingState = 'CA',
            Name = 'DEF', Industry = 'Interior Design', Membership_Level_Last_Changed__c = yesterday, Program_Type__c = 'DTP',
            RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a3;
        Account a4 = new Account (Account_Level__c = 'Gold', Account_level_Expire__c = yesterday.addDays(32),
            Account_Level_Last_Evaluated__c = null, Automatic_Upgrade_Downgrade__c = 'Always', BillingState = 'CA',
            Name = 'GHI', Industry = 'Interior Design', Membership_Level_Last_Changed__c = yesterday, Program_Type__c = 'DTP',
            RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a4;
        Account a5 = new Account (Account_Level__c = 'Green', Account_level_Expire__c = yesterday.addDays(32),
            Account_Level_Last_Evaluated__c = null, Automatic_Upgrade_Downgrade__c = 'Never', BillingState = 'CA',
            Name = 'JKL', Industry = 'Interior Design', Membership_Level_Last_Changed__c = yesterday, Program_Type__c = 'DTP',
            RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a5;
        Account a2Child = new Account (Account_Level__c = 'Platinum', Account_level_Expire__c = yesterday,
            Account_Level_Last_Evaluated__c = yesterday.addDays(-32), Automatic_Upgrade_Downgrade__c = 'Always', BillingState = 'CA',
            Name = 'MNO', Industry = 'Interior Design', Membership_Level_Last_Changed__c = yesterday, ParentId = a2.Id, Program_Type__c = 'DTP',
            RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a2Child;

        // Create Opportunities
        Opportunity o1 = new Opportunity (AccountId = a2.Id, Amount = 11000, CloseDate = yesterday, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 1', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o1;
        Opportunity o2 = new Opportunity (AccountId = a4.Id, Amount = 21000, CloseDate = yesterday, Concept__c = 'PB',
            CustomFieldProductType__c = 'Designer', Name = 'Opp 2', Secondary_Owner__c = 'Alexis Machado', StageName = 'Order Entered',
            Type = 'Existing Business');
        insert o2;

/*      // Assert that the Accounts have their proper values
        System.assertEquals(yesterday, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a1.Id].Account_level_Expire__c);
        System.assertEquals('Platinum', [SELECT Account_Level__c FROM Account WHERE ID = :a2.Id].Account_Level__c);
        System.assertEquals(yesterday, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a2.Id].Account_level_Expire__c);
        System.assertEquals('Platinum', [SELECT Account_Level__c FROM Account WHERE ID = :a3.Id].Account_Level__c);
        System.assertEquals(yesterday, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a3.Id].Account_level_Expire__c);
        System.assertEquals(yesterday.addDays(32), [SELECT Account_level_Expire__c FROM Account WHERE ID = :a4.Id].Account_level_Expire__c);
        System.assertEquals(yesterday.addDays(32), [SELECT Account_level_Expire__c FROM Account WHERE ID = :a5.Id].Account_level_Expire__c);
        System.assertEquals(null, [SELECT Account_Level_Last_Evaluated__c FROM Account WHERE ID = :a5.Id].Account_Level_Last_Evaluated__c);
        System.assertEquals('Platinum', [SELECT Account_Level__c FROM Account WHERE ID = :a2Child.Id].Account_Level__c);
        System.assertEquals(yesterday, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a2Child.Id].Account_level_Expire__c);
        System.assertEquals(yesterday.addDays(-32), [SELECT Account_Level_Last_Evaluated__c FROM Account WHERE ID = :a2Child.Id].Account_Level_Last_Evaluated__c);
*/
        // Execute the batchable test
        Test.startTest();

        // Schedule the test job
        String scheduleExpression = '0 59 23 3 9 ? 2099';
        jobId = System.schedule('testScheduleUpgradeDowngradeHierarchy', scheduleExpression, new ScheduleUpgradeDowngradeHierarchy());
        
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
//      System.assertEquals(newExpirationDateExpired, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a1.Id].Account_level_Expire__c);
//      System.assertEquals('Gold', [SELECT Account_Level__c FROM Account WHERE ID = :a2.Id].Account_Level__c);
//      System.assertEquals(newExpirationDateExpired, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a2.Id].Account_level_Expire__c);
//      System.assertEquals('Green', [SELECT Account_Level__c FROM Account WHERE ID = :a3.Id].Account_Level__c);
//      System.assertEquals(null, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a3.Id].Account_level_Expire__c);
//      System.assertEquals(newExpirationDateManualOrUp, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a4.Id].Account_level_Expire__c);
//      System.assertEquals(null, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a5.Id].Account_level_Expire__c);
//      System.assertEquals(today, [SELECT Account_Level_Last_Evaluated__c FROM Account WHERE ID = :a5.Id].Account_Level_Last_Evaluated__c);
//      System.assertEquals('Gold', [SELECT Account_Level__c FROM Account WHERE ID = :a2Child.Id].Account_Level__c);
//      System.assertEquals(newExpirationDateExpired, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a2Child.Id].Account_level_Expire__c);
//      System.assertEquals(today, [SELECT Account_Level_Last_Evaluated__c FROM Account WHERE ID = :a2Child.Id].Account_Level_Last_Evaluated__c);
    }
}