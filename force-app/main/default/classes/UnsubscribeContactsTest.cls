//Test by Jessie Rymph included with unmanaged package Unsubscribe Link from AppExchange & Salesforce Labs.
//April 14, 2021
//test the Unsubscribe Contacts flow that looks for all contacts with an email address
//and marks them Email Opt Out = true
//How it actually works: Screen flow Unsubscribe Link launches the subflow, Unsubscribe Contacts.
//Params passed: Email 

@isTest
public without sharing class UnsubscribeContactsTest {
    
    @isTest public static void testUnsubscribeContactsFlow(){
        //create Test Data
        String emailAdd = 'waitwait@npr.org';
        Account newA = new Account (Name= 'NPR.org');
        Account newB = new Account (Name= 'KUOW.org');
        Account newC = new Account (Name= 'KCTS9');
        List <Account> newAccounts = new List <Account> {newA, newB, newC};
        insert newAccounts;
        
        Contact bob = new Contact (LastName='Sagal', Email= emailAdd, AccountId = newA.id);
        Contact paula = new Contact (LastName='Poundstone', Email= emailAdd, AccountId = newB.id);
        Contact maz = new Contact (LastName='Jobrani', Email= emailAdd, AccountId = newC.id);
        List <Contact> newContacts = new List <Contact>{bob, paula, maz};
        insert newContacts;

        //pass values into the Flow
        Map<String, String> params = new Map <String,String>();
        params.put('Email',emailAdd);
        
        //pass params to the flow
        Flow.Interview.Unsubscribe_Contacts ucFlow = new Flow.Interview.Unsubscribe_Contacts(params);
        
        Test.startTest();
        //launch the Flow
        ucFlow.start();
        Test.stopTest();
        //assert that the test records were unsubscribed
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :emailAdd AND HasOptedOutOfEmail = true ];
        System.assertEquals(3,contacts.size(),'three contacts should be unsubscribed');
        system.debug('list:' + contacts);
    }
    
    @IsTest public static void UnsubscribeContactsBulkTest (){
        String emailAdd = 'waitwait@npr.org';
        Account newA = new Account (Name= 'NPR.org');
        insert newA;
        List<Contact> cons = new List<Contact>();
        for (Integer i=0; i<200; i++) {
            Contact c = new Contact(
                LastName = 'Contact ' + i, Email = emailadd, AccountId= newA.id
            );
            cons.add(c);
        }
        insert cons;
        //pass values into the Flow
        Map<String, String> params = new Map <String,String>();
        params.put('Email',emailAdd);
        
        //pass params to the flow
        Flow.Interview.Unsubscribe_Contacts ucFlow = new Flow.Interview.Unsubscribe_Contacts(params);
        
        Test.startTest();
        //launch the Flow
        ucFlow.start();
        Test.stopTest();
        //assert that the test records were unsubscribed
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :emailAdd AND HasOptedOutOfEmail = true ];
        System.assertEquals(200,contacts.size(),'200 contacts should be unsubscribed');
        //system.debug('list:' + contacts);
    }
}