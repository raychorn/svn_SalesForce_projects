/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This batch class handles mass processing of Contact information.    */
/*                                                                      */
/*----------------------------------------------------------------------*/

global class ProcessContacts implements Database.Batchable<sObject>{

    global final string query;

    global ProcessContacts(String query) {
        this.query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        // Declare local variables
        List<Contact>                                           contacts = new List<Contact>();

        for (sObject s : scope) {
            Contact c = (Contact)s;
            contacts.add(c);
        }
        UpdateContacts.updateContacts(contacts);
    }

    global void finish(Database.BatchableContext BC) {
    }
}