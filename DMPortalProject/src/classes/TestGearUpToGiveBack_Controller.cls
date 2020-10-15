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
private class TestGearUpToGiveBack_Controller 
{
    static testMethod void testConstructor() 
    {
		// Setup test environment
		Test.setCurrentPage(Page.GearUpToGiveBack);
        GearUpToGiveBack_Controller gutgb = new GearUpToGiveBack_Controller();
        gutgb.searchString = 'ac';
        gutgb.searchSchools();
        gutgb.clickedLetter();
    }
    
    static testMethod void testWithData()
    {
    	Account a = new Account();
    	a.Program_Type__c = 'School Rewards';
    	a.Name = 'test';
    	insert a;
    	Contact c = new Contact(LastName = 'test');
    	c.AccountId = a.Id;
    	c.Designer_ID__c = '777';
    	insert c;
    	
		// Setup test environment
		Test.setCurrentPage(Page.GearUpToGiveBack);
        GearUpToGiveBack_Controller gutgb = new GearUpToGiveBack_Controller();
        gutgb.searchString = 'te*';
        gutgb.searchSchools();
		ApexPages.currentPage().getParameters().put('letter', 't');
        gutgb.clickedLetter();
    }
}