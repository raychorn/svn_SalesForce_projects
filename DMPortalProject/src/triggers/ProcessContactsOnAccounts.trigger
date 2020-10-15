/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Trigger processes Designer IDs and Expiration Dates for        */
/*  Contacts when their Accounts change.  This is designed to process   */
/*  the first 200, while nightly batch updates will process any others. */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger ProcessContactsOnAccounts on Account (after update) {
    
    // Declare Local Variables
    Set<ID>         accountIds = new Set<ID>();
    List<Contact>   contacts = new List<Contact>();
    boolean         executeTrigger = false;
    
    // Look through the Trigger array determining whether the Trigger should run
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if ((Trigger.old[i].Industry != Trigger.new[i].Industry) || (Trigger.old[i].Account_Level__c != Trigger.new[i].Account_Level__c)) {
            accountIds.add(Trigger.new[i].Id);
            executeTrigger = true;
        }
    }
    
    // If the Trigger is to be executed, get the first 200 Contacts for the Accounts and pass them into the UpdateContacts Class
    if (executeTrigger) {
        contacts = [SELECT Id, Account_Expiration_Last_Changed__c, Account_Level__c, Account_level_Expire__c, Account_Membership_Level_Last_Changed__c, Assign_Membership_ID__c, Design_Concierge_Services__c, Designer_ID__c, DTP_Card_Exp_Date_CLN__c, Membership_ID_Formula__c FROM Contact WHERE AccountId IN :accountIds AND ID_Formula_Equals_ID__c = 'No' LIMIT 200];
        
        if (contacts.size() > 0) {
            UpdateContacts.updateContacts(contacts);
        }
    }
}