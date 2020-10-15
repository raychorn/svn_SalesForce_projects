/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This batch class schedules the batch Apex to process Contacts       */
/*  that have been part of an upgrade / downgrade or expiration.        */
/*                                                                      */
/*----------------------------------------------------------------------*/

global class ScheduleProcessContacts implements Schedulable {

    global void execute (SchedulableContext sc) {

        String                                                  level = '';
        List<Membership_Level_Puchase_Requirements__c>          mLPRList = new List<Membership_Level_Puchase_Requirements__c>();
        string                                                  yesterday = String.valueOf(date.today().addDays(-1));

        mLPRList = Membership_Level_Puchase_Requirements__c.getAll().values();
        
        for (Integer i = 0; i < mLPRList.size(); i++) {
            if (mLPRList[i].Purchase_Requirement__c == 0) {
                level = mLPRList[i].Name;
            }
        }
        
            processContacts pc = new ProcessContacts('SELECT Id, Account_Expiration_Last_Changed__c, Account_Level__c, Account_Level_Expire__c, Account_Membership_Level_Last_Changed__c, Assign_Membership_ID__c, Design_Concierge_Services__c, Designer_ID__c, DTP_Card_Exp_Date_CLN__c, Membership_ID_Formula__c FROM Contact WHERE ((Account_Membership_Level_Last_Changed__c >= ' + yesterday + ' OR DTP_Card_Exp_Date_CLN__c = ' + yesterday + ') AND ID_Formula_Equals_ID__c = \'No\') OR Account_Expiration_Last_Changed__c >= ' + yesterday);
        database.executebatch(pc);
    }
}