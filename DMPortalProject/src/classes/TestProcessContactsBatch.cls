/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the                    */
/*  Process Contacts class.  It does not test its Scheduler class.      */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestProcessContactsBatch {
    
    static testMethod void testProcessContactsBatch() {
        
        // Declare Local Variables
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        Date                                    expirationInTwoYears;
        Date                                    lastYear = date.today().addDays(-365);
        Date                                    nextYear = date.today().addDays(365);
        String                                  query;
        Date                                    yesterday = date.today().addDays(-1);
        string                                  yesterdayString = String.valueOf(date.today().addDays(-1));

        
        // Set the query
        query = 'SELECT Id, Account.Account_Level__c, Account.Account_level_Expire__c, Account.Membership_Level_Last_Changed__c, Assign_Membership_ID__c, Design_Concierge_Services__c, Designer_ID__c, DTP_Card_Exp_Date_CLN__c, Membership_ID_Formula__c FROM Contact WHERE Account.Membership_Level_Last_Changed__c >= ' + yesterdayString + ' OR DTP_Card_Exp_Date_CLN__c = ' + yesterdayString + ' LIMIT 200';
        
        // Set the expiration date variable
        if (date.today().month() == 1) {
            if (date.today().day() == 1 ) {
                expirationInTwoYears = date.newInstance(date.today().year() + 1, 12, 31);
            } else {
                expirationInTwoYears = date.newInstance(date.today().year() + 2, 1, 31);
            }
        } else {
            if (date.today().day() == 1 ) {
                expirationInTwoYears = date.newInstance(date.today().year() + 2, date.today().month() - 1, date.daysInMonth(date.today().year() + 2, date.today().month() - 1));
            } else {
                expirationInTwoYears = date.newInstance(date.today().year() + 2, date.today().month(), date.daysInMonth(date.today().year() + 2, date.today().month()));
            }
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
        Contact c2= new Contact (AccountId = a2.Id, Assign_Membership_ID__c = true, Designer_Id__c = '612345678910', DTP_Card_Exp_Date_CLN__c = nextYear, LastName = 'Andersen');
        Insert c2;
        Contact c3= new Contact (AccountId = a3.Id, Assign_Membership_ID__c = true, Designer_Id__c = '112345678910', DTP_Card_Exp_Date_CLN__c = yesterday, LastName = 'Andersen');
        Insert c3;
        
        // Execute the batchable test
        Test.startTest();

        // Execute and stop the batchable test
        ProcessContacts processContacts = new ProcessContacts(query);
        ID batchProcessId = Database.executeBatch(processContacts); 
        Test.StopTest();
        
        // Assert that the Contacts have their proper values
        System.assertEquals([SELECT Reserved_Gold_Designer_ID__c FROM Contact WHERE Id = :c1.Id].Reserved_Gold_Designer_ID__c,[SELECT Designer_ID__c FROM Contact WHERE Id = :c1.Id].Designer_ID__c);
        System.assertEquals(nextYear,[SELECT DTP_Card_Exp_Date_CLN__c FROM Contact WHERE Id = :c1.Id].DTP_Card_Exp_Date_CLN__c);
        System.assertEquals([SELECT Reserved_Green_Designer_ID__c FROM Contact WHERE Id = :c2.Id].Reserved_Green_Designer_ID__c,[SELECT Designer_ID__c FROM Contact WHERE Id = :c2.Id].Designer_ID__c);
        System.assertEquals(expirationInTwoYears,[SELECT DTP_Card_Exp_Date_CLN__c FROM Contact WHERE Id = :c2.Id].DTP_Card_Exp_Date_CLN__c);
        System.assertEquals(null,[SELECT Designer_ID__c FROM Contact WHERE Id = :c3.Id].Designer_ID__c);
        System.assertEquals(yesterday,[SELECT DTP_Card_Exp_Date_CLN__c FROM Contact WHERE Id = :c3.Id].DTP_Card_Exp_Date_CLN__c);
    }
}