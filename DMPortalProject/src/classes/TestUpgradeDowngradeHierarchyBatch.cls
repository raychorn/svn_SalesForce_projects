/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the Upgrade            */
/*  Downgrade Hierarchy Class.  It does not test its Scheduler class.   */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestUpgradeDowngradeHierarchyBatch {
    
    static testMethod void testUpgradeDowngradeHierarchyBatch() {
        
        // Declare Local Variables
        final string                                    accountRecordType = 'Account';
        Id                                              accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>              accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        Date                                            expirationInTwoYears;
        Date                                            lastYear = date.today().addDays(-365);
        String                                          level = '';
        List<Membership_Level_Puchase_Requirements__c>  mLPRList = new List<Membership_Level_Puchase_Requirements__c>();
        Date                                            newExpirationDateExpired;
        Date                                            newExpirationDateTwoYears;
        Date                                            newExpirationDateManualOrUp;
        Date                                            nextYear = date.today().addDays(365);
        String                                          query;
        final Integer                                   thisYear = date.today().year();
        final Date                                      today = date.today();
        Date                                            yesterday = date.today().addDays(-1);
        string                                          yesterdayString = String.valueOf(date.today().addDays(-1));

        
        // Get the Membership Level Purchase Requirements
        mLPRList = Membership_Level_Puchase_Requirements__c.getAll().values();
        
        // Get the lowest level
        for (Integer i = 0; i < mLPRList.size(); i++) {
            if (mLPRList[i].Purchase_Requirement__c == 0) {
                level = mLPRList[i].Name;
            }
        }

        // Set the date variables
        if (date.today().month() == 1) {
            if (date.today().day() == 1 ) {
                newExpirationDateExpired = date.newInstance(date.today().year(), 12, 31);
                newExpirationDateTwoYears = date.newInstance(date.today().year() + 1, 12, 31);
            } else {
                newExpirationDateExpired = date.newInstance(date.today().year() + 1, 1, 31);
                newExpirationDateTwoYears = date.newInstance(date.today().year() + 2, 1, 31);
            }
        } else {
            if (date.today().day() == 1 ) {
                newExpirationDateExpired = date.newInstance(date.today().year() + 1, date.today().month() - 1, date.daysInMonth(date.today().year() + 1, date.today().month() - 1));
                newExpirationDateTwoYears = date.newInstance(date.today().year() + 2, date.today().month() - 1, date.daysInMonth(date.today().year() + 2, date.today().month() - 1));
            } else {
                newExpirationDateExpired = date.newInstance(date.today().year() + 1, date.today().month(), date.daysInMonth(date.today().year() + 1, date.today().month()));
                newExpirationDateTwoYears = date.newInstance(date.today().year() + 2, date.today().month(), date.daysInMonth(date.today().year() + 2, date.today().month()));
            }
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

        // Set the query
        query = 'SELECT Id, Account_Level__c, Account_level_Expire__c, Account_Level_Last_Evaluated__c, Automatic_Upgrade_Downgrade__c, Hierarchy_TTM_Sales__c FROM Account WHERE (Id = \'' + a1.Id + '\' OR Id = \'' + a2.Id + '\' OR Id = \'' + a3.Id + '\' OR Id = \'' + a4.Id + '\' OR Id = \'' + a5.Id + '\' OR Id = \'' + a2Child.Id + '\') AND Program_Type__c = \'DTP\' AND ParentId = \'\' AND (Account_level_Expire__c = ' + yesterdayString + ' OR Account_Level_Last_Evaluated__c = null) AND (Account_Level__c <> \'' + level + '\' OR (Account_Level__c = \'' + level + '\' AND Account_Level_Last_Evaluated__c = null))';
        
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

        // Execute and stop the batchable test
        UpgradeDowngradeHierarchy   uDH = new UpgradeDowngradeHierarchy(query);
        ID batchProcessId = Database.executeBatch(uDH); 
        Test.StopTest();
        
        // Assert that the Accounts have their proper values
        System.assertEquals(newExpirationDateExpired, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a1.Id].Account_level_Expire__c);
        System.assertEquals('Gold', [SELECT Account_Level__c FROM Account WHERE ID = :a2.Id].Account_Level__c);
        System.assertEquals(newExpirationDateExpired, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a2.Id].Account_level_Expire__c);
        System.assertEquals('Green', [SELECT Account_Level__c FROM Account WHERE ID = :a3.Id].Account_Level__c);
        System.assertEquals(newExpirationDateTwoYears, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a3.Id].Account_level_Expire__c);
        System.assertEquals(newExpirationDateManualOrUp, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a4.Id].Account_level_Expire__c);
        System.assertEquals(null, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a5.Id].Account_level_Expire__c);
        System.assertEquals(today, [SELECT Account_Level_Last_Evaluated__c FROM Account WHERE ID = :a5.Id].Account_Level_Last_Evaluated__c);
        System.assertEquals('Gold', [SELECT Account_Level__c FROM Account WHERE ID = :a2Child.Id].Account_Level__c);
        System.assertEquals(newExpirationDateExpired, [SELECT Account_level_Expire__c FROM Account WHERE ID = :a2Child.Id].Account_level_Expire__c);
        System.assertEquals(today, [SELECT Account_Level_Last_Evaluated__c FROM Account WHERE ID = :a2Child.Id].Account_Level_Last_Evaluated__c);
    }
}