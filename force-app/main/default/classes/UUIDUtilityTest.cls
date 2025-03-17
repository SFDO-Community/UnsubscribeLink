@isTest
private class UUIDUtilityTest {
    
    @isTest
    static void testGenerateUUIDsForRecords() {

        // Arrange
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 10; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'McTester' + i));
        }
        insert contacts;
        
        // Act
        Test.startTest();
        UUIDUtility.generateUUIDsForRecords(contacts, 'Public_Id__c');
        Test.stopTest();
        
        // Assert
        for (Contact c : contacts) {
            System.assertNotEquals(null, c.Public_Id__c, 'Public_Id__c should not be null');
            System.assertEquals(36, c.Public_Id__c.length(), 'Public_Id__c should be a valid UUID');
        }
    }
    
    @isTest
    static void testGeneratedPublicUUIDForSingleRecord() {

        // Arrange
        Contact contact = new Contact(
            FirstName = 'Tester',
            LastName = 'McTester');
        insert contact;
        
        // Act
        Test.startTest();
        UUIDUtility.generatedPublicUUIDForSingleRecord(contact, 'Public_Id__c');
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, contact.Public_Id__c, 'Public_Id__c should not be null');
        System.assertEquals(36, contact.Public_Id__c.length(), 'Public_Id__c should be a valid UUID');
    }
    
    @isTest
    static void testGeneratedPublicUUIDForSingleRecordWithExistingUUID() {

        // Arrange
        String existingUUID = UUIDUtility.generateUUID();
        Contact contact = new Contact(
            FirstName = 'Tester',
            LastName = 'McTest', 
            Public_Id__c = existingUUID);
        insert contact;
        
        // Act
        Test.startTest();
        UUIDUtility.generatedPublicUUIDForSingleRecord(contact, 'Public_Id__c');
        Test.stopTest();
        
        // Assert
        System.assertEquals(existingUUID, contact.Public_Id__c, 'Public_Id__c should not change if it already exists');
    }
    
    @isTest
    static void testGenerateUUID() {
        // Act
        Test.startTest();
        String uuid1 = UUIDUtility.generateUUID();
        String uuid2 = UUIDUtility.generateUUID();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, uuid1, 'Generated UUID should not be null');
        System.assertEquals(36, uuid1.length(), 'Generated UUID should be 36 characters long');
        System.assertNotEquals(uuid1, uuid2, 'Generated UUIDs should be unique');
    }
}