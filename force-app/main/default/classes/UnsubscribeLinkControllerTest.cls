@IsTest
private class UnsubscribeLinkControllerTest {
    
    @testSetup
    static void setupTestData() {
        testDataFactory.createULSetup();
        testDataFactory.createContacts();
        testDataFactory.createLeads();
    }
    
    @IsTest
    static void testNoEmailRecipientId() {
        // Create an instance of the UnsubscribeLinkController
        UnsubscribeLinkController controller = new UnsubscribeLinkController();
        
        // Attempt to get the recipient Id and observe the exception
        try {
            controller.emailRecipientId = null;
        } catch (Exception e) {
            System.assertEquals('Recipient must be a contact or lead to use this component', e.getMessage());
        }
    }
    
    @IsTest
    static void testContact() {
        // Retrieve the test Contact created in the test setup
        Contact testContact = [SELECT Id, Part1_Unsubscribe_Link__c FROM Contact WHERE LastName = 'Sagal' LIMIT 1];
        
        // Create an instance of the UnsubscribeLinkController
        UnsubscribeLinkController controller = new UnsubscribeLinkController();
        
        // Set emailRecipientId to the test Contact's Id
        Test.startTest();
        controller.emailRecipientId = testContact.Id;
        Test.stopTest();
        
        // Get the unsubscribeLinkUrl and unsubscribeLinkTitle
        String unsubscribeLinkUrl = controller.unsubscribeLinkUrl;
        String unsubscribeLinkTitle = controller.unsubscribeLinkTitle;

        // Parse record's link
        List<String> recordLinkParts = testContact.Part1_Unsubscribe_Link__c.split('\\+');
        String recordUrl = recordLinkParts[0];
        String recordTitle = recordLinkParts[1];
        
        // Perform assertions
        System.assertEquals(recordUrl, unsubscribeLinkUrl);
        System.assertEquals(recordTitle, unsubscribeLinkTitle);
    }
    
    @IsTest
    static void testLead() {
        // Retrieve the test Lead created in the test setup
        Lead testLead = [SELECT Id, Part1_Unsubscribe_Link__c FROM Lead WHERE LastName = 'Notaro' LIMIT 1];
        
        // Create an instance of the UnsubscribeLinkController
        UnsubscribeLinkController controller = new UnsubscribeLinkController();
        
        // Set emailRecipientId to the test Lead's Id
        Test.startTest();
        controller.emailRecipientId = testLead.Id;
        Test.stopTest();
        
        // Get the unsubscribeLinkUrl and unsubscribeLinkTitle
        String unsubscribeLinkUrl = controller.unsubscribeLinkUrl;
        String unsubscribeLinkTitle = controller.unsubscribeLinkTitle;
        
        // Parse record's link
        List<String> recordLinkParts = testLead.Part1_Unsubscribe_Link__c.split('\\+');
        String recordUrl = recordLinkParts[0];
        String recordTitle = recordLinkParts[1];
        
        // Perform assertions
        System.assertEquals(recordUrl, unsubscribeLinkUrl);
        System.assertEquals(recordTitle, unsubscribeLinkTitle);
    }
    
    @IsTest
    static void testRunningUser() {
        // Create an instance of the UnsubscribeLinkController
        UnsubscribeLinkController controller = new UnsubscribeLinkController();
        
        try {
            // Set emailRecipientId to the running user's Id
            controller.emailRecipientId = UserInfo.getUserId();
        } catch (Exception e) {
            System.assertEquals('Recipient must be a contact or lead to use this component', e.getMessage());
        }
    }
}