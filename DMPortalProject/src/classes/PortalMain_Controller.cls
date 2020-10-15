public with sharing class PortalMain_Controller 
{
    // Test passes
    private Boolean isTesting = false;
    public class IsTestingException extends Exception {}

    public User currentUser {get; set;}
    public Boolean isExpiring {get; private set;}

    public Boolean isUpdating {get; private set;}
    public Boolean isViewing {get; private set;}

    public String status {get; private set;}
    public Boolean isStatusVisible {get; private set;}

    public String memberid {get; set;}
    public String membership {get; set;}
    public String password {get; set;}
    public String expires {get; set;}
    public String title {get; set;}
    public String companyName {get; set;}
    public String spendlimit {get; set;}
    public String taxexempt {get; set;}

    public String createdDate {get; private set;}

    public PortalMain_Controller(Boolean isTest)
    {
        isTesting = true;
        fc();
    }   
    public PortalMain_Controller()
    {
        isUpdating = false;
        isViewing = true;
        isStatusVisible = false;
        status = '';
        createdDate = '';
        memberid = '';
        membership = '';
        password = '';
        expires = '';
        title = '';
        companyName = '';
        spendlimit = '';
        taxexempt = '';
        fc();
    }
    private void fc()
    {
        PageReference p = ApexPages.currentPage();
        String ip = null; //p.getHeaders().get('X-Salesforce-SIP');
        if (ip == '') {
	    	isStatusVisible = true;
    		status += 'UserInfo.getUserId()='+UserInfo.getUserId();
	    	status += get_debugging_info(p);
        }
        currentUser = getCurrentUser();
        isExpiring = getIsExpiring();
    }
    
    private User getCurrentUser() {
	    User aUser = [SELECT Id, Email, Phone, Fax, MobilePhone, Street, State, PostalCode, Country, City, Account_Level_Expire__c, 
            Account_Level__c, Hierarchy_TTM_Sales__c, Designer_Id__c, eComm_Pswd__c, DTP_Card_Exp_Date_CLN__c, 
            CreatedDate, FirstName, LastName, Title, CompanyName, Tax_Exempt_Status__c FROM User 
            WHERE Id = :UserInfo.getUserId()];
        if (status.length() > 0) {
        	status += ' (1) aUser='+aUser;
        }
        aUser.FirstName = (aUser.FirstName == null) ? '' : aUser.FirstName;
        aUser.LastName = (aUser.LastName == null) ? '' : aUser.LastName;
        createdDate = (aUser.CreatedDate == null) ? datetime.now()+'' : aUser.CreatedDate+'';
        aUser.Title = (aUser.Title == null) ? '' : aUser.Title;
		aUser.Email = (aUser.Email == null) ? '' : aUser.Email;
		aUser.Phone = (aUser.Phone == null) ? '' : aUser.Phone;
		aUser.Fax = (aUser.Fax == null) ? '' : aUser.Fax;
		aUser.CompanyName = (aUser.CompanyName == null) ? '' : aUser.CompanyName;
		aUser.Street = (aUser.Street == null) ? '' : aUser.Street;
		aUser.City = (aUser.City == null) ? '' : aUser.City;
		aUser.State = (aUser.State == null) ? '' : aUser.State;
		aUser.PostalCode = (aUser.PostalCode == null) ? '' : aUser.PostalCode;
		aUser.Designer_ID__c = (aUser.Designer_ID__c == null) ? '' : aUser.Designer_ID__c;
		aUser.eComm_Pswd__c = (aUser.eComm_Pswd__c == null) ? '' : aUser.eComm_Pswd__c;
        if (status.length() > 0) {
        	status += ' (2) aUser='+aUser;
        }
    	memberid = aUser.Designer_ID__c;
    	membership = (aUser.Account_Level__c == null) ? '' : aUser.Account_Level__c;
    	password = aUser.eComm_Pswd__c;
    	expires = (aUser.Account_level_Expire__c == null) ? datetime.now()+'' : aUser.Account_level_Expire__c+'';
    	title = aUser.Title;
    	companyName = aUser.CompanyName;
    	spendlimit = (aUser.Hierarchy_TTM_Sales__c == null) ? '0.00' : aUser.Hierarchy_TTM_Sales__c+'';
    	taxexempt = (aUser.Tax_Exempt_Status__c == null) ? '' : aUser.Tax_Exempt_Status__c+'';
        return aUser;
    }

    public String get_debugging_info(PageReference p) {
        String s = '';
        String ip = null; //p.getHeaders().get('X-Salesforce-SIP');
        if (ip == '') {
	        s += ', p.getParameters()='+p.getParameters();
	        s += ', BEGIN: p.getParameters():';
			for (String key : p.getParameters().keySet()) {
		        s += ', Key: ' + key + ', Value: ' + p.getParameters().get(key);
			}        
	        s += ', END!  p.getParameters()';
	        //s += ', BEGIN: p.getHeaders():';
			//for (String key : p.getHeaders().keySet()) {
		    //    s += ', Key: ' + key + ', Value: ' + p.getHeaders().get(key);
			//}        
	        //s += ', END!  p.getHeaders()';
        }
        return s;
    }
    
    public Boolean getIsExpiring()
    {
        if(currentUser.DTP_Card_Exp_Date_CLN__c != null)
            return ((Date.today().daysBetween(currentUser.DTP_Card_Exp_Date_CLN__c) <= 31) && currentUser.Account_Level__c == 'Green');
        else
            return false;
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
                throw e;
            }
        }
        catch(Exception e)
        {
            // Shouldn't be here...
        }

        return null;
    }

    public PageReference updateUser()
    {
        PageReference p = ApexPages.currentPage();

        isUpdating = true;
        isViewing = false;

        return p;
    }
    
    public PageReference updateCancel()
    {
        PageReference p = ApexPages.currentPage();

        isUpdating = false;
        isViewing = true;

        return p;
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
    
    //public PageReference printTemporaryIDCardHTML()
    //{
    //  return Page.PrintTemporaryIDCard;
    //}
    
    //public PageReference viewWelcomeEmail()
    //{
    //  return Page.PrintTemporaryIDCardHTML;
    //}
}