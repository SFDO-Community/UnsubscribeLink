//Test by Jessie Rymph included with unmanaged package Unsubscribe Link from AppExchange & Salesforce Labs.
//May 28, 2024
//test the Unsubscribe Contacts flow that looks for all contacts with an email address
//and marks them Email Opt Out = true
//How it actually works: Screen flow Unsubscribe Link Quick launches the subflow, Unsubscribe Contacts.

@istest
public without sharing class UnsubscribeContactsTest {
  public User adminUser;
  @isTest
  public static void contactsTest() {
    testDataFactory.setUpUser();
    User adminUser = [SELECT id FROM User WHERE Alias = 'Seattle'];
    System.runAs(adminUser) {
      testDataFactory.createContacts();
      Contact returnOneContact = [SELECT Email FROM Contact LIMIT 1];
      String emailAddress = returnOneContact.email;
      Map<String, String> params = new Map<String, String>();
      params.put('Email', emailAddress);
      //pass params to the flow
      Test.startTest();

      Flow.Interview.Unsubscribe_Contacts ucFlow = new Flow.Interview.Unsubscribe_Contacts(
        params
      );
      //launch the Flow
      ucFlow.start();
      //assert that the test records were unsubscribed
      Test.stopTest();
      List<Contact> updatedContacts = [
        SELECT Id
        FROM Contact
        WHERE Email = :emailAddress AND HasOptedOutOfEmail = TRUE
      ];
      System.assertEquals(
        3,
        updatedContacts.size(),
        'three leads should be unsubscribed'
      );
      system.debug('list:' + updatedContacts);
    }
  }
  @isTest
  public static void contactsBulkTest() {
    testDataFactory.createBulkContacts();
    testDataFactory.setUpUser();
    User adminUser = [SELECT id FROM User WHERE Alias = 'Seattle'];
    System.runAs(adminUser) {
      Contact returnOneContact = [SELECT Email FROM Contact LIMIT 1];
      String emailAddress = returnOneContact.email;
      Map<String, String> params = new Map<String, String>();
      params.put('Email', emailAddress);
      //get initial unsubscribe contact count
      List<Contact> contactsBeforeTheFlow = [
        SELECT Id
        FROM Contact
        WHERE Email = :emailAddress AND HasOptedOutOfEmail = TRUE
      ];

      Test.startTest();

      Flow.Interview.Unsubscribe_Contacts ucFlow = new Flow.Interview.Unsubscribe_Contacts(
        params
      );
      //launch the Flow
      ucFlow.start();
      //assert that the test records were unsubscribed
      Test.stopTest();
      List<Contact> updatedContacts = [
        SELECT Id
        FROM Contact
        WHERE Email = :emailAddress AND HasOptedOutOfEmail = TRUE
      ];
      System.assertEquals(
        0,
        contactsBeforeTheFlow.size(),
        'no contacts should be unsubscribed'
      );
      System.assertEquals(
        200,
        updatedContacts.size(),
        'two hundred leads should be unsubscribed'
      );
    }
  }
}
