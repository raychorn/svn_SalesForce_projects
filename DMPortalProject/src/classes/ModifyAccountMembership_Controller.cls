public with sharing class ModifyAccountMembership_Controller 
{
    // Test passes
    private Boolean isTesting = false;
    
    public User currentUser {get; set;}

    public String memberid {get; set;}
    public String membership {get; set;}
    public String memberlevel {get; set;}
    public String memberexpiration {get; set;}
    
    public String userid {get; set;}
    public String usersname {get; set;}
    
    public List<SelectOption> levels {get; private set;}
    public List<SelectOption> users {get; private set;}

    public Boolean isChangingMember {get; set;}
    public Boolean isChoosingUser {get; set;}
    public Boolean isShowingUser {get; set;}
    
    public Boolean isStatusVisible {get; private set;}
    
    public String status {get; private set;}

    public ModifyAccountMembership_Controller(Boolean isTest)
    {
        isTesting = true;
        fc();
    }   
    public ModifyAccountMembership_Controller()
    {
        fc();
    }
    private void fc()
    {
        memberid = '';
        membership = '';
        memberlevel = '';
        memberexpiration = datetime.now()+'';
        userid = '';
        usersname = '';
        levels = null;
        users = null;
        getCurrentUser();
        isChangingMember = false;
        isStatusVisible = false;
        isChoosingUser = false;
        isShowingUser = false;
        status = '';
        isStatusVisible = true;
    }
    
    public String get_debugging_info(PageReference p) {
		String s = '';
        String ip = p.getHeaders().get('X-Salesforce-SIP');
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
    
    private User getCurrentUser()
    {
    	currentUser = [SELECT Id, Email, Phone, Fax, MobilePhone, Street, State, PostalCode, Country, City, Account_Level_Expire__c, 
            Account_Level__c, Hierarchy_TTM_Sales__c, Designer_Id__c, eComm_Pswd__c, DTP_Card_Exp_Date_CLN__c, 
            CreatedDate, FirstName, LastName, CompanyName, Title FROM User 
            WHERE Id = :UserInfo.getUserId()];
    	memberid = (currentUser.Designer_Id__c == null) ? '' : currentUser.Designer_Id__c;
    	membership = (currentUser.Account_Level__c == null) ? '' : currentUser.Account_Level__c;
    	memberexpiration = (currentUser.DTP_Card_Exp_Date_CLN__c == null) ? datetime.now()+'' : currentUser.DTP_Card_Exp_Date_CLN__c+'';
		List<String> toks = memberexpiration.split(' ');
		memberexpiration = toks[0];
        return currentUser;
    }
    
	public List<SelectOption> getUsers() {
		List<SelectOption> options = new List<SelectOption>();
	        
    	//List<User> users = [SELECT Id, FirstName, LastName FROM User WHERE IsActive = true AND IsPortalEnabled = true AND FederationIdentifier != NULL ];
    	List<User> users = [SELECT Id, FirstName, LastName FROM User WHERE IsActive = true AND FirstName != NULL AND LastName != NULL ];
	        
		for(User u : users){
			options.add(new SelectOption(u.Id+','+u.FirstName+' '+u.LastName, u.FirstName+' '+u.LastName+' ('+u.Id+')'));
		}
		return options;
	}
    
    public PageReference chooseUser() {
        PageReference p = ApexPages.currentPage();
        currentUser = getCurrentUser();
        status = get_debugging_info(p);
        Boolean isDebugging = (status.length() > 0) ? true : false;
        if (isDebugging) {
	        status += ' DEBUG: changeMember() !!!';
        }
        if (true) {
        	String s = p.getParameters().get('modifyMember:usersBlock:usersForm:userid');
			List<String> toks = s.split(',');
        	userid = toks[0];
        	usersname = toks[toks.size()-1];
            isChoosingUser = false;
            isShowingUser = true;
        }
        isStatusVisible = true;
        return null;
    }
    
    public PageReference changeMember() {
        PageReference p = ApexPages.currentPage();
        currentUser = getCurrentUser();
        status = get_debugging_info(p);
        Boolean isDebugging = (status.length() > 0) ? true : false;
        if (isDebugging) {
	        status += ' DEBUG: changeMember() !!!';
        }
        if (true) {
        	String mid = p.getParameters().get('modifyMember:memberBlock:memberForm:memberid');
        	String mship = p.getParameters().get('modifyMember:memberBlock:memberForm:membership');
        	String mlevel = p.getParameters().get('modifyMember:memberBlock:memberForm:levels');
        	String mexpiration = p.getParameters().get('modifyMember:memberBlock:memberForm:memberexpiration');
	        if (isDebugging) {
		        status += ' (1) mid='+mid;
		        status += ' (2) mship='+mship;
		        status += ' (3) mlevel='+mlevel;
		        status += ' (4) mexpiration='+mexpiration;
	        }
            isChangingMember = false;
            try {
                currentUser.Designer_Id__c = mid;
		    	currentUser.Account_Level__c = mlevel;
		    	try {
		    		List<String> toks = mexpiration.split('-');
		    		//for(Integer i=0; i < toks.size() ; i++) {
					//	status += ' tok['+i+']"'+toks[i]+'"';
					//}
	    			currentUser.DTP_Card_Exp_Date_CLN__c = Date.newInstance(integer.valueOf(toks[0]), integer.valueOf(toks[1]), integer.valueOf(toks[2]));
				} catch (Exception e) {
                	status += ' DATE_ERROR: '+e;
				}
                update currentUser;
                status += 'Membership change is complete !';
		    	memberid = currentUser.Designer_Id__c;
		    	membership = currentUser.Account_Level__c;
		    	memberlevel = currentUser.Account_Level__c;
		    	memberexpiration = mexpiration;
            } catch(System.DmlException e) {
                status += ' DML_ERROR: '+e.getDmlMessage(0);
            }
        }
        isStatusVisible = true;
        return Page.ModifyAccountMembership;
    }
    
	public List<SelectOption> getLevels() {
	  List<SelectOption> options = new List<SelectOption>();
	        
	   Schema.DescribeFieldResult fieldResult = User.Account_Level__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   for( Schema.PicklistEntry f : ple) {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}

    public PageReference printTemporaryIDCardPDF()
    {
        PageReference retVal = Page.PrintTemporaryIDCard;
        retVal.getParameters().put('renderas', 'pdf');
        return retVal;
    }

    public PageReference returnToWSI()
    {
        return new PageReference('http://www.wsidesignermarketplace.com');
    }

    public PageReference choosingUser() {
        PageReference p = ApexPages.currentPage();
        isChoosingUser = true;
        isStatusVisible = true;
        status = get_debugging_info(p);
        users = getUsers();
        if (status.length() > 0) {
	        status += ' DEBUG: modifyMember !!!';
        }
        return null;
    }
    
    public PageReference cancelChoosingUser() {
        PageReference p = ApexPages.currentPage();
        isChoosingUser = false;
        status = get_debugging_info(p);
        userid = usersname = '';
        if (status.length() > 0) {
	        status += ' DEBUG: cancelChangeUser !!!';
        }
        return null;
    }
    
    public PageReference modifyMember() {
        PageReference p = ApexPages.currentPage();
        isChangingMember = true;
        isStatusVisible = true;
        status = get_debugging_info(p);
        levels = getLevels();
        if (status.length() > 0) {
	        status += ' DEBUG: modifyMember !!!';
        }
        return null;
    }
    
    public PageReference cancelChangeMember() {
        PageReference p = ApexPages.currentPage();
        isChangingMember = false;
        status = get_debugging_info(p);
        if (status.length() > 0) {
	        status += ' DEBUG: cancelChangeMember !!!';
        }
        return null;
    }
    
    public PageReference contactUs()
    {
        PageReference retVal = Page.ContactUs;
        return retVal;
    }

}