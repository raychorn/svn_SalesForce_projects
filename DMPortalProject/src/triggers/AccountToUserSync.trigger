/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This trigger synchronizes changed data from Account to User         */
/*  on specific fields                                                  */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger AccountToUserSync on Account (after update, after insert) 
{
    if(!UserSyncHelper.userTriggerIsInProcess())
    {
        UserSyncHelper.setContactTriggerInProcess(); // Contact here means the NOT user trigger, which is Account in this case

        // Generate Account Id list
        List<Id> aIdList = new List<Id>();
        for(Account a : Trigger.new)
            aIdList.add(a.Id);
        
        // Generate matching User list and subset list for targeted updating
        List<User> userList = [SELECT Id, AccountId, Account_Level_Expire__c, Account_Level__c, Hierarchy_TTM_Sales__c 
            FROM User WHERE AccountId IN :aIdList];
        List<User> tmpU = new List<User>();
        
        // Produce list with changed records only
        for(User u : userList)
        {
            Account a = Trigger.newMap.get(u.AccountId);

            if(a != null)
            {
                if((u.Account_Level_Expire__c != a.Account_Level_Expire__c) || (u.Account_Level__c != a.Account_Level__c) || 
                    (u.Hierarchy_TTM_Sales__c != a.Hierarchy_TTM_Sales__c))
                {
                    u.Account_Level_Expire__c = a.Account_Level_Expire__c;
                    u.Account_Level__c = a.Account_Level__c;
                    u.Hierarchy_TTM_Sales__c = a.Hierarchy_TTM_Sales__c;
                    
                    u.Tax_Exempt_Status__c = a.Tax_Exempt_Status__c;
                    
                    
                    tmpU.add(u);
                }
            }
        }
        
        // Update the subset list
        update tmpU;
    }
}