/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Trigger processes Designer IDs and Expiration Dates for        */
/*  Contacts when they are created or updated.                          */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger ProcessContacts on Contact (after insert, after update) {
    
    // If the Trigger is an Insert, automatically pass the Contacts into the class for processing
    if (Trigger.IsInsert) {
        UpdateContacts.updateContacts(Trigger.new.deepClone(true));
    
    // If this is an Update, only pass in Contacts that might have a new Designer ID or Expiration Date
    } else {
    
        // Declare Local Variables
        List<Contact>   contacts = new List<Contact>();
        
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            if (Trigger.old[i].Membership_ID_Formula__c != Trigger.new[i].Membership_ID_Formula__c) {
                contacts.add(Trigger.new[i]);
            }
        }
        
        if (contacts.size() > 0) {
            UpdateContacts.updateContacts(contacts.deepClone(true));
        }
    }
}