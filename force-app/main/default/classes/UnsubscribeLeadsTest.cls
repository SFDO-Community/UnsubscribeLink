@istest
public without sharing class UnsubscribeLeadsTest {
  public User adminUser;
  @isTest
  public static void leadsTest() {
    testDataFactory.createLeads();
    testDataFactory.setUpUser();
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
  @isTest
  public static void leadsBulkTest() {
    testDataFactory.createBulkLeads();
    testDataFactory.setUpUser();
    User adminUser = [SELECT id FROM User WHERE Alias = 'Seattle'];
    System.runAs(adminUser) {
      Lead returnOneLead = [SELECT Email FROM Lead LIMIT 1];
      String emailAddress = returnOneLead.email;
      Map<String, String> params = new Map<String, String>();
      params.put('Email', emailAddress);
      //pass params to the flow
      List<Lead> leadsBeforeTheFlow = [
        SELECT Id
        FROM Lead
        WHERE Email = :emailAddress AND HasOptedOutOfEmail = TRUE
      ];

      Test.startTest();

      Flow.Interview.Unsubscribe_Leads ucFlow = new Flow.Interview.Unsubscribe_Leads(
        params
      );
      //launch the Flow
      ucFlow.start();
      //assert that the test records were unsubscribed
      Test.stopTest();
      System.assertEquals(
        0,
        leadsBeforeTheFlow.size(),
        '0 leads should be unsubscribed'
      );
      List<Lead> updatedLeads = [
        SELECT Id
        FROM Lead
        WHERE Email = :emailAddress AND HasOptedOutOfEmail = TRUE
      ];
      System.assertEquals(
        200,
        updatedLeads.size(),
        '200 leads should be unsubscribed'
      );
      system.debug('list:' + updatedLeads);
    }
  }
}
