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
private class TestAccountToUserSync 
{
    static testMethod void testWithExistingUser()
    {
    	User[] u1 = [SELECT Id, AccountId, Account_Level_Expire__c, Account_Level__c, Hierarchy_TTM_Sales__c FROM User u 
    		WHERE AccountId != null limit 1];
    		
    	if(u1.size() > 0)
    	{
    		Account a = [SELECT Account_Level_Expire__c, Account_Level__c, Hierarchy_TTM_Sales__c FROM Account WHERE Id = :u1[0].AccountId limit 1];

			a.Account_Level_Expire__c = Date.today();
			a.Account_Level__c = 'Gold';
			a.Hierarchy_TTM_Sales__c = 333.93;

			update a;

			// Make sure Account 'a' has expected changes			
    		a = [SELECT Account_Level_Expire__c, Account_Level__c, Hierarchy_TTM_Sales__c FROM Account WHERE Id = :u1[0].AccountId limit 1];
	    	system.assert(a.Account_Level_Expire__c == Date.today());
	    	system.assert(a.Account_Level__c == 'Gold');
	    	system.assert(a.Hierarchy_TTM_Sales__c == 333.93);
			
			// Now verify trigger has modified User appropriately
	    	User[] u2 = [SELECT Account_Level_Expire__c, Account_Level__c, Hierarchy_TTM_Sales__c FROM User u WHERE Id = :u1[0].Id limit 1];
	    	system.assert(u2[0].Account_Level_Expire__c == Date.today());
	    	system.assert(u2[0].Account_Level__c == 'Gold');
	    	system.assert(u2[0].Hierarchy_TTM_Sales__c == 333.93);
    	}
    }
}