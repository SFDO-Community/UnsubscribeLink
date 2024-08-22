public with sharing class generateAllRandomStrings {
  public generateAllRandomStrings() {
    List<Contact> updateList = new List<Contact>();
    List<Contact> allContacts = [
      SELECT UnsubscribeLnk__Public_Id__c
      FROM Contact
      WHERE UnsubscribeLnk__Public_Id__c = ''
    ];
    for (Contact c : allContacts) {
      c.UnsubscribeLnk__Public_Id__c = '1';
      updateList.add(c);
    }
    update updateList;
  }
}
