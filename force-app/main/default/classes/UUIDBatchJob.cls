/*
public class UUIDBatchJob implements Database.Batchable<SObject> {
    private String objectType;
    private String fieldName;

    public UUIDBatchJob(String objectType, String fieldName) {
        this.objectType = objectType;
        this.fieldName = fieldName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Get records with null UUID field
        String query = 'SELECT Id, ' + fieldName + ' FROM ' + objectType + ' WHERE ' + fieldName + ' = null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        // Use utility method to generate UUIDs for records
        UUIDUtility.generateUUIDsForRecords(scope, fieldName);
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        // TO DO: Send email notification when batch completes
    }
}
*/

public class UUIDBatchJob implements Database.Batchable<SObject> {
    private String objectType;
    private String fieldName;
    private String unsubscribeLinkField;
    private String siteBaseUrl;
    private static final String SITE_NAME = 'Unsubscribe';
    
    public UUIDBatchJob(String objectType, String fieldName) {
        this.objectType = objectType;
        this.fieldName = fieldName;
        
        // Get the base URL for the experience site
        String partnerURL = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/58.0';
        Integer servicesIndex = partnerURL.indexOf('/services');
        if (servicesIndex != -1) {
            String baseURL = partnerURL.substring(0, servicesIndex + 1);
            this.siteBaseUrl = baseURL.replace('salesforce.com/', 'site.com/' + SITE_NAME + '/s/');
        } else {
            throw new UUIDBatchException('Unable to determine site URL');
        }
        
        // Determine the unsubscribe link field based on object type
        if (objectType.equalsIgnoreCase('Contact')) {
            this.unsubscribeLinkField = 'UnsubscribeLinkContact__c';  // Adjust field name as needed
        } else if (objectType.equalsIgnoreCase('Lead')) {
            this.unsubscribeLinkField = 'UnsubscribeLinkLead__c';
        } else {
            throw new UUIDBatchException('Object type must be Contact or Lead');
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Get records with null UUID field, include UnsubscribeLink field
        String query = 'SELECT Id, ' + fieldName + ', ' + unsubscribeLinkField + 
                      ' FROM ' + objectType + 
                      ' WHERE ' + fieldName + ' = null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try {
            // Generate UUIDs for records
            UUIDUtility.generateUUIDsForRecords(scope, fieldName);
            
            // Generate unsubscribe links using the newly created UUIDs
            for (SObject record : scope) {
                String uuid = (String)record.get(fieldName);
                if (uuid != null) {
                    String unsubscribeLink = generateUnsubscribeLink(uuid);
                    record.put(unsubscribeLinkField, unsubscribeLink);
                }
            }
            
            update scope;
            
        } catch (Exception e) {
            // Log error and send notification
            System.debug(LoggingLevel.ERROR, 'Error in UUIDBatchJob: ' + e.getMessage());
            throw new UUIDBatchException('Error processing records: ' + e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // Get the job details
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                           TotalJobItems, CreatedBy.Email
                           FROM AsyncApexJob 
                           WHERE Id = :bc.getJobId()];
        
        // Send email notification
        String emailBody = String.format('The UUID and Unsubscribe Link generation job for ' + objectType + 's has completed.\n\n' +
                                       'Status: {0}\n' +
                                       'Records Processed: {1}\n' +
                                       'Number of Errors: {2}',
                                       new String[]{
                                           job.Status,
                                           String.valueOf(job.JobItemsProcessed),
                                           String.valueOf(job.NumberOfErrors)
                                       });
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{job.CreatedBy.Email});
        mail.setSubject('UUID Batch Job Complete');
        mail.setPlainTextBody(emailBody);
        
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error sending completion email: ' + e.getMessage());
        }
    }
    
    private String generateUnsubscribeLink(String uuid) {
        return siteBaseUrl + 'unsubscribe?varRecId=' + uuid;
    }
    
    public class UUIDBatchException extends Exception {}
}