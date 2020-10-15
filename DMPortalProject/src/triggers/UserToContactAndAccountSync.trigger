/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This trigger synchronizes changed data from User to Contact         */
/*  and Account on specific fields                                      */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger UserToContactAndAccountSync on User (after insert, after update) 
{
    if(!UserSyncHelper.contactTriggerIsInProcess())
    {
        UserSyncHelper.setUserTriggerInProcess();
        
        // If after update, move changes to contact and account.
        // If after insert, move data from contact IF matching contact exists 
        if(Trigger.isAfter && Trigger.isInsert)
        {
            // Create copy of user objects so we can apply any changes
            List<User> userList = Trigger.new.deepClone(true);
            
            // Generate User.ContactId & User.AccountId lists
            List<Id> uCIdList = new List<Id>();
            List<Id> uAIdList = new List<Id>();
            for(User u : userList)
            {
                if(u.ContactId != null)
                    uCIdList.add(u.ContactId);
                if(u.AccountId != null)
                    uAIdList.add(u.AccountId);
            }
            
            // Generate matching Contact & Account lists 
            List<Contact> contactList = [SELECT Id, Email, Phone, MobilePhone, Designer_ID__c, eComm_Pswd__c, DTP_Card_Exp_Date_CLN__c 
                FROM Contact WHERE Id IN :uCIdList];
            List<Account> accountList = [SELECT Id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity, Account_Level__c 
                FROM Account WHERE Id IN :uAIdList];
    
            // Generate Contact and Account maps from contactList and accountList
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            Map<Id, Account> accountMap = new Map<Id, Account>();
            for(Contact c : contactList)
                contactMap.put(c.Id, c);
            for(Account a : accountList)
                accountMap.put(a.Id, a);
    
            for(User u : userList)
            {
                Contact c = contactMap.get(u.ContactId);
                Account a = accountMap.get(u.AccountId);
    
                if(c != null)
                {
                    if(c.Phone != null)
                        u.Phone = c.Phone;
                    if(c.MobilePhone != null)
                        u.MobilePhone = c.MobilePhone;
                    if(c.Designer_ID__c != null)
                        u.Designer_ID__c = c.Designer_ID__c;
                    if(c.eComm_Pswd__c != null)
                        u.eComm_Pswd__c = c.eComm_Pswd__c;
                    if(c.DTP_Card_Exp_Date_CLN__c != null)
                        u.DTP_Card_Exp_Date_CLN__c = c.DTP_Card_Exp_Date_CLN__c;
                }
    
                if(a != null)
                {
                    if(a.BillingStreet != null)
                        u.Street = a.BillingStreet;
                    if(a.BillingState != null)
                        u.State = a.BillingState;
                    if(a.BillingPostalCode != null)
                        u.PostalCode = a.BillingPostalCode;
                    if(a.BillingCountry != null)
                        u.Country = a.BillingCountry;
                    if(a.BillingCity != null)
                        u.City = a.BillingCity;
                    if(a.Account_Level__c != null)
                        u.Account_Level__c = a.Account_Level__c;
                    if (a.Tax_Exempt_Status__c != null)
                        u.Tax_Exempt_Status__c = a.Tax_Exempt_Status__c;
                }
            }
            
            // Update the cloned user list
            update userList;
        }
        else if(Trigger.isAfter && Trigger.isUpdate)
        {
            // Generate User.ContactId & User.AccountId lists
            List<Id> uCIdList = new List<Id>();
            List<Id> uAIdList = new List<Id>();
            for(User u : Trigger.new)
            {
                if(u.ContactId != null)
                    uCIdList.add(u.ContactId);
                if(u.AccountId != null)
                    uAIdList.add(u.AccountId);
            }
            
            // Generate matching Contact & Account lists 
            List<Contact> contactList = [SELECT Id, Email, Phone, MobilePhone FROM Contact WHERE Id IN :uCIdList];
            List<Account> accountList = [SELECT Id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity 
                FROM Account WHERE Id IN :uAIdList];
    
            // Generate Contact and Account maps from contactList and accountList
            Map<Id, Contact> contactMap = new Map<Id, Contact>();
            Map<Id, Account> accountMap = new Map<Id, Account>();
            for(Contact c : contactList)
                contactMap.put(c.Id, c);
            for(Account a : accountList)
                accountMap.put(a.Id, a);
    
            // Create Contact and Account lists with changes only
            List<Contact> tmpC = new List<Contact>();
            List<Account> tmpA = new List<Account>();
            
            for(User u : Trigger.new)
            {
                Contact c = contactMap.get(u.ContactId);
                Account a = accountMap.get(u.AccountId);
    
                if(c != null)
                {
                    // Only add Contact if any of these fields have changed             
                    if((c.Email != u.Email) || (c.Phone != u.Phone) || (c.MobilePhone != u.MobilePhone))
                    {
                        c.Email = u.Email;
                        c.Phone = u.Phone;
                        c.MobilePhone = u.MobilePhone;
                        
                        tmpC.add(c);
                    }
                }
    
                if(a != null)
                {
                    // Only add Account if any of these fields have changed             
                    if((a.BillingStreet != u.Street) || (a.BillingState != u.State) || (a.BillingPostalCode != u.PostalCode) || 
                        (a.BillingCountry != u.Country) || (a.BillingCity != u.City))
                    {
                        a.BillingStreet = u.Street;
                        a.BillingState = u.State;
                        a.BillingPostalCode = u.PostalCode;
                        a.BillingCountry = u.Country;
                        a.BillingCity = u.City;
                        
                        tmpA.add(a);
                    }
                }
            }
            
            // Update the subset lists
            update tmpC;
            update tmpA;
        }
    }
}