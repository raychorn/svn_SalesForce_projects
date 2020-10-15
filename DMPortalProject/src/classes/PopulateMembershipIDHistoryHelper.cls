/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This is the helper class to track whether the                       */
/*  PopulateMembershipIDHistory class is running.                       */
/*                                                                      */
/*  ARGUMENTS: none                                                     */
/*                                                                      */
/*----------------------------------------------------------------------*/

public class PopulateMembershipIDHistoryHelper {
    
    // Delare variable and initialize it to false
    private static boolean  inProcess = false;
    
    // This function is called by Triggers to see if an instance of the Class is already in process
    public static boolean triggerIsInProcess() {
        return inProcess;
    }
    
    // This function is called by Triggers after all the in-memory processing and before the DML execution to inform the Class
    // that it is already in process.
    public static void setTriggerInProcess() {
        inProcess = true;
    }
    
    // This function is called by the Unit Test to simulate completion of a DML statement.  This function is NOT intended for any other purpose
    public static void resetTriggerInProcess() {
        inProcess = false;
    }
}