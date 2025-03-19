public class UnsubscribeLinkController {
    public Id emailRecipientId {
      get;
      set { 
          emailRecipientId = value; 
          If(emailRecipientId == null){
              return;
          }
          //Assuming the part1 field names are identical for both contact and lead objects
          String idPrefix = ((String)emailRecipientId).left(3);
          String part1UnsubscribeLink;
          If(idPrefix == '003'){
              Contact theContact = [select id, Part1_Unsubscribe_Link__c from Contact where id = :emailRecipientId];
              part1UnsubscribeLink = theContact.Part1_Unsubscribe_Link__c;
          }else if(idPrefix == '00Q'){
              Lead theLead = [select id, Part1_Unsubscribe_Link__c from Lead where id = :emailRecipientId];
              part1UnsubscribeLink = theLead.Part1_Unsubscribe_Link__c;
          }else{
              TypeException e = new TypeException();
    		  e.setMessage('Recipient must be a contact or lead to use this component');
    		  throw e;
          }
          unsubscribeLinkUrl = getUnsubscribeLinkUrlFromParts(part1UnsubscribeLink);
          unsubscribeLinkTitle = getUnsubscribeLinkTitleFromParts(part1UnsubscribeLink);
      }
   }
    public String unsubscribeLinkUrl {get; set;}
    public String unsubscribeLinkTitle {get; set;}

    public UnsubscribeLinkController(){}

    // Method to extract the unsubscribe link URL from the provided string
    private String getUnsubscribeLinkUrlFromParts(String linkParts) {
        if (String.isNotBlank(linkParts)) {
            List<String> parts = linkParts.split('\\+');
            return parts[0];
        }
        return '';
    }

    // Method to extract the unsubscribe link title from the provided string
    private String getUnsubscribeLinkTitleFromParts(String linkParts) {
        if (String.isNotBlank(linkParts)) {
            List<String> parts = linkParts.split('\\+');
            return parts[1];
        }
        return '';
    }
}