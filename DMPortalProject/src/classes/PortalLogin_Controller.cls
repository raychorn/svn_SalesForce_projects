public without sharing class PortalLogin_Controller {

    public String memberId {get;set;}
    public String password {get;set;}

    public String status {get;set;}

    public Boolean isStatusVisible {get;set;}
    public Boolean isForgotPassword {get;set;}
    
    public Boolean isRunningLocally {get;set;}

    private static String endPoint = 'https://cs4.salesforce.com/secur/login_portal.jsp?orgId=00DP000000059XR&portalId=060P0000000D0W7';
    private static String orgId = userInfo.getOrganizationId();
    private static String portalId = '060P0000000D0W7';
    
    public PortalLogin_Controller() {
    	isStatusVisible = false;
    	isForgotPassword = false;
        PageReference p = ApexPages.currentPage();
        String ip = p.getHeaders().get('X-Salesforce-SIP');
        isRunningLocally = (ip == '');
    }

    public PageReference login(){
        PageReference p = null;
        if ( memberId != null && password != null ){
            List<User> users = [SELECT Id, Username, FederationIdentifier, IsPortalEnabled, IsActive, Contact.eComm_Pswd__c, Contact.Designer_ID__c, ContactId 
                                FROM User
                                WHERE Contact.Designer_ID__c = :memberId 
                                AND Contact.eComm_Pswd__c = :password 
                                AND IsPortalEnabled = TRUE
                                AND IsActive = TRUE
                                AND FederationIdentifier != NULL
                                limit 1];
            if ( users.size() == 1 ){
                p = new PageReference(endPoint+'&un='+users[0].Username+'&pw='+password); // Page.PortalMain
            }

        }
        return p;
    }
    
    public Pagereference forgotPasswordRequest() {
    	isForgotPassword = true;
        return null;
    }
    
    public Pagereference forgotpasswordCancel() {
    	isForgotPassword = false;
        return null;
    }

    private void sendPost(){
        HttpRequest  req  =  new  HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        //  Specify  the  required  user  name  and  password  to  access  the  endpoint
        //  As  well  as  the  header  and  header  information
        String  username  =  'myname';
        String  password  =  'mypwd';
        Blob  headerValue  =  Blob.valueOf(username  +  ':'  +  password);
        String  authorizationHeader  =  'BASIC  '  +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization',  authorizationHeader);
        //  Create  a  new  http  object  to  send  the  request  object
        //  A  response  object  is  generated  as  a  result  of  the  request
        Http  http  =  new  Http();
        HTTPResponse  res  =  http.send(req);
        System.debug(res.getBody());
    }

    public PageReference forgotpassword(){
        PageReference p = null;
        this.isStatusVisible = false;
        if ( memberId != null){
            List<User> users = [Select Contact.eComm_Pswd__c, u.IsPortalEnabled, u.IsActive, u.FederationIdentifier, u.Email, Contact.Designer_ID__c 
                                From User u 
                                where u.Designer_ID__c = :memberId
                                AND u.IsPortalEnabled = TRUE
                                AND u.IsActive = TRUE
                                AND u.FederationIdentifier != NULL
                                limit 1];
            if ( users.size() == 1 ){
                String s_body = users[0].Email+'\n\nPassword Request\n\nUsername: '+users[0].Contact.Designer_ID__c+'\nPassword: '+users[0].Contact.eComm_Pswd__c+'';
                PortalUtilities.sendEmail('Forgot Password for '+users[0].Contact.Designer_ID__c, s_body, users[0].Email);
                p = ApexPages.currentPage();
                this.isStatusVisible = true;
                this.status = 'Your password has been emailed to you at "'+users[0].Email+'".';
    			isForgotPassword = false;
            } else {
                this.isStatusVisible = true;
                if (memberId.length() == 0) {
                    this.status = 'Please enter your Member ID.';
                } else {
                    this.status = 'Cannot locate your user records for Member ID "'+memberId+'".';
                }
            }
        } else {
            this.status = 'Member ID cannot be empty, null or "'+memberId+'".';
        }
        return p;
    }
}