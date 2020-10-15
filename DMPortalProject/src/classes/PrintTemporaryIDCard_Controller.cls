/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This class supports the PDF version of a user's temporary ID card   */
/*  for printing from their browser.                                    */
/*                                                                      */
/*----------------------------------------------------------------------*/

public with sharing class PrintTemporaryIDCard_Controller 
{
	public User currentUser {get; set;}
	public String renderAs {get; private set;}

	public String status {get; set;}

	public String level {get; set;}
	
	public PrintTemporaryIDCard_Controller()
	{
		currentUser = [SELECT Id, Email, Phone, MobilePhone, Street, State, PostalCode, Country, City, Account_Level_Expire__c, 
			Account_Level__c, Hierarchy_TTM_Sales__c, Designer_Id__c, eComm_Pswd__c, DTP_Card_Exp_Date_CLN__c, 
			CreatedDate, FirstName, LastName FROM User 
			WHERE Id = :UserInfo.getUserId()];
			
		level = currentUser.Account_Level__c;
		status = 'Account_Level__c=('+currentUser.Account_Level__c+')';

		this.renderAs = ApexPages.currentPage().getParameters().get('renderas');
	}
	
}