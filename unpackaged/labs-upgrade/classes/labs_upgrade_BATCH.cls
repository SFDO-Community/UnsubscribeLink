/**
 * This batch class is meant to be run once, after an org has installed the Unsubscribe Link package from the Salesforce Communinity Commons
 * after already having used the Salesforce Labs app
 * 
 * This class copies Unsubscribe objects from the unmanaged Salesforce Labs object to the packaged Unsubscribe object
 */

public with sharing class labs_upgrade_BATCH implements Database.Batchable<sObject> {

    Integer errorCount;
    
    @InvocableMethod(label='Migrate Unsubscribes' description='Kick off a batch that copies Unsubscribe objects from the Salesforce Labs package into the new managed package object')
    public static List<Boolean> executeMigrationBatch(List<ExecuteRequest> requests) {
        List<Boolean> successful = new List<Boolean>();
        for (ExecuteRequest r : requests) {
            if (r.batchsize == null) {
                r.batchsize = 200;
            } else if (r.batchsize > 2000) {
                r.batchsize = 2000;
            }
            try {
                Database.executeBatch(new labs_upgrade_BATCH(), r.batchsize);
                successful.add(true);
            } catch (Exception e) {
                successful.add(false);
            }
        }
    
        return successful;
    }

    public class executeRequest {
        @InvocableVariable(required=false description='Choose an apex batch size <= 200. If left blank, will default to 200' label='Batch Size')
        public Integer batchsize;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id, jrsl_ul_Contact__c, jrsl_ul_Lead__c, jrsl_ul_Status__c, jrsl_ul_Unsubscribe_Email__c from jrsl_ul_Unsubscribe__c';
        errorCount = 0;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<UnsubscribeLnk__Unsubscribe__c> newUnsubscribeList = new List<UnsubscribeLnk__Unsubscribe__c>();
        for (jrsl_ul_Unsubscribe__c obj : (List<jrsl_ul_Unsubscribe__c>)scope) {
            newUnsubscribeList.add(new UnsubscribeLnk__Unsubscribe__c(Migrated_Record_Id__c = obj.Id, UnsubscribeLnk__contact__c = obj.jrsl_ul_Contact__c, UnsubscribeLnk__lead__c = obj.jrsl_ul_Lead__c, UnsubscribeLnk__unsubscribe_email__c = obj.jrsl_ul_Unsubscribe_Email__c, UnsubscribeLnk__status__c = obj.jrsl_ul_status__c));
        }
        Database.SaveResult[] results = Database.insert(newUnsubscribeList,false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                errorCount +=1;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        //send an email to the running user that the job has finished
        Messaging.SingleEmailMessage finishmessage = new Messaging.SingleEmailMessage();
        finishmessage.setSubject('Unsubscribe Link batch process migration complete');
        String bodytext = 'The batch migration of Unsubscribe records is complete.';
        if(errorCount > 0) {
            bodytext += 'There were '+errorCount+' Unsubscribe records that were not transferred successfully. You should delete or archive the successfully transferred records and then attempt this process again.';
        } else {
            bodytext += 'You may now delete or otherwise archive your prior Unsubscribe records.';
        }
        finishmessage.setPlainTextBody(bodytext);
        finishmessage.setToAddresses(new String[] { UserInfo.getUserId() });

        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ finishmessage });
        } catch (Exception e) {
            //possibly email is not enabled in this org (due to it being a sandbox)
            System.debug(
                LoggingLevel.ERROR,
                'Error sending completion email: ' + e.getMessage()
            );  
        }
    }

}