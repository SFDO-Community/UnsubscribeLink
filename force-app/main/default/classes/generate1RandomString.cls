public with sharing class generate1RandomString {
  @InvocableMethod(
    label='Generate Random Text Strings for All'
    description='generates a random id for all contacts and leads'
  )
  public static void randomStringContacts() {
    List<Contact> conList = [
      SELECT Id
      FROM Contact
      WHERE Public_Id__c = ''
      LIMIT 200
    ];
    Integer len = 64;
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    List<Contact> updateCon = new List<Contact>();
    for (Contact c : conList) {
      while (randStr.length() < len) {
        Integer idx = Math.mod(
          Math.abs(Crypto.getRandomInteger()),
          chars.length()
        );
        randStr += chars.substring(idx, idx + 1);
        System.debug('randomstringLead:' + randStr);
      }

      c.Public_Id__c = randStr;
      updateCon.add(c);
      randStr = '';
    }
    update updateCon;
    System.debug('ContactList:' + updateCon);

    List<Lead> leadList = [
      SELECT Id
      FROM Lead
      WHERE Public_Id__c = ''
      LIMIT 200
    ];
    randStr = '';
    //final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    // String randStr = '';
    List<Lead> updateLeads = new List<Lead>();
    for (Lead l : leadList) {
      while (randStr.length() < len) {
        Integer idx = Math.mod(
          Math.abs(Crypto.getRandomInteger()),
          chars.length()
        );
        randStr += chars.substring(idx, idx + 1);
        System.debug('randomstringLead:' + randStr);
      }

      l.Public_Id__c = randStr;
      updateLeads.add(l);
      randStr = '';
    }
    update updateLeads;
    System.debug('LeadList:' + updateLeads);
  }
}
