/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This trigger synchronizes changed data from Contact to User         */
/*  on specific fields                                                  */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger ContactToUserSync on Contact (after update, after insert) 
{
	if(!UserSyncHelper.userTriggerIsInProcess())
	{
		UserSyncHelper.setContactTriggerInProcess();

		// Generate Contact Id list
		List<Id> cIdList = new List<Id>();
		for(Contact c : Trigger.new)
			cIdList.add(c.Id);
		
		// Generate matching User list and subset list for targeted updating
		List<User> userList = [SELECT Id, DTP_Card_Exp_Date_CLN__c, ContactId, PostalCode, Designer_Id__c, eComm_Pswd__c FROM User WHERE ContactId IN :cIdList];
		List<User> tmpU = new List<User>();
		
		// Produce list with changed records only
		for(User u : userList)
		{
			Contact c = Trigger.newMap.get(u.ContactId);

			if(c != null)
			{
				if((u.Designer_Id__c != c.Designer_Id__c) || (u.eComm_Pswd__c != c.eComm_Pswd__c) || (u.PostalCode != c.MailingPostalCode) || 
					(u.DTP_Card_Exp_Date_CLN__c != c.DTP_Card_Exp_Date_CLN__c))
				{
					u.Designer_Id__c = c.Designer_Id__c;
					u.eComm_Pswd__c = c.eComm_Pswd__c; 
					u.PostalCode = c.MailingPostalCode;
					u.DTP_Card_Exp_Date_CLN__c = c.DTP_Card_Exp_Date_CLN__c;
					
					tmpU.add(u);
				}
			}
		}
		
		// Update the subset list
		update tmpU;
	}
}