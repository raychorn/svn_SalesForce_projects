/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This batch class schedules the batch Apex to recalculate Account    */
/*  totals.                                                             */
/*                                                                      */
/*----------------------------------------------------------------------*/

global class ScheduleRecalculateAccountTotals implements Schedulable {

    global void execute (SchedulableContext sc) {

        string today = String.valueOf(date.today());
        recalculateAccountTotals recAT = new recalculateAccountTotals('SELECT AccountId, Amount FROM Opportunity WHERE IsWon = true AND Rollup_Stop_Date__c = ' + today);
        database.executebatch(recAT);
    }
}