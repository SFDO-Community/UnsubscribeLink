@IsTest
public class SingleRecordUUIDInvocableTest {

    @TestSetup
    static void setupTestData() {

        // Arrange: Create a test Contact record for testing the UUID generation
        Contact testContact = new Contact(
            FirstName = 'TestFirst',
            LastName = 'TestLast'
        );
        insert testContact;

        // Create a test Lead record for additional test coverage
        Lead testLead = new Lead(
            FirstName = 'TestLeadFirst',
            LastName = 'TestLeadLast',
            Company = 'TestCompany'
        );
        insert testLead;
    }

    @IsTest
    static void testGenerateUUID() {

        // Arrange: Retrieve the created Contact and Lead IDs
        List<Contact> testContacts = [SELECT Id FROM Contact LIMIT 1];
        List<Lead> testLeads = [SELECT Id FROM Lead LIMIT 1];
        
        // Act: Call the invocable method with both Contact and Lead IDs
        List<Id> recordIds = new List<Id>();
        recordIds.add(testContacts[0].Id);
        recordIds.add(testLeads[0].Id);
        
        List<SingleRecordUUIDInvocable.UUIDResult> results;
        Test.startTest();
        results = SingleRecordUUIDInvocable.generateUUID(recordIds);
        Test.stopTest();
        
        // Assert: Ensure that two UUIDs were generated (one for Contact, one for Lead)
        System.assertEquals(2, results.size(), 'Two UUIDs should have been generated');
        System.assertNotEquals(null, results[0].generatedUUID, 'First UUID should not be null');
        System.assertNotEquals(null, results[1].generatedUUID, 'Second UUID should not be null');
    }

    @IsTest
    static void testGenerateUUIDWithEmptyList() {

        // Arrange: Prepare an empty list of record IDs
        List<Id> emptyRecordIds = new List<Id>();

        // Act: Call the invocable method with the empty list
        List<SingleRecordUUIDInvocable.UUIDResult> results;
        Test.startTest();
        results = SingleRecordUUIDInvocable.generateUUID(emptyRecordIds);
        Test.stopTest();

        // Assert: Ensure that no UUIDs are generated when the input is an empty list
        System.assertEquals(0, results.size(), 'No UUIDs generated');
    }
}