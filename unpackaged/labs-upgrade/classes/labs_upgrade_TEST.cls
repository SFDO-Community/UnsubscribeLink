/**
 * Tests the labs_upgrade_BATCH class
 */

@isTest
public with sharing class labs_upgrade_TEST {
    

    //create a contact and 2 leads
    //contact and one lead have test@email.com, the other lead has email@test.com
    //all have an unsubscribe record
    @TestSetup
    static void makeData(){
        List<Lead> testleads = new List<Lead>();
        testleads.add(new Lead(LastName = 'Test1', email = 'test@email.com', company = 'TestCompany1'));
        testleads.add(new Lead(LastName = 'Test2', email = 'email@test.com', company = 'TestCompany2'));
        insert testleads;

        Contact testcontact = new Contact(LastName = 'Testcontact', email = 'test@email.com');
        insert testcontact;

        List<jrsl_ul_Unsubscribe__c> oldUnsubscribes = new List<jrsl_ul_Unsubscribe__c>();
        oldUnsubscribes.add(new jrsl_ul_Unsubscribe__c(jrsl_ul_Lead__c= testleads[0].Id, jrsl_ul_Unsubscribe_Email__c = testleads[0].email));
        oldUnsubscribes.add(new jrsl_ul_Unsubscribe__c(jrsl_ul_Lead__c= testleads[1].Id, jrsl_ul_Unsubscribe_Email__c = testleads[1].email));
        oldUnsubscribes.add(new jrsl_ul_Unsubscribe__c(jrsl_ul_Contact__c= testcontact.Id, jrsl_ul_Unsubscribe_Email__c = testcontact.email));

        insert oldUnsubscribes;
    }

    //test running the batch directly
    @isTest
    static void testBatchExecution() {

        //no additional setup needed aside from older SF labs records existing
        Test.startTest();
        Database.executeBatch(new labs_upgrade_BATCH());
        Test.stopTest();

        //batch will have completed, check number of records (3) and values
        Map<Id, jrsl_ul_Unsubscribe__c> oldUnsubscribeMap = new Map<Id, jrsl_ul_Unsubscribe__c>([Select Id, jrsl_ul_Lead__c, jrsl_ul_Contact__c, jrsl_ul_Status__c, jrsl_ul_Unsubscribe_Email__c from jrsl_ul_Unsubscribe__c]);
        List<UnsubscribeLnk__Unsubscribe__c> newUnsubscribes = new List<UnsubscribeLnk__Unsubscribe__c>();
        newUnsubscribes = [Select Id, UnsubscribeLnk__lead__c, UnsubscribeLnk__contact__c, UnsubscribeLnk__status__c, UnsubscribeLnk__unsubscribe_email__c, Migrated_Record_Id__c from UnsubscribeLnk__Unsubscribe__c];

        Assert.areEqual(3, newUnsubscribes.size(), 'There should be 3 new unsubscribe records to match the old record count.');
        for (UnsubscribeLnk__Unsubscribe__c newUnsub : newUnsubscribes) {
            Assert.isNotNull(newUnsub.Migrated_Record_Id__c, 'Migrated record Id should be populated');
            Assert.isTrue(oldUnsubscribeMap.containsKey(newUnsub.Migrated_Record_Id__c), 'Migrated record Id should match an old Unsubscribe record');
            jrsl_ul_Unsubscribe__c oldUnsub = oldUnsubscribeMap.get(newUnsub.Migrated_Record_Id__c);

            Assert.areEqual(oldUnsub.jrsl_ul_Contact__c, newUnsub.UnsubscribeLnk__contact__c, 'Contact lookup does not match');
            Assert.areEqual(oldUnsub.jrsl_ul_Lead__c, newUnsub.UnsubscribeLnk__lead__c, 'Lead lookup does not match');
            Assert.areEqual(oldUnsub.jrsl_ul_Status__c, newUnsub.UnsubscribeLnk__status__c, 'Unsubscribe status does not match');
            Assert.areEqual(oldUnsub.jrsl_ul_Unsubscribe_Email__c, newUnsub.UnsubscribeLnk__unsubscribe_email__c, 'Unsubscribe status does not match');
        }

    }

    //test invoking the batch via invocable action
    @isTest
    static void testInvocableAction() {

        labs_upgrade_BATCH.executeRequest req = new labs_upgrade_BATCH.executeRequest();
        req.batchsize = 1000;

        Test.startTest();
        List<Boolean> batchresults = labs_upgrade_BATCH.executeMigrationBatch(new List<labs_upgrade_BATCH.executeRequest>{ req });
        Test.stopTest();

        //confirm that the invocable action successfully enqueued the batch and returned a success boolean
        Assert.areEqual(1, batchresults.size(), 'Should only have one result');
        Assert.isTrue(batchresults[0]);
    }
}