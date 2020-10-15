/*----------------------------------------------------------------------*/
/*                                                                      */
/*  This is the helper class to track whether the                       */
/*  UserSync triggers are running.                                      */
/*                                                                      */
/*----------------------------------------------------------------------*/

public class UserSyncHelper 
{
    // Delare variable and initialize it to false
    private static Boolean  contactInProcess = false;
    private static Boolean  userInProcess = false;
    
    // This function is called by Triggers to see if an instance of the Class is already in process
    public static boolean contactTriggerIsInProcess() 
    {
        return contactInProcess;
    }
    public static boolean userTriggerIsInProcess() 
    {
        return userInProcess;
    }
    
    // This function is called by Triggers after all the in-memory processing and before the DML execution to inform the Class
    // that it is already in process.
    public static void setContactTriggerInProcess() 
    {
        contactInProcess = true;
    }
    public static void setUserTriggerInProcess() 
    {
        userInProcess = true;
    }
}