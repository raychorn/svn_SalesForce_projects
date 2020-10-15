public class AjaxResponseController {
    public String result {get;set;}
     
    private static String endPoint = 'https://cs4.salesforce.com/secur/login_portal.jsp?orgId=00DP000000059XR&portalId=060P0000000D0W7';

    public void doSearch() {
        PageReference p = null;
        Map<string,string> params = ApexPages.currentPage().getParameters();
         
        List<User> records = getRecords(params.get('username'),params.get('password'));
         
        p = new PageReference(endPoint+'&un='+params.get('username')+'&pw='+params.get('password'));
        result = '{"url":'+((records.size() == 1) ? '"'+p.getUrl()+'"' : null)+',"main":'+((records.size() == 1) ? '"'+Page.PortalMain.getUrl()+'"' : null)+'}';
    }
     
    public List<User> getRecords(String username, String password) {
        List<User> records = new List<User>();
        if ( (username != null && username.trim().length() > 0) && (password != null && password.trim().length() > 0) ) {
	        records = [SELECT Id, Username, FederationIdentifier, IsPortalEnabled, IsActive, Contact.eComm_Pswd__c, Contact.Designer_ID__c, ContactId 
                        FROM User
                        WHERE Contact.Designer_ID__c = :username 
                        AND Contact.eComm_Pswd__c = :password 
                        AND IsPortalEnabled = TRUE
                        AND IsActive = TRUE
                        AND FederationIdentifier != NULL
                        limit 1];
        }   
        return records;      
    }    
}