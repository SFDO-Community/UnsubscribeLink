//Test by Jessie Rymph included with unmanaged package Unsubscribe Link from AppExchange & Salesforce Labs.
//February 2024
    //test the Unsubscribe Lead flow that looks for all leads with an email address
    //and marks them Email Opt Out = true
    //How it actually works: Screen flow Unsubscribe Link launches the subflow, Unsubscribe Lead
    //Params passed: Email
    
@istest
public without sharing class UnsubscribeLeadsTest {

    
    @isTest public static void testUnsubscribeLeadsFlow(){
        //create Test Data
        String emailAdd = 'mfm@exactlyright.com';
        Lead karen = new Lead (LastName='Kilgarriff', Email= emailAdd, Company = 'Exactly Right');
        Lead georgia = new Lead (LastName='Hardstark', Email= emailAdd, Company = 'My Favorite Murder');
        Lead steven = new Lead (LastName='Morris', Email= emailAdd, Company ='Purrcast');
        List <Lead> newLeads = new List <Lead> {karen, georgia, steven};
        insert newLeads;

        //pass values into the Flow
        Map<String, String> params = new Map <String,String>();
        params.put('Email',emailAdd);
        
        //pass params to the flow
        Flow.Interview.Unsubscribe_Leads ucFlow = new Flow.Interview.Unsubscribe_Leads(params);
        
        //launch the Flow
        ucFlow.start();
        //assert that the test records were unsubscribed
        List<Lead> leads = [SELECT Id FROM Lead WHERE Email = :emailAdd AND HasOptedOutOfEmail = true ];
        System.assertEquals(3,leads.size(),'three leads should be unsubscribed');
        system.debug('list:' + leads);
    }
}