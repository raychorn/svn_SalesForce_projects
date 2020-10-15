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
private class TestPortalMain_Controller 
{
    static testMethod void testConstructor() 
    {
		// Setup test environment
		Test.setCurrentPage(Page.PortalMain);
        PortalMain_Controller pm = new PortalMain_Controller();
    }
    
    static testMethod void testMethods() 
    {
		Test.setCurrentPage(Page.PortalMain);
        PortalMain_Controller pm = new PortalMain_Controller();
        pm.extendMembership();
        pm.modifyAccountInformation();
        pm.printTemporaryIDCardPDF();
        pm.returnToWSI();
    }
	
	static testMethod void testMethods2()
	{
		Test.setCurrentPage(Page.PortalMain);
        PortalMain_Controller pm = new PortalMain_Controller();
        
        // When DTP_Card_Exp_Date_CLN__c = null, getIsExpiring() returns false
        pm.currentUser.DTP_Card_Exp_Date_CLN__c = null;
        system.assert(pm.getIsExpiring() == false);
	}

	static testMethod void testMethodsIsTestingTrue()
	{
		Test.setCurrentPage(Page.PortalMain);
        PortalMain_Controller pm = new PortalMain_Controller(true);
        
        pm.extendMembership();
	}
}