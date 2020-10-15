/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Class serves as the Unit Test class for the                    */
/*  Populate Membership ID History Class.                               */
/*                                                                      */
/*----------------------------------------------------------------------*/

@isTest

class TestPopulateMembershipIDHistory {
    
    static testMethod void testPopulateMembershipIDHistory() {
        
        // Declare Local Variables
        final string                            accountRecordType = 'Account';
        Id                                      accountRecordTypeId;
        Map<String, Schema.RecordTypeInfo>      accountRecordTypes = new Map<String, Schema.RecordTypeInfo>();
        String                                  designerId;
        Date                                    today = date.today();
        
        // Get Account Record Type Ids
        accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        accountRecordTypeId = accountRecordTypes.get(accountRecordType).getRecordTypeId();

        // Create an Account
        Account a1 = new Account (Account_Level__c = 'Gold', Automatic_Upgrade_Downgrade__c = 'Never', BillingState = 'CA', Name = 'Acme', Industry = 'Interior Design', Program_Type__c = 'DTP', RecordTypeId = accountRecordTypeId, Site = 'HQ');
        Insert a1;

        // Create a contact
        Contact c1 = new Contact (AccountId = a1.Id, Assign_Membership_ID__c = true, LastName = 'Andersen');
        Insert c1;
        
        // Assert the MIDH record was created
        designerId = [SELECT Reserved_Gold_Designer_ID__c FROM Contact WHERE Id = :c1.Id].Reserved_Gold_Designer_ID__c;
        System.assertEquals(1,[SELECT COUNT() FROM Membership_ID_History__c WHERE Contact__c = :c1.Id AND Membership_ID__c = :designerId AND Valid_Through__c = null]);
        
        // Update the Account
        PopulateMembershipIDHistoryHelper.resetTriggerInProcess();
        a1.Account_Level__c = 'Platinum';
        update a1;

        // Assert the old MIDH record was updated and the new one created
        System.assertEquals(1,[SELECT COUNT() FROM Membership_ID_History__c WHERE Contact__c = :c1.Id AND Membership_ID__c = :designerId AND Valid_Through__c = :today AND Expiration_Reason__c = 'Upgraded']);
        designerId = [SELECT Reserved_Platinum_Designer_ID__c FROM Contact WHERE Id = :c1.Id].Reserved_Platinum_Designer_ID__c;
        System.assertEquals(1,[SELECT COUNT() FROM Membership_ID_History__c WHERE Contact__c = :c1.Id AND Membership_ID__c = :designerId AND Valid_Through__c = null]);
        
        // Update the Account again
        PopulateMembershipIDHistoryHelper.resetTriggerInProcess();
        a1.Account_Level__c = 'Gold';
        update a1;

        // Assert the old MIDH record was updated and the new one created
        System.assertEquals(1,[SELECT COUNT() FROM Membership_ID_History__c WHERE Contact__c = :c1.Id AND Membership_ID__c = :designerId AND Valid_Through__c = :today AND Expiration_Reason__c = 'Downgraded']);
        designerId = [SELECT Reserved_Gold_Designer_ID__c FROM Contact WHERE Id = :c1.Id].Reserved_Gold_Designer_ID__c;
        System.assertEquals(1,[SELECT COUNT() FROM Membership_ID_History__c WHERE Contact__c = :c1.Id AND Membership_ID__c = :designerId AND Valid_Through__c = null]);
        
        // Update the Contact
        PopulateMembershipIDHistoryHelper.resetTriggerInProcess();
        c1.Design_Concierge_Services__c = true;
        c1.Designer_ID__c = '23456789101';
        update c1;

        // Assert the old MIDH record was updated and the new one created
        System.assertEquals(1,[SELECT COUNT() FROM Membership_ID_History__c WHERE Contact__c = :c1.Id AND Membership_ID__c = :designerId AND Valid_Through__c = :today AND Expiration_Reason__c = 'Program Change']);
        System.assertEquals(1,[SELECT COUNT() FROM Membership_ID_History__c WHERE Contact__c = :c1.Id AND Membership_ID__c = '23456789101' AND Valid_Through__c = null]);

        // Update the Contact
        PopulateMembershipIDHistoryHelper.resetTriggerInProcess();
        c1.Design_Concierge_Services__c = false;
        c1.Designer_ID__c = null;
        update c1;

        // Assert the old MIDH record was updated and the new one created
        System.assertEquals(1,[SELECT COUNT() FROM Membership_ID_History__c WHERE Contact__c = :c1.Id AND Membership_ID__c = '23456789101' AND Valid_Through__c = :today AND Expiration_Reason__c = 'Expired']);
    }
}