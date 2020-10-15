public without sharing class PortalUtilities {

    public static void sendEmail(String subject, String body, String toAddress) {
        if(subject != null && body != null && toAddress != null) {
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              String[] toAddresses = new String[] {toAddress};
              mail.setToAddresses(toAddresses);
              String[] bccAddresses = new String[] {'raychorn@gmail.com'};
              mail.setBccAddresses(bccAddresses);
              mail.setSubject(subject);
              mail.setPlainTextBody(body);
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}