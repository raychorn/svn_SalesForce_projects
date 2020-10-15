public with sharing class ContactUs_Controller
{
    // Test passes
    private Boolean isTesting = false;
    public class IsTestingException extends Exception {}

    public User currentUser {get; set;}

    public String phoneType {get; set;}
    
    public ContactUs_Controller(Boolean isTest)
    {
        isTesting = true;
        fc();
    }   
    public ContactUs_Controller()
    {
        fc();
    }
    private void fc()
    {
        currentUser = getCurrentUser();
        phoneType = '';
        if ( (currentUser.Phone != null) && (currentUser.Phone.length() > 0) ) {
            if (currentUser.Phone.startsWith('8')) {
                phoneType = 'US Toll Free';
            } else {
                phoneType = 'Outside the US';
            }
        }
    }
    
    private User getCurrentUser()
    {
        return [SELECT Id, Email, Phone, Fax, MobilePhone, Street, State, PostalCode, Country, City, Account_Level_Expire__c, 
            Account_Level__c, Hierarchy_TTM_Sales__c, Designer_Id__c, eComm_Pswd__c, DTP_Card_Exp_Date_CLN__c, 
            CreatedDate, FirstName, LastName, CompanyName, Title FROM User 
            WHERE Id = :UserInfo.getUserId()];
    }
    
    public PageReference printTemporaryIDCardPDF()
    {
        PageReference retVal = Page.PrintTemporaryIDCard;
        retVal.getParameters().put('renderas', 'pdf');
        return retVal;
    }

    public PageReference modifyAccountInformation()
    {
        PageReference retVal = Page.ModifyAccountInformation;
        return retVal;
    }

    public PageReference cancel()
    {
      return Page.PortalMain;
    }
    
    public PageReference returnToWSI()
    {
        return new PageReference('http://www.wsidesignermarketplace.com');
    }

}