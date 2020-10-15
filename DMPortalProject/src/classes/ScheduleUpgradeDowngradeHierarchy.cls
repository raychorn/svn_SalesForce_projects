/*---------------------------------------------------------------------*/
/*                                                                     */
/*  This batch class schedules the batch Apex to flag Accounts that    */
/*  potentially need to be downgraded on their expiration date.        */
/*                                                                     */
/*---------------------------------------------------------------------*/

global class ScheduleUpgradeDowngradeHierarchy implements Schedulable {

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
        
        upgradeDowngradeHierarchy uDH = new upgradeDowngradeHierarchy('SELECT Id, Account_Level__c, Account_level_Expire__c, Account_Level_Last_Evaluated__c, Automatic_Upgrade_Downgrade__c, Hierarchy_TTM_Sales__c FROM Account WHERE Program_Type__c = \'DTP\' AND ParentId = \'\' AND (Account_level_Expire__c = ' + yesterday + ' OR Account_Level_Last_Evaluated__c = null) AND (Account_Level__c <> \'' + level + '\' OR (Account_Level__c = \'' + level + '\' AND Account_Level_Last_Evaluated__c = null))');
        database.executebatch(uDH);
    }
}