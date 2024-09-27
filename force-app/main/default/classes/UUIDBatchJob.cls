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