/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This Trigger sets the Rollup Stop Date for an Opportunity.          */
/*                                                                      */
/*----------------------------------------------------------------------*/

trigger SetRollupStopDate on Opportunity (before insert, before update) {
    
    // Loop through the Trigger, setting the Rollup Stop Date
    for (integer i = 0; i < Trigger.new.size(); i++)
    {
        if (Trigger.new[i].isWon && Trigger.new[i].CloseDate != null)
        {
            if(Trigger.new[i].CloseDate.month() == 12)
            {
                Trigger.new[i].Rollup_Stop_Date__c = date.newInstance(Trigger.new[i].CloseDate.year()+2,1,1);
            } else {
                Trigger.new[i].Rollup_Stop_Date__c = date.newInstance(Trigger.new[i].CloseDate.year()+1,Trigger.new[i].CloseDate.month()+1,1);
            }
        } else {
            Trigger.new[i].Rollup_Stop_Date__c = null;
        }
    }   
}