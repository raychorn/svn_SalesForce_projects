/*---------------------------------------------------------------------------------*/
/*                                                                                 */
/*  This class updates the Contact Expiration Date and Designer ID.                */
/*                                                                                 */
/*  ARGUMENTS:                                                                     */
/*  contacts:           The Contacts that need to be updated.                      */
/*                                                                                 */
/*---------------------------------------------------------------------------------*/

public class UpdateContacts {
    
    public static void UpdateContacts(List<Contact> contacts) {
        
        // Declare local variables
        Boolean                                                 contactHasChanged;
        List<Contact>                                           contactsToUpdate = new List<Contact>();
        Boolean                                                 expirationDateHasChanged;
        Date                                                    expirationInOneYear;
        Date                                                    expirationInTwoYears;
        Map<String, Membership_Level_Puchase_Requirements__c>   mLPRMap = new Map<String, Membership_Level_Puchase_Requirements__c>();
        Date                                                    yesterday = date.today().addDays(-1);

        // Get the Membership Level Purchase Requirements
        mLPRMap = Membership_Level_Puchase_Requirements__c.getAll();
        
        // Set the expiration date
        if (date.today().month() == 1) {
            if (date.today().day() == 1 ) {
                expirationInOneYear = date.newInstance(date.today().year(), 12, 31);
                expirationInTwoYears = date.newInstance(date.today().year() + 1, 12, 31);
            } else {
                expirationInOneYear = date.newInstance(date.today().year() + 1, 1, 31);
                expirationInTwoYears = date.newInstance(date.today().year() + 2, 1, 31);
            }
        } else {
            if (date.today().day() == 1 ) {
                expirationInOneYear = date.newInstance(date.today().year() + 1, date.today().month() - 1, date.daysInMonth(date.today().year() + 1, date.today().month() - 1));
                expirationInTwoYears = date.newInstance(date.today().year() + 2, date.today().month() - 1, date.daysInMonth(date.today().year() + 2, date.today().month() - 1));
            } else {
                expirationInOneYear = date.newInstance(date.today().year() + 1, date.today().month(), date.daysInMonth(date.today().year() + 1, date.today().month()));
                expirationInTwoYears = date.newInstance(date.today().year() + 2, date.today().month(), date.daysInMonth(date.today().year() + 2, date.today().month()));
            }
        }

        System.debug('Processing: ' + contacts);
        for (Contact c : contacts) {

            // Reset whether the Contact and whether the Expiration Date has changed
            contactHasChanged = false;
            expirationDateHasChanged = false;
            
            // Set the expiration date if the Account has been downgraded to Green
            if (mLPRMap.containsKey(c.Account_Level__c) && c.Account_Membership_Level_Last_Changed__c >= yesterday) {
                if (mLPRMap.get(c.Account_Level__c).Purchase_Requirement__c == 0) {
                    c.DTP_Card_Exp_Date_CLN__c = expirationInTwoYears;
                    contactHasChanged = true;
                    expirationDateHasChanged = true;
                    System.debug(c + ' has been downgraded to Green.');
                }
            }
            
            // Set the expiration date if the Account is now a 2 or a 5
            if ((c.Designer_ID__c != null && c.Membership_ID_Formula__c != null) ? (!c.Designer_ID__c.startsWith(c.Membership_ID_Formula__c.substring(0,1)) &&
            (c.Membership_ID_Formula__c.startsWith('2') || c.Membership_ID_Formula__c.startsWith('5'))) : 
            (c.Membership_ID_Formula__c != null ? c.Membership_ID_Formula__c.startsWith('2') || c.Membership_ID_Formula__c.startsWith('5') : false)) {
                System.debug(c + ' has changed to a 2 or 5.');
                c.DTP_Card_Exp_Date_CLN__c = expirationInTwoYears;
                contactHasChanged = true;
                expirationDateHasChanged = true;
            }

            // Set the new Designer ID if the calc ID and the existing ID do not start with the same character, if the Design Concierge Services
            // box is not checked, and the calc ID is different from the existing ID.
            if ((c.Designer_ID__c == null || c.Membership_ID_Formula__c == null ? true : !c.Designer_ID__c.startsWith(c.Membership_ID_Formula__c.substring(0,1))) &&
            (!c.Design_Concierge_Services__c || !c.Assign_Membership_ID__c) && c.Designer_ID__c != c.Membership_ID_Formula__c) {
                System.debug('Designer ID ' + c.Designer_ID__c + ' is being changed to ' + c.Membership_ID_Formula__c);
                c.Designer_ID__c = c.Membership_ID_Formula__c;
                if (expirationDateHasChanged == false && c.Account_level_Expire__c != null) {
                    c.DTP_Card_Exp_Date_CLN__c = c.Account_level_Expire__c;
                }
                contactHasChanged = true;
            }
            
            // If the Account Expiration has changed and the Contact Expiration has not yet changed, change the Contact Expiration
            if(c.Account_Expiration_Last_Changed__c >= yesterday && !expirationDateHasChanged)
            {
                c.DTP_Card_Exp_Date_CLN__c = c.Account_level_Expire__c;
                contactHasChanged = true;
            }
            
            // Add the Contact to the list to be updated if it has changed
            if (contactHasChanged) {
                contactsToUpdate.add(c);
            }
        }

        // Update the Contacts here if this has not been called from a Contact Trigger
        if (contactsToUpdate.size() > 0) {
            System.debug('About to update ' + contactsToUpdate);
            Database.SaveResult[] lsr = database.update(contactsToUpdate);
            for (Database.SaveResult sr : lsr) {
                if (!sr.isSuccess()) {
                    System.debug(sr.getErrors()[0].getMessage());
                }
            }
        }
    }
}