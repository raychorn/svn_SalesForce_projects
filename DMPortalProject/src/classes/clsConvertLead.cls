public with sharing class clsConvertLead {

    Public Account ACC { Get; Set;}
    Public Opportunity OPP { Get; Set;}
    Public Task Task{ Get; Set;}    

    public clsConvertLead(ApexPages.StandardController controller) {

        ACC=new Account();
        OPP=new Opportunity();
        Task=new Task();
    }

}