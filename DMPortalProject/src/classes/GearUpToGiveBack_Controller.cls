public with sharing class GearUpToGiveBack_Controller 
{
	public String searchString {get; set;}
	private List<Account> accountList;
	public List<AccountWrapper> accountListWrapper {get; private set;}
	
	public class AccountWrapper
	{
		public Account a {get; private set;}
		public String memberId {get; private set;}
		public String password {get; private set;}
		
		public AccountWrapper(Account act, String dId, String pW)
		{
			a = act;
			memberId = dId;
			password = pW;
		}
	}

	public GearUpToGiveBack_Controller()
	{
		searchString = '';
		accountList = new List<Account>();
		accountListWrapper = new List<AccountWrapper>();
	}
	
	private void refreshWrapper()
	{
		// Clean wrapper
		accountListWrapper.clear();
		
		// Create list of account Ids
		List<Id> accountIds = new List<Id>();
		for(Account a : accountList)
		{
			accountIds.add(a.Id);
		}
		
		// Get matching contact data
		List<Contact> contacts = [SELECT Id, AccountId, Designer_Id__c, eComm_Pswd__c FROM Contact 
			WHERE AccountId IN :accountIds AND Designer_Id__c != NULL AND eComm_Pswd__c != NULL];
		Map<Id, String> memberIdMap = new Map<Id, String>();
		Map<Id, String> passwordMap = new Map<Id, String>();
		for(Contact c : contacts)
		{
			memberIdMap.put(c.AccountId, c.Designer_Id__c);
			passwordMap.put(c.AccountId, c.eComm_Pswd__c);
		}
		
		// Now populate wrapper list with matching contact data
		for(Account a : accountList)
		{
			String tmpMId = memberIdMap.get(a.Id);
			String tmpP = passwordMap.get(a.Id);
			if(tmpMId != null && tmpP != null)
			{
				accountListWrapper.add(new AccountWrapper(a, tmpMId, tmpP));
			}
		}
	}
	
	public PageReference searchSchools()
	{
		if(searchString.length() > 1)
		{
			String tmp = searchString + '*';
			List<List<SObject>> searchList = [FIND :tmp IN ALL FIELDS RETURNING Account (Id, Name, BillingStreet, BillingState, BillingPostalCode, BillingCity 
				WHERE Program_Type__c = 'School Rewards')];
			accountList = ((List<Account>)searchList[0]);
		}
		
		refreshWrapper(); // Convert account list to account wrapper list

		return null;
	}

	public PageReference clickedLetter()
	{
		String letter = ApexPages.currentPage().getParameters().get('letter');

		if(letter != null)
		{
			letter += '%';
			accountList = [SELECT Id, Name, BillingStreet, BillingState, BillingPostalCode, BillingCity 
				FROM Account WHERE Name LIKE :letter AND Program_Type__c = 'School Rewards' LIMIT 200];
		}
		
		refreshWrapper(); // Convert account list to account wrapper list

		return null;
	}
}