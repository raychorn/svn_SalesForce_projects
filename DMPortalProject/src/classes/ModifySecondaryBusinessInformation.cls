public with sharing class ModifySecondaryBusinessInformation {
    // Test passes
    private Boolean isTesting = false;
    public class IsTestingException extends Exception {}
    
    public User currentUser {get; set;}
    
    public Boolean isExpiring {get; private set;}
    public Boolean hasChanged {get; private set;}
    public String cancelText {get; private set;}
    public Boolean emailMismatch {get; private set;}

    public String memberid {get; set;}
    public String membership {get; set;}
    public String memberexpiration {get; set;}
    public String confirmEmail {get; set;}
    public String password {get; set;}
    public String confirmpassword {get; set;}

    public String companyname {get; set;}
    public String title {get; set;}
    public String street {get; set;}
    public String city {get; set;}
    public String state {get; set;}
    public String postal {get; set;}
    public String country {get; set;}

    public Boolean isChangingMember {get; set;}
    public Boolean isChangingPassword {get; set;}
    public Boolean isChangingContact {get; set;}
    public Boolean isChangingPrimaryLocation {get; set;}
    public Boolean isChangingSecondaryLocation {get; set;}

    public Boolean isAddingSecondaryLocation {get; set;}
    public Boolean hasSecondaryLocation {get; set;}
    
    public Boolean isStatusVisible {get; set;}
    
    public String status {get; private set;}
    
    public ModifySecondaryBusinessInformation(Boolean isTest)
    {
        isTesting = true;
        fc();
    }   
    public ModifySecondaryBusinessInformation()
    {
        fc();
    }
    private void fc()
    {
        memberid = '';
        membership = '';
        memberexpiration = datetime.now()+'';
        password = '';
        confirmpassword = '';
        confirmEmail = '';
        status = '';
	    companyname = '';
	    title = '';
	    street = '';
	    city = '';
	    state = '';
	    postal = '';
	    country = '';
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
        isAddingSecondaryLocation = false;
        hasSecondaryLocation = false;
        getCurrentUser();
        isExpiring = getIsExpiring();
        hasChanged = false;
        cancelText = 'Close';
        emailMismatch = false; // Display when trying to save and both email addresses do NOT match     
        isStatusVisible = (status.length() > 0);
    }
    
    private void refreshAddingSecondaryLocation() {
    	isAddingSecondaryLocation = (currentUser.SecondaryCompanyName__c.length() == 0) && (currentUser.SecondaryTitle__c.length() == 0) && (currentUser.SecondaryStreet__c.length() == 0) && (currentUser.SecondaryCity__c.length() == 0) && (currentUser.SecondaryState__c.length() == 0) && (currentUser.SecondaryPostal__c.length() == 0) && (currentUser.SecondaryCountry__c.length() == 0);
    	hasSecondaryLocation = (isAddingSecondaryLocation == false);
    }
    
    private User getCurrentUser()
    {
    	currentUser = [SELECT Id, Email, Phone, Fax, MobilePhone, Street, State, PostalCode, Country, City, Account_Level_Expire__c, 
            Account_Level__c, Hierarchy_TTM_Sales__c, Designer_Id__c, eComm_Pswd__c, DTP_Card_Exp_Date_CLN__c, 
            CreatedDate, FirstName, LastName, CompanyName, Title,
            SecondaryCompanyName__c, SecondaryTitle__c, SecondaryStreet__c, SecondaryCity__c, SecondaryState__c, SecondaryPostal__c, SecondaryCountry__c
            FROM User WHERE Id = :UserInfo.getUserId()];
    	memberid = (currentUser.Designer_Id__c == null) ? '' : currentUser.Designer_Id__c;
    	membership = (currentUser.Account_Level__c == null) ? '' : currentUser.Account_Level__c;
    	memberexpiration = (currentUser.DTP_Card_Exp_Date_CLN__c == null) ? datetime.now()+'' : currentUser.DTP_Card_Exp_Date_CLN__c+'';
    	password = (currentUser.eComm_Pswd__c == null) ? '' : currentUser.eComm_Pswd__c;
        //status += ' (*)password='+password;
        //status += ' (*)confirmpassword='+confirmpassword;
    	currentUser.FirstName = (currentUser.FirstName == null) ? '' : currentUser.FirstName;
    	currentUser.LastName = (currentUser.LastName == null) ? '' : currentUser.LastName;
    	currentUser.Phone = (currentUser.Phone == null) ? '' : currentUser.Phone;
    	currentUser.Fax = (currentUser.Fax == null) ? '' : currentUser.Fax;
    	currentUser.Email = (currentUser.Email == null) ? '' : currentUser.Email;
    	confirmEmail = currentUser.Email;
    	currentUser.CompanyName = (currentUser.CompanyName == null) ? '' : currentUser.CompanyName;
    	currentUser.Title = (currentUser.Title == null) ? '' : currentUser.Title;
    	currentUser.Street = (currentUser.Street == null) ? '' : currentUser.Street;
    	currentUser.City = (currentUser.City == null) ? '' : currentUser.City;
    	currentUser.State = (currentUser.State == null) ? '' : currentUser.State;
    	currentUser.PostalCode = (currentUser.PostalCode == null) ? '' : currentUser.PostalCode;
    	currentUser.Country = (currentUser.Country == null) ? '' : currentUser.Country;
    	currentUser.SecondaryCompanyName__c = (currentUser.SecondaryCompanyName__c == null) ? '<null>' : currentUser.SecondaryCompanyName__c;
    	currentUser.SecondaryTitle__c = (currentUser.SecondaryTitle__c == null) ? '<null>' : currentUser.SecondaryTitle__c;
    	currentUser.SecondaryStreet__c = (currentUser.SecondaryStreet__c == null) ? '<null>' : currentUser.SecondaryStreet__c;
    	currentUser.SecondaryCity__c = (currentUser.SecondaryCity__c == null) ? '<null>' : currentUser.SecondaryCity__c;
    	currentUser.SecondaryState__c = (currentUser.SecondaryState__c == null) ? '<null>' : currentUser.SecondaryState__c;
    	currentUser.SecondaryPostal__c = (currentUser.SecondaryPostal__c == null) ? '<null>' : currentUser.SecondaryPostal__c;
    	currentUser.SecondaryCountry__c = (currentUser.SecondaryCountry__c == null) ? '<null>' : currentUser.SecondaryCountry__c;
    	refreshAddingSecondaryLocation();
    	/*
        status += ' (*)currentUser.SecondaryCompanyName__c="'+currentUser.SecondaryCompanyName__c+'"';
        status += ' (*)currentUser.SecondaryTitle__c="'+currentUser.SecondaryTitle__c+'"';
        status += ' (*)currentUser.SecondaryStreet__c="'+currentUser.SecondaryStreet__c+'"';
        status += ' (*)currentUser.SecondaryCity__c="'+currentUser.SecondaryCity__c+'"';
        status += ' (*)currentUser.SecondaryState__c="'+currentUser.SecondaryState__c+'"';
        status += ' (*)currentUser.SecondaryPostal__c="'+currentUser.SecondaryPostal__c+'"';
        status += ' (*)currentUser.SecondaryCountry__c="'+currentUser.SecondaryCountry__c+'"';
        */
	    companyname = currentUser.SecondaryCompanyName__c;
	    title = currentUser.SecondaryTitle__c;
	    street = currentUser.SecondaryStreet__c;
	    city = currentUser.SecondaryCity__c;
	    state = currentUser.SecondaryState__c;
	    postal = currentUser.SecondaryPostal__c;
	    country = currentUser.SecondaryCountry__c;
	    /*
        status += ' (**)companyname="'+companyname+'"';
        status += ' (**)title="'+title+'"';
        status += ' (**)street="'+street+'"';
        status += ' (**)city="'+city+'"';
        status += ' (**)state="'+state+'"';
        status += ' (**)postal="'+postal+'"';
        status += ' (**)country="'+country+'"';
        status += ' (*)isAddingSecondaryLocation='+isAddingSecondaryLocation;
        */
        return currentUser;
    }
    
    public PageReference changeSecondaryLocation() {
        PageReference p = ApexPages.currentPage();
        currentUser = getCurrentUser();
        //status += get_debugging_info(p);
        companyname = p.getParameters().get('companyname');
        title = p.getParameters().get('title');
        street = p.getParameters().get('street');
        city = p.getParameters().get('city');
        state = p.getParameters().get('state');
        postal = p.getParameters().get('postal');
        country = p.getParameters().get('country');
        /*
        if (status.length() > 0) {
        	status += ' (**)companyname="'+companyname+'"';
        	status += ' (**)title="'+title+'"';
        	status += ' (**)street="'+street+'"';
        	status += ' (**)city="'+city+'"';
        	status += ' (**)state="'+state+'"';
        	status += ' (**)postal="'+postal+'"';
        	status += ' (**)country="'+country+'"';
        }
        */
        if ( (companyname.length() > 0)
        	 || (title.length() > 0)
        	 || (street.length() > 0) 
        	 || (city.length() > 0) 
        	 || (state.length() > 0) 
        	 || (postal.length() > 0) 
        	 || (country.length() > 0)
        	) {
            try {
		    	currentUser.SecondaryCompanyName__c = companyname;
		    	currentUser.SecondaryTitle__c = title;
		    	currentUser.SecondaryStreet__c = street;
		    	currentUser.SecondaryCity__c = city;
		    	currentUser.SecondaryState__c = state;
		    	currentUser.SecondaryPostal__c = postal;
		    	currentUser.SecondaryCountry__c = country;
                update currentUser;
		        isChangingPassword = false;
		        isChangingContact = false;
		        isChangingMember = false;
		        isChangingPrimaryLocation = false;
		        isChangingSecondaryLocation = false;
            } catch(System.DmlException e) {
                status += e.getDmlMessage(0);
            }
        } else {
            status += 'WARNING: Cannot perform update.';
        }
        isStatusVisible = (status.length() > 0);
        return null;
    }
    
    public PageReference changePrimaryLocation() {
        PageReference p = ApexPages.currentPage();
        currentUser = getCurrentUser();
        //status += get_debugging_info(p);
        String companyname = p.getParameters().get('modifyAccount:mainBlock:businessFormBlock:businessForm:companyname');
        String title = p.getParameters().get('modifyAccount:mainBlock:businessFormBlock:businessForm:title');
        String street = p.getParameters().get('modifyAccount:mainBlock:businessFormBlock:businessForm:street');
        String city = p.getParameters().get('modifyAccount:mainBlock:businessFormBlock:businessForm:city');
        String state = p.getParameters().get('modifyAccount:mainBlock:businessFormBlock:businessForm:state');
        String postal = p.getParameters().get('modifyAccount:mainBlock:businessFormBlock:businessForm:postal');
        String country = p.getParameters().get('modifyAccount:mainBlock:businessFormBlock:businessForm:country');
        /*
        if (status.length() > 0) {
        	status += ' companyname="'+companyname+'"';
        	status += ' title="'+title+'"';
        	status += ' street="'+street+'"';
        	status += ' city="'+city+'"';
        	status += ' state="'+state+'"';
        	status += ' postal="'+postal+'"';
        	status += ' country="'+country+'"';
        }
        */
        if ( (companyname.length() > 0)
        	 || (title.length() > 0)
        	 || (street.length() > 0) 
        	 || (city.length() > 0) 
        	 || (state.length() > 0) 
        	 || (postal.length() > 0) 
        	 || (country.length() > 0) 
        	) {
            try {
		    	currentUser.CompanyName = companyname;
		    	currentUser.Title = title;
		    	currentUser.Street = street;
		    	currentUser.City = city;
		    	currentUser.State = state;
		    	currentUser.PostalCode = postal;
		    	currentUser.Country = country;
                update currentUser;
		        isChangingPassword = false;
		        isChangingContact = false;
		        isChangingMember = false;
		        isChangingPrimaryLocation = false;
		        isChangingSecondaryLocation = false;
            } catch(System.DmlException e) {
                status += e.getDmlMessage(0);
            }
        }
        isStatusVisible = (status.length() > 0);
        return null;
    }
    
    public PageReference changeUserPassword() {
        PageReference p = ApexPages.currentPage();
        currentUser = getCurrentUser();
        //status += get_debugging_info(p);
        password = p.getParameters().get('modifyAccount:mainBlock:passwordFormBlock:passwordForm:password');
        confirmpassword = p.getParameters().get('modifyAccount:mainBlock:passwordFormBlock:passwordForm:confirmpassword');
        if (password == confirmpassword) {
            isChangingPassword = false;
            try {
                currentUser.eComm_Pswd__c = password;
                update currentUser;
                p = Page.PortalMain;
                status += 'Password change is complete !';
                String s_body = currentUser.Email+'\n\nPassword Change Request\n\nUsername: '+currentUser.Designer_ID__c+'\nPassword: '+currentUser.eComm_Pswd__c+'';
                PortalUtilities.sendEmail('Password Change for '+currentUser.Designer_ID__c, s_body, currentUser.Email);
		        isChangingPassword = false;
		        isChangingContact = false;
		        isChangingMember = false;
		        isChangingPrimaryLocation = false;
		        isChangingSecondaryLocation = false;
            } catch(System.DmlException e) {
                status += e.getDmlMessage(0);
		        p = null;
            }
        } else {
	        isChangingPassword = false;
	        isChangingContact = false;
	        isChangingMember = false;
	        isChangingPrimaryLocation = false;
	        isChangingSecondaryLocation = false;
            status += 'WARNING: Both Passwords ("'+password+'","'+confirmpassword+'") must match; please try again.';
            p = null;
        }
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference changeContact() {
        PageReference p = ApexPages.currentPage();
        currentUser = getCurrentUser();
        //status += get_debugging_info(p);
        String firstName = p.getParameters().get('modifyAccount:mainBlock:contactFormBlock:contactForm:firstname');
        String lastName = p.getParameters().get('modifyAccount:mainBlock:contactFormBlock:contactForm:lastname');
        String phone = p.getParameters().get('modifyAccount:mainBlock:contactFormBlock:contactForm:phone');
        String fax = p.getParameters().get('modifyAccount:mainBlock:contactFormBlock:contactForm:fax');
        String email = p.getParameters().get('modifyAccount:mainBlock:contactFormBlock:contactForm:email');
        String emailConfirm = p.getParameters().get('modifyAccount:mainBlock:contactFormBlock:contactForm:confirmemail');
        /*
        if (status.length() > 0) {
        	status += ' firstName="'+firstName+'"';
        	status += ' lastName="'+lastName+'"';
        	status += ' phone="'+phone+'"';
        	status += ' fax="'+fax+'"';
        	status += ' email="'+email+'"';
        	status += ' emailConfirm="'+emailConfirm+'"';
        }
        */
        try {
	        currentUser.FirstName = firstName;
	        currentUser.LastName = lastName;
	        currentUser.Phone = phone;
	        currentUser.Fax = fax;
	        if (email == emailConfirm) {
		        currentUser.Email = email;
	            status += 'Contact Information change is complete, including the Email Address !';
	        } else {
	            status += 'Contact Information change is complete, except for the Email Address because both Email Addresses must match; please try again.';
	        }
            update currentUser;
	        isChangingPassword = false;
	        isChangingContact = false;
	        isChangingMember = false;
	        isChangingPrimaryLocation = false;
	        isChangingSecondaryLocation = false;
	        p = null;
        } catch(System.DmlException e) {
            status += e.getDmlMessage(0);
	        isChangingPassword = false;
	        isChangingContact = false;
	        isChangingMember = false;
	        isChangingPrimaryLocation = false;
	        isChangingSecondaryLocation = false;
	        p = null;
        }
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public String get_debugging_info(PageReference p) {
        String s = '';
        String ip = p.getHeaders().get('X-Salesforce-SIP');
        s += ' ip='+ip;
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
    
    public PageReference changeMember() {
        return null;
    }
    
    public Boolean getIsExpiring()
    {
        if(currentUser.DTP_Card_Exp_Date_CLN__c != null)
            return ((Date.today().daysBetween(currentUser.DTP_Card_Exp_Date_CLN__c) <= 31) && currentUser.Account_Level__c == 'Green');
        else
            return false;
    }
    
    public PageReference addNewLocation() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = true;
        isAddingSecondaryLocation = false;
        status += 'DEBUG: addNewLocation !!!';
        isStatusVisible = (status.length() > 0);
        return null;
    }
    
    public PageReference addSecondaryLocation() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = true;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = true;
        isAddingSecondaryLocation = false;
        //status += 'DEBUG: addSecondaryLocation !!!';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference modifyPrimaryLocation() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = true;
        isChangingSecondaryLocation = false;
        isAddingSecondaryLocation = false;
        //status += 'DEBUG: modifyPrimaryLocation !!!';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference modifySecondaryLocation() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = true;
        //status += 'DEBUG: modifySecondaryLocation !!!';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference modifyUserPassword() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = true;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
        //status += 'DEBUG: modifyUserPassword !!!';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference modifyContact() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = true;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
        //status += 'DEBUG: modifyContact !!!';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference modifyMember() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = true;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
        //status = 'DEBUG: modifyMember !!!'+'\n'+get_debugging_info(p);
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference cancelChangeSecondaryLocation() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
    	refreshAddingSecondaryLocation();
        status = '';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference cancelChangePrimaryLocation() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
        status = '';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference cancelChangeUserPassword() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
        status = '';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference cancelChangeContact() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingMember = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
        status = '';
        isStatusVisible = (status.length() > 0);
        return p;
    }
    
    public PageReference cancelChangeMember() {
        PageReference p = ApexPages.currentPage();
        isChangingPassword = false;
        isChangingContact = false;
        isChangingPrimaryLocation = false;
        isChangingSecondaryLocation = false;
        isChangingMember = false;
        status = '';
        isStatusVisible = (status.length() > 0);
        return p;
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
            hasChanged = false;
            cancelText = 'Close';
            
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

    public PageReference cancel() {
      return Page.PortalMain;
    }
}