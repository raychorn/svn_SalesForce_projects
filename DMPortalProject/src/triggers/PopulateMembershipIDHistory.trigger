/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Trigger populates / updates the Membership ID History          */
/*  object when the Designer ID is changed.                             */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger PopulateMembershipIDHistory on Contact (after insert, after update) {
    
    // Only execute this Trigger if it is not already running.  This prevents recursive loops.
    if (!PopulateMembershipIDHistoryHelper.triggerIsInProcess()) {

        // Declare local variables
        Set<Id>                                                 contactIds = new Set<Id>();
        Boolean                                                 executeTrigger = false;
        Integer                                                 firstDigitNew;
        Integer                                                 firstDigitOld;
        Membership_ID_History__c                                midh;
        List<Membership_ID_History__c>                          midhList = new List<Membership_ID_History__c>();
        final Date                                              today = date.today();
    
        for (Integer l = 0; l < Trigger.new.size(); l++) {
            if ((Trigger.isInsert && Trigger.new[l].Designer_ID__c != null) || (Trigger.isUpdate && Trigger.old[l].Designer_ID__c != Trigger.new[l].Designer_ID__c)) {
                executeTrigger = true;
            }
        }
        // Only run this Trigger if it is an Insert with a prepopulated Designer ID or an Update with a changed Designer ID
        if (executeTrigger) {
        
            // If this is an update, get and update the MIDH records that need to be expired
            if (Trigger.isUpdate) {
                
                // Get the Contact IDs for those with new Designer IDs
                for (Integer i = 0; i < Trigger.new.size(); i++) {
                    if (Trigger.old[i].Designer_ID__c != Trigger.new[i].Designer_ID__c && Trigger.old[i].Designer_ID__c != null) {
                        contactIds.add(Trigger.old[i].Id);
                    }
                }
                
                // Get the MIDH records
                if (ContactIds.size() > 0) {
                    midhList = [SELECT Contact__c, Expiration_Reason__c, Id, Valid_Through__c FROM Membership_ID_History__c WHERE Contact__c IN :contactIds AND Valid_Through__c = null];
                }
                
                // Loop through the MIDH records updating the Expiration Reason and the Valid Through date
                if (midhList.size()>0) {
                    
                    for (Integer j = 0; j < midhList.size(); j++) {
                        
                        // Set the expiration to today
                        midhList[j].Valid_Through__c = today;
                        
                        // Set the Expiration Reason
                        if (Trigger.newMap.get(midhList[j].Contact__c).Designer_ID__c == null) {
                            midhList[j].Expiration_Reason__c = 'Expired';
                        } else if (Trigger.oldMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('1')) {
                            if (Trigger.newMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('6') || Trigger.newMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('7')) {
                                midhList[j].Expiration_Reason__c = 'Upgraded';
                            } else {
                                midhList[j].Expiration_Reason__c = 'Program Change';
                            }
                        } else if (Trigger.oldMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('6')) {
                            if (Trigger.newMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('7')) {
                                midhList[j].Expiration_Reason__c = 'Upgraded';
                            } else if (Trigger.newMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('1')){
                                midhList[j].Expiration_Reason__c = 'Downgraded';
                            } else {
                                midhList[j].Expiration_Reason__c = 'Program Change';
                            }
                        } else if (Trigger.oldMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('7')) {
                            if (Trigger.newMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('1') || Trigger.newMap.get(midhList[j].Contact__c).Designer_ID__c.startsWith('6')) {
                                midhList[j].Expiration_Reason__c = 'Downgraded';
                            } else {
                                midhList[j].Expiration_Reason__c = 'Program Change';
                            }                   
                        } else {
                            midhList[j].Expiration_Reason__c = 'Program Change';
                        }
                    }
                }
            }
            
            // If the Trigger is an Insert or Update, create the new Membership ID History record
            for (Integer k = 0; k < Trigger.new.size(); k++) {
                if ((Trigger.isInsert || (Trigger.IsUpdate && Trigger.old[k].Designer_ID__c != Trigger.new[k].Designer_ID__c)) && Trigger.new[k].Designer_ID__c != null) {
                    midh = new Membership_ID_History__c (Contact__c = Trigger.new[k].Id, Membership_ID__c = Trigger.new[k].Designer_ID__c, Valid_From__c = today);
                    midhList.add(midh.clone(true, true));
                }
            }
            
            // Set the Helper Class in process
            PopulateMembershipIDHistoryHelper.setTriggerInProcess();
        
            // Upsert the MIDH records
            if (midhList.size() > 0) {
                List<Database.upsertResult> upsertResults = Database.upsert(midhList, false);
                for (Database.upsertResult upsertResult : upsertResults) {
                    if (!upsertResult.isSuccess()) {
                        System.debug(upsertResult.getErrors()[0]);
                    }
                }
            }
        }
    }
}