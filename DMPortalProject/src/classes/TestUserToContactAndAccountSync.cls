/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestUserToContactAndAccountSync 
{
    static testMethod void testWithExistingUser()
    {
    	User[] u1 = [SELECT Id, ContactId, AccountId, Email, Phone, MobilePhone, Street, State, PostalCode, Country, City 
    		FROM User u WHERE ContactId != null AND AccountId != null limit 1];
    		
    	if(u1.size() > 0 && u1[0].ContactId != null && u1[0].AccountId != null)
    	{
    		// Modify User record
			u1[0].Email = 'TEST@TEST.COM';
			u1[0].Phone = '333-777-9393';
			u1[0].MobilePhone = '333-777-9393';
			u1[0].Street = 'TEST';
			u1[0].State = 'TEST';
			u1[0].PostalCode = 'TEST';
			u1[0].Country = 'TEST';
			u1[0].City = 'TEST';
			update u1;
    		
			// Verify changes to User
	    	User u2 = [SELECT Email, Phone, MobilePhone, Street, State, PostalCode, Country, City FROM User u WHERE Id = :u1[0].Id limit 1];
	    	system.assert(u2.Email == 'TEST@TEST.COM');
	    	system.assert(u2.Phone == '333-777-9393');
	    	system.assert(u2.MobilePhone == '333-777-9393');
	    	system.assert(u2.Street == 'TEST');
	    	system.assert(u2.State == 'TEST');
	    	system.assert(u2.PostalCode == 'TEST');
	    	system.assert(u2.Country == 'TEST');
	    	system.assert(u2.City == 'TEST');

			// Verify trigger has made appropriate changes to associated Contact record  
    		Contact c = [SELECT Email, Phone, MobilePhone FROM Contact WHERE Id = :u1[0].ContactId limit 1];
	    	system.assert(c.Email == 'TEST@TEST.COM');
	    	system.assert(c.Phone == '333-777-9393');
	    	system.assert(c.MobilePhone == '333-777-9393');
	    	
			// Verify trigger has made appropriate changes to associated Account record
			Account a = [SELECT Id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity 
				FROM Account WHERE Id = :u1[0].AccountId limit 1]; 
	    	system.assert(a.BillingStreet == 'TEST');
	    	system.assert(a.BillingState == 'TEST');
	    	system.assert(a.BillingPostalCode == 'TEST');
	    	system.assert(a.BillingCountry == 'TEST');
	    	system.assert(a.BillingCity == 'TEST');
    	}
    }

    static testMethod void testWithNewUser()
    {
    	Profile p = [select id from profile where name='Standard User'];
		User u1 = new User(alias = 'standt', email='standarduser@wsi-testorg.com', emailencodingkey='UTF-8', lastname='Testing', 
			languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', username='standarduser@wsi-testorg.com');
		
		insert u1;
    		
    	if(u1 != null && u1.ContactId != null && u1.AccountId != null)
    	{
    		// Modify User record
			u1.Email = 'TEST@TEST.COM';
			u1.Phone = '333-777-9393';
			u1.MobilePhone = '333-777-9393';
			u1.Street = 'TEST';
			u1.State = 'TEST';
			u1.PostalCode = 'TEST';
			u1.Country = 'TEST';
			u1.City = 'TEST';
			update u1;
    		
			// Verify changes to User
	    	User u2 = [SELECT Email, Phone, MobilePhone, Street, State, PostalCode, Country, City FROM User u WHERE Id = :u1.Id limit 1];
	    	system.assert(u2.Email == 'TEST@TEST.COM');
	    	system.assert(u2.Phone == '333-777-9393');
	    	system.assert(u2.MobilePhone == '333-777-9393');
	    	system.assert(u2.Street == 'TEST');
	    	system.assert(u2.State == 'TEST');
	    	system.assert(u2.PostalCode == 'TEST');
	    	system.assert(u2.Country == 'TEST');
	    	system.assert(u2.City == 'TEST');

			// Verify trigger has made appropriate changes to associated Contact record  
    		Contact c = [SELECT Email, Phone, MobilePhone FROM Contact WHERE Id = :u1.ContactId limit 1];
	    	system.assert(c.Email == 'TEST@TEST.COM');
	    	system.assert(c.Phone == '333-777-9393');
	    	system.assert(c.MobilePhone == '333-777-9393');
	    	
			// Verify trigger has made appropriate changes to associated Account record
			Account a = [SELECT Id, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity 
				FROM Account WHERE Id = :u1.AccountId limit 1]; 
	    	system.assert(a.BillingStreet == 'TEST');
	    	system.assert(a.BillingState == 'TEST');
	    	system.assert(a.BillingPostalCode == 'TEST');
	    	system.assert(a.BillingCountry == 'TEST');
	    	system.assert(a.BillingCity == 'TEST');
    	}
    }
}