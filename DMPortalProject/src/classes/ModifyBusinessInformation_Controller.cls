public with sharing class ModifyBusinessInformation_Controller 
{
    // Test passes
    private Boolean isTesting = false;
    public class IsTestingException extends Exception {}
    
    public User currentUser {get; set;}
    public Boolean errorsOnPage {get; private set;}
    public String errorMessage {get; private set;}

    public Boolean isChangingPassword {get; set;}
    
    public Boolean isStatusVisible {get; set;}
    
    public Boolean isViewingLocation {get; set;}
    public Boolean isEditingLocation {get; set;}

    public String status {get; private set;}

    public ModifyBusinessInformation_Controller(Boolean isTest)
    {
        isTesting = true;
        fc();
    }   
    public ModifyBusinessInformation_Controller()
    {
        fc();
    }
    private void fc()
    {
        currentUser = getCurrentUser();
        isChangingPassword = false;
        isViewingLocation = true;
        isEditingLocation = false;
        isStatusVisible = false;
        errorsOnPage = false; // Turns true when update fails
        errorMessage = '';
        status = '';
    }
    
    private User getCurrentUser()
    {
        return [SELECT Id, Email, Phone, Fax, MobilePhone, Street, State, PostalCode, Country, City, Account_Level_Expire__c, 
            Account_Level__c, Hierarchy_TTM_Sales__c, Designer_Id__c, eComm_Pswd__c, DTP_Card_Exp_Date_CLN__c, 
            CreatedDate, FirstName, LastName, CompanyName, Title FROM User 
            WHERE Id = :UserInfo.getUserId()];
    }
    
    public PageReference addAdditionalLocation() {
        PageReference p = ApexPages.currentPage();
        return p;
    }
    
    public PageReference changeCurrentLocation() {
        PageReference p = ApexPages.currentPage();
        isViewingLocation = false;
        isEditingLocation = true;
        return p;
    }
    
    public PageReference cancelChangeCurrentLocation() {
        PageReference p = ApexPages.currentPage();
        isViewingLocation = true;
        isEditingLocation = false;
        return p;
    }
    
    public PageReference save() {
        PageReference p = ApexPages.currentPage();
        PageReference retVal;
        errorsOnPage = false;
        
        currentUser = getCurrentUser();
        if(p.getParameters().get('modifyBusiness:accountForm:mainBlock:email') == p.getParameters().get('modifyBusiness:accountForm:mainBlock:confirmEmail')) {
            try {
                currentUser.FirstName = p.getParameters().get('modifyBusiness:accountForm:mainBlock:firstname');
                currentUser.LastName = p.getParameters().get('modifyBusiness:accountForm:mainBlock:lastname');
                currentUser.Phone = p.getParameters().get('modifyBusiness:accountForm:mainBlock:phone');
                currentUser.Fax = p.getParameters().get('modifyBusiness:accountForm:mainBlock:fax');
                currentUser.Email = p.getParameters().get('modifyBusiness:accountForm:mainBlock:email');
                update currentUser;
                retVal = Page.PortalMain;
            } catch(System.DmlException e) {
                // Exceptions on Update
                errorMessage = e.getDmlMessage(0);
                errorsOnPage = true;
            }
        } else {
            errorsOnPage = true;
            status = 'WARNING: Both email addresses must match before any changes can be made.';
        }

        isStatusVisible = true;
        return retVal;
    }
    
    // Cancel removed when custom Submit button added
    public PageReference cancel()
    {
      return Page.PortalMain;
    }
    
}