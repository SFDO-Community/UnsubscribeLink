@isTest
private class UUIDBatchJobTest {

    @TestSetup
    static void setupTestData() {
        // TO DO: Add custom metadata type or setting to bypass flows that set the Public_Id__c field when running test.
        
        // Arrange: Create test data for Contacts and Leads with null UUID fields
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();

        for (Integer i = 0; i < 200; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'McTester ' + i,
                Public_Id__c = null // Field to hold the UUID
            ));

            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'McLeader ' + i,
                Company = 'Test Company',
                Public_Id__c = null // Field to hold the UUID
            ));
        }

        // Insert test records
        insert contacts;
        insert leads;
    }

    @isTest
    static void testBatchJobForContacts() {
        // Arrange
        List<Contact> contactsBefore = [SELECT Id, Public_Id__c FROM Contact WHERE Public_Id__c = null];
        System.assertEquals(200, contactsBefore.size(), 'Should have 200 contacts with null UUIDs before the batch job.');

        // Act: Run the batch job for Contacts
        UUIDBatchJob batchJob = new UUIDBatchJob('Contact', 'Public_Id__c');
        Test.startTest();
        Database.executeBatch(batchJob, 200); // Set batch size to avoid multiple executions
        Test.stopTest();

        // Assert: Check that all Contacts now have a generated UUID
        List<Contact> contactsAfter = [SELECT Id, Public_Id__c FROM Contact WHERE Public_Id__c != null];
        System.assertEquals(200, contactsAfter.size(), 'All contacts should have a generated UUID after the batch job.');

        for (Contact c : contactsAfter) {
            System.assertNotEquals(null, c.Public_Id__c, 'Public_Id__c should not be null after the batch job.');
            System.assertEquals(36, c.Public_Id__c.length(), 'Public_Id__c should be a valid UUID of 36 characters.');
        }
    }

    @isTest
    static void testBatchJobForLeads() {
        // Arrange
        List<Lead> leadsBefore = [SELECT Id, Public_Id__c FROM Lead WHERE Public_Id__c = null];
        System.assertEquals(200, leadsBefore.size(), 'Should have 200 leads with null UUIDs before the batch job.');

        // Act: Run the batch job for Leads
        UUIDBatchJob batchJob = new UUIDBatchJob('Lead', 'Public_Id__c');
        Test.startTest();
        Database.executeBatch(batchJob, 200); // Set batch size to avoid multiple executions
        Test.stopTest();

        // Assert: Check that all Leads now have a generated UUID
        List<Lead> leadsAfter = [SELECT Id, Public_Id__c FROM Lead WHERE Public_Id__c != null];
        System.assertEquals(200, leadsAfter.size(), 'All leads should have a generated UUID after the batch job.');

        for (Lead l : leadsAfter) {
            System.assertNotEquals(null, l.Public_Id__c, 'Public_Id__c should not be null after the batch job.');
            System.assertEquals(36, l.Public_Id__c.length(), 'Public_Id__c should be a valid UUID of 36 characters.');
        }
    }
}