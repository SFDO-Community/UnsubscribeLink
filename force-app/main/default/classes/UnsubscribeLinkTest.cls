//test by Jessie Rymph included with unmanaged package Unsubscribe Link from AppExchange & Salesforce Labs.
// May 2024
@isTest
global class UnsubscribeLinkTest {
    
    @isTest global static void findUnsubscribeRecord () {
        //Look for Unsubscribe record. 
        //it exists. yay!
        
        //Look for Unsubscribe record.
        //Does not exist. Boo. 
        //        //query for the unsubscribe link custom metadata type with a blank TestCase.
        Test.startTest();
        List<Unsubscribe_Link__mdt> metadata = [SELECT Id FROM Unsubscribe_Link__mdt WHERE masterLabel = 'Unsubscribe' ];        
        Test.stopTest();
                System.assertEquals(1,metadata.size(),'1 record with "Unsubscribe" as the masterlabel should exist or the Unsubscribe Link package fails.');
        system.debug('list:' + metadata);
        

        }
    
    }