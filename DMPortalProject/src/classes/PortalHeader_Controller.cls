public with sharing class PortalHeader_Controller
{
    // Test passes
    private Boolean isTesting = false;
    public class IsTestingException extends Exception {}

    public PageReference currentPage {get; set;}

    public String status {get; set;}
    
    public Boolean IsModifyAccountInformationPage {get; set;}
    public Boolean IsContactUsPage {get; set;}
    public Boolean IsTemporaryIDPage {get; set;}

    public PortalHeader_Controller(Boolean isTest)
    {
        isTesting = true;
        fc();
    }   
    public PortalHeader_Controller()
    {
        fc();
    }
    private void fc()
    {
        currentPage = ApexPages.currentPage();
        status = ''; //'DEBUG: currentPage.Url='+currentPage.getUrl();
        IsModifyAccountInformationPage = currentPage.getUrl().indexOf('/apex/modifyaccountinformation') > -1;
        IsContactUsPage = currentPage.getUrl().indexOf('/apex/contactus') > -1;
        IsTemporaryIDPage = currentPage.getUrl().indexOf('/apex/printtemporaryidcard') > -1;
    }
    
    public PageReference contactUs()
    {
        PageReference retVal = Page.ContactUs;
        return retVal;
    }

    public PageReference printTemporaryIDCardPDF()
    {
        PageReference retVal = Page.PrintTemporaryIDCard;
        //retVal.getParameters().put('renderas', 'pdf');
        return retVal;
    }

    public PageReference modifyAccountInformation()
    {
        PageReference retVal = Page.ModifyAccountInformation;
        return retVal;
    }

    public PageReference returnToWSI()
    {
        return new PageReference('http://www.wsidesignermarketplace.com');
    }

}