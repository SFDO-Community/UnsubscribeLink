@isTest
private class UUIDBatchJobTest {
  @TestSetup
  static void setupTestData() {
    // Arrange: Create test data for Contacts and Leads with null UUID fields
    List<Contact> contacts = new List<Contact>();
    List<Lead> leads = new List<Lead>();

    for (Integer i = 0; i < 200; i++) {
      contacts.add(
        new Contact(
          FirstName = 'Test',
          LastName = 'McTester ' + i,
          Public_Id__c = null // Field to hold the UUID
        )
      );
      leads.add(
        new Lead(
          FirstName = 'Test',
          LastName = 'McLeader ' + i,
          Company = 'Test Company',
          Public_Id__c = null // Field to hold the UUID
        )
      );
    }

    // Insert test records
    insert contacts;
    insert leads;
  }

  @isTest
  static void testBatchJobForContacts() {
    // Arrange
    List<Contact> contactsBefore = [
      SELECT Id, Public_Id__c
      FROM Contact
      WHERE Public_Id__c = NULL
    ];
    System.assertEquals(
      200,
      contactsBefore.size(),
      'Should have 200 contacts with null UUIDs before the batch job.'
    );

    // Act: Run the batch job for Contacts
    UUIDBatchJob batchJob = new UUIDBatchJob(
      'Contact',
      'Public_Id__c',
      'Unsubscribe all'
    );
    Test.startTest();
    Database.executeBatch(batchJob, 200);
    Test.stopTest();

    // Assert: Check that all Contacts now have a generated UUID
    List<Contact> contactsAfter = [
      SELECT Id, Public_Id__c, UnsubscribeLinkContact__c
      FROM Contact
      WHERE Public_Id__c != NULL
    ];

    System.assertEquals(
      200,
      contactsAfter.size(),
      'All contacts should have a generated UUID after the batch job.'
    );
    for (Contact c : contactsAfter) {
      System.assertNotEquals(
        null,
        c.Public_Id__c,
        'Public_Id__c should not be null after the batch job.'
      );
      System.assertEquals(
        36,
        c.Public_Id__c.length(),
        'Public_Id__c should be a valid UUID of 36 characters.'
      );
      System.assertNotEquals(
        null,
        c.UnsubscribeLinkContact__c,
        'Unsubscribe link should be generated.'
      );
    }
  }

  @isTest
  static void testBatchJobForLeads() {
    // Arrange
    List<Lead> leadsBefore = [
      SELECT Id, Public_Id__c
      FROM Lead
      WHERE Public_Id__c = NULL
    ];
    System.assertEquals(
      200,
      leadsBefore.size(),
      'Should have 200 leads with null UUIDs before the batch job.'
    );

    // Act: Run the batch job for Leads
    UUIDBatchJob batchJob = new UUIDBatchJob(
      'Lead',
      'Public_Id__c',
      'Unsubscribe all'
    );
    Test.startTest();
    Database.executeBatch(batchJob, 200);
    Test.stopTest();

    // Assert: Check that all Leads now have a generated UUID
    List<Lead> leadsAfter = [
      SELECT Id, Public_Id__c, UnsubscribeLinkLead__c
      FROM Lead
      WHERE Public_Id__c != NULL
    ];
    System.assertEquals(
      200,
      leadsAfter.size(),
      'All leads should have a generated UUID after the batch job.'
    );
    for (Lead l : leadsAfter) {
      System.assertNotEquals(
        null,
        l.Public_Id__c,
        'Public_Id__c should not be null after the batch job.'
      );
      System.assertEquals(
        36,
        l.Public_Id__c.length(),
        'Public_Id__c should be a valid UUID of 36 characters.'
      );
      System.assertNotEquals(
        null,
        l.UnsubscribeLinkLead__c,
        'Unsubscribe link should be generated.'
      );
    }
  }

  // Test the error handling when an invalid object type is passed
  @isTest
  static void testInvalidObjectType() {
    Test.startTest();
    try {
      UUIDBatchJob invalidBatchJob = new UUIDBatchJob(
        'InvalidObject',
        'Public_Id__c',
        'Unsubscribe all'
      );
      Database.executeBatch(invalidBatchJob, 200);
      System.assert(
        false,
        'An exception should have been thrown for invalid object type.'
      );
    } catch (UUIDBatchJob.UUIDBatchException e) {
      System.assertEquals(
        'Object type must be Contact or Lead',
        e.getMessage()
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testUnsubscribeLinkGeneration() {
    // Arrange: Run the batch job and check unsubscribe link generation
    UUIDBatchJob batchJob = new UUIDBatchJob(
      'Contact',
      'Public_Id__c',
      'Unsubscribe all'
    );
    Test.startTest();
    Database.executeBatch(batchJob, 200);
    Test.stopTest();

    // Assert: Verify unsubscribe links are generated for all contacts
    List<Contact> contactsAfter = [
      SELECT Id, Public_Id__c, UnsubscribeLinkContact__c
      FROM Contact
      WHERE Public_Id__c != NULL
    ];
    for (Contact c : contactsAfter) {
      System.assertNotEquals(
        null,
        c.UnsubscribeLinkContact__c,
        'Unsubscribe link should not be null after batch execution.'
      );
    }
  }

  @isTest
  static void testUnsubscribeLinkGenerationLead() {
    // Arrange: Run the batch job and check unsubscribe link generation
    UUIDBatchJob batchJob = new UUIDBatchJob(
      'Lead',
      'Public_Id__c',
      'Unsubscribe all'
    );
    Test.startTest();
    Database.executeBatch(batchJob, 200);
    Test.stopTest();

    // Assert: Verify unsubscribe links are generated for all contacts
    List<Lead> leadsAfter = [
      SELECT Id, Public_Id__c, UnsubscribeLinkLead__c
      FROM Lead
      WHERE Public_Id__c != NULL
    ];
    for (Lead l : leadsAfter) {
      System.assertNotEquals(
        null,
        l.UnsubscribeLinkLead__c,
        'Unsubscribe link should not be null after batch execution.'
      );
    }
  }
}
