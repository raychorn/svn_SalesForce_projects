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
private class TestContactToUserSync 
{
    static testMethod void testWithExistingUser()
    {
    	User[] u1 = [SELECT Id, ContactId, Designer_Id__c, PostalCode, DTP_Card_Exp_Date_CLN__c FROM User u WHERE ContactId != null limit 1];
    		
    	if(u1.size() > 0)
    	{
    		Contact c = [SELECT Designer_Id__c, eComm_Pswd__c, MailingPostalCode, DTP_Card_Exp_Date_CLN__c FROM Contact 
    			WHERE Id = :u1[0].ContactId limit 1];

			c.Designer_Id__c = 'TEST';
			c.MailingPostalCode = 'TEST';
			c.DTP_Card_Exp_Date_CLN__c = Date.today();

			update c;
			
	    	User[] u2 = [SELECT Designer_Id__c, PostalCode, DTP_Card_Exp_Date_CLN__c FROM User u WHERE Id = :u1[0].Id limit 1];
	    	
	    	system.assert(u2[0].Designer_Id__c == 'TEST');
	    	system.assert(u2[0].PostalCode == 'TEST');
	    	system.assert(u2[0].DTP_Card_Exp_Date_CLN__c == Date.today());
    	}
    }
}