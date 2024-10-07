@isTest
private class UUIDBatchInvocableTest {
    
    @TestSetup
    static void setupTestData() {
        List<Contact> contacts = new List<Contact>();
        
        for (Integer i = 0; i < 500; i++) {
            contacts.add(new Contact(
                FirstName = 'Tester',
                LastName = 'McTest ' + i));
        }
        
        insert contacts;
    }
    
    private static void assertResults(Integer expectedBatchSize) {
        // Verify Contacts
        List<Contact> updatedContacts = [SELECT Id, Public_Id__c FROM Contact];
        System.assertEquals(500, updatedContacts.size(), 'Incorrect number of contacts');
        for (Contact c : updatedContacts) {
            System.assertNotEquals(null, c.Public_Id__c, 'Contact Public_Id__c should not be null');
            System.assertEquals(36, c.Public_Id__c.length(), 'Contact Public_Id__c should be a valid UUID');
        }
        
        // Verify batch execution
        List<AsyncApexJob> batchJobs = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'UUIDBatchJob' AND JobType = 'BatchApex'];
        System.assertEquals(1, batchJobs.size(), 'Expected one batch job execution');
    }
}