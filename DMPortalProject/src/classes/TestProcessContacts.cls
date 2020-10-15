/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the                    */
/*  Process Contacts Class and its scheduler Class.                     */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestProcessContacts {
    
    static testMethod void testProcessContacts() {
        
        // Declare Local Variables
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        CronTrigger                             cronTrigger;
        Date                                    expirationInTwoYears;
        String                                  jobId;
        Date                                    lastYear = date.today().addDays(-365);
        Date                                    nextYear = date.today().addDays(365);
        Date                                    yesterday = date.today().addDays(-1);
        
        // Set the expiration date variable
        if (date.today().month() == 1) {
            expirationInTwoYears = date.newInstance(date.today().year() + 1, 12, 31);
        } else {
            expirationInTwoYears = date.newInstance(date.today().year() + 2, date.today().month() - 1, date.daysInMonth(date.today().year() + 2, date.today().month() - 1));
        }

        // Get Account Record Type Ids
        accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        accountRecordTypeId = accountRecordTypes.get(accountRecordType).getRecordTypeId();

        // Create Accounts
        Account a1 = new Account (Account_Level__c = 'Gold', Automatic_Upgrade_Downgrade__c = 'Always', BillingState = 'CA', Name = 'Acme', Industry = 'Interior Design', Membership_Level_Last_Changed__c = yesterday, Program_Type__c = 'DTP', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a1;
        Account a2 = new Account (Account_Level__c = 'Green', Automatic_Upgrade_Downgrade__c = 'Always', BillingState = 'CA', Name = 'Acme', Industry = 'Interior Design', Membership_Level_Last_Changed__c = yesterday, Program_Type__c = 'DTP', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a2;
        Account a3 = new Account (Account_Level__c = 'Green', Automatic_Upgrade_Downgrade__c = 'Always', BillingState = 'CA', Name = 'Acme', Industry = 'Interior Design', Program_Type__c = 'DTP', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a3;

        // Create Contacts
        Contact c1= new Contact (AccountId = a1.Id, Assign_Membership_ID__c = true, Designer_Id__c = '712345678910', DTP_Card_Exp_Date_CLN__c = nextYear, LastName = 'Andersen');
        Insert c1;
        Contact c2= new Contact (AccountId = a2.Id, Assign_Membership_ID__c = true, Designer_Id__c = '612345678910', DTP_Card_Exp_Date_CLN__c = lastYear, LastName = 'Andersen');
        Insert c2;
        Contact c3= new Contact (AccountId = a3.Id, Assign_Membership_ID__c = true, Designer_Id__c = '112345678910', DTP_Card_Exp_Date_CLN__c = yesterday, LastName = 'Andersen');
        Insert c3;
        
        // Execute the batchable test
        Test.startTest();

        // Schedule the test job
        String scheduleExpression = '0 59 23 3 9 ? 2099';
        jobId = System.schedule('testScheduleProcessContacts', scheduleExpression, new ScheduleProcessContacts());
        
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
        
        // Assert that the Contacts have their proper values
//      System.assertEquals([SELECT Reserved_Gold_Designer_ID__c FROM Contact WHERE Id = :c1.Id].Reserved_Gold_Designer_ID__c,[SELECT Designer_ID__c FROM Contact WHERE Id = :c1.Id].Designer_ID__c);
        System.assertEquals(nextYear,[SELECT DTP_Card_Exp_Date_CLN__c FROM Contact WHERE Id = :c1.Id].DTP_Card_Exp_Date_CLN__c);
//      System.assertEquals([SELECT Reserved_Green_Designer_ID__c FROM Contact WHERE Id = :c1.Id].Reserved_Green_Designer_ID__c,[SELECT Designer_ID__c FROM Contact WHERE Id = :c2.Id].Designer_ID__c);
//      System.assertEquals(expirationInTwoYears,[SELECT DTP_Card_Exp_Date_CLN__c FROM Contact WHERE Id = :c2.Id].DTP_Card_Exp_Date_CLN__c);
//      System.assertEquals('',[SELECT Designer_ID__c FROM Contact WHERE Id = :c3.Id].Designer_ID__c);
        System.assertEquals(yesterday,[SELECT DTP_Card_Exp_Date_CLN__c FROM Contact WHERE Id = :c3.Id].DTP_Card_Exp_Date_CLN__c);
        
        // Change an Account to a "2"
        a1.Industry = 'Home Builder';
        a1.Program_Type__c = 'Preferred Business';
        a1.Automatic_Upgrade_Downgrade__c = 'Never';
        update a1;
        
        // Assert that the Contact's ID has changed
        System.assertEquals([SELECT Reserved_Home_Builder_ID__c FROM Contact WHERE Id = :c1.Id].Reserved_Home_Builder_ID__c,[SELECT Designer_ID__c FROM Contact WHERE Id = :c1.Id].Designer_ID__c);
        
    }
}