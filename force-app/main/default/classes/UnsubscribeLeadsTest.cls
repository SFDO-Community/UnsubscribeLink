@istest
public without sharing class UnsubscribeLeadsTest {
  public User adminUser;
  @isTest
  public static void leadsTest() {
    testDataFactory.createLeads();
    User adminUser = [SELECT id FROM User WHERE Alias = 'Seattle'];
    System.runAs(adminUser) {
      Lead returnOneLead = [SELECT Email FROM Lead LIMIT 1];
      String emailAddress = returnOneLead.email;
      Map<String, String> params = new Map<String, String>();
      params.put('Email', emailAddress);
      //pass params to the flow
      Test.startTest();

      Flow.Interview.Unsubscribe_Leads ucFlow = new Flow.Interview.Unsubscribe_Leads(
        params
      );
      //launch the Flow
      ucFlow.start();
      //assert that the test records were unsubscribed
      Test.stopTest();
      List<Lead> updatedLeads = [
        SELECT Id
        FROM Lead
        WHERE Email = :emailAddress AND HasOptedOutOfEmail = TRUE
      ];
      System.assertEquals(
        3,
        updatedLeads.size(),
        'three leads should be unsubscribed'
      );
      system.debug('list:' + updatedLeads);
    }
  }
}
