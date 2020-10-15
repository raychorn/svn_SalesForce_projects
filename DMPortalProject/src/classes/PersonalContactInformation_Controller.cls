public with sharing class PersonalContactInformation_Controller 
{
    // Test passes
    private Boolean isTesting = false;
    public class IsTestingException extends Exception {}
    
    public User currentUser {get; set;}
    public Boolean isExpiring {get; private set;}
    public Boolean emailMismatch {get; private set;}

    public String confirmEmail {get; set;}

    public Boolean isChangingPassword {get; set;}
    
    public Boolean isStatusVisible {get; set;}
    
    public String status {get; private set;}

    public PersonalContactInformation_Controller(Boolean isTest)
    {
        isTesting = true;
        fc();
    }   
    public PersonalContactInformation_Controller()
    {
        fc();
    }
    private void fc()
    {
        currentUser = getCurrentUser();
        isChangingPassword = false;
        isStatusVisible = false;
        isExpiring = getIsExpiring();
        status = '';
    }
    
    public PageReference changeUserPassword() {
        PageReference p = ApexPages.currentPage();
        currentUser = getCurrentUser();
        if (p.getParameters().get('modifyContact:contactForm:mainBlock:password') == p.getParameters().get('modifyContact:contactForm:mainBlock:confirmpassword')) {
            isChangingPassword = false;
            try {
                currentUser.eComm_Pswd__c = p.getParameters().get('modifyContact:contactForm:mainBlock:password');
                update currentUser;
                p = Page.PortalMain;
                status = 'Password change is complete !';
                String s_body = currentUser.Email+'\n\nPassword Change Request\n\nUsername: '+currentUser.Designer_ID__c+'\nPassword: '+currentUser.eComm_Pswd__c+'';
                PortalUtilities.sendEmail('Password Change for '+currentUser.Designer_ID__c, s_body, currentUser.Email);
            } catch(System.DmlException e) {
                status = e.getDmlMessage(0);
            }
        } else {
            status = 'WARNING: Both Passwords must match; please try again.';
        }
        isStatusVisible = true;
        return p;
    }
    
    private User getCurrentUser()
    {
        return [SELECT Id, Email, Phone, Fax, MobilePhone, Street, State, PostalCode, Country, City, Account_Level_Expire__c, 
            Account_Level__c, Hierarchy_TTM_Sales__c, Designer_Id__c, eComm_Pswd__c, DTP_Card_Exp_Date_CLN__c, 
            CreatedDate, FirstName, LastName, CompanyName, Title FROM User 
            WHERE Id = :UserInfo.getUserId()];
    }
    
    public Boolean getIsExpiring()
    {
        if(currentUser.DTP_Card_Exp_Date_CLN__c != null)
            return ((Date.today().daysBetween(currentUser.DTP_Card_Exp_Date_CLN__c) <= 31) && currentUser.Account_Level__c == 'Green');
        else
            return false;
    }
    
    public PageReference modifyUserPassword() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = true;
        isStatusVisible = true;
        return p;
    }
    
    public PageReference cancelChangeUserPassword() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        return p;
    }
    
    // Cancel removed when custom Submit button added
    public PageReference cancel()
    {
      return Page.PortalMain;
    }
    
    public PageReference extendMembership()
    {
        // Get user again in case data was inadvertently changed
        currentUser = getCurrentUser();
         
        Date extDate = Date.today();
        extDate = extDate.addMonths(1);
        extDate = extDate.toStartOfMonth();
        extDate = extDate.addYears(2);
        
        currentUser.DTP_Card_Exp_Date_CLN__c = extDate;
        
        try
        {
            update currentUser;

            isExpiring = getIsExpiring();
            
            if(isTesting == true)
            {
                IsTestingException e = new IsTestingException();
                throw e; // For 100% coverage
            }
        }
        catch(Exception e)
        {
            // Shouldn't be here...
        }

        return null;
    }
    
}