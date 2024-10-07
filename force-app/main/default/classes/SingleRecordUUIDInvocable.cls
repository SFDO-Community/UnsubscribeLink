public class SingleRecordUUIDInvocable {
    
    // Wrapper class to hold the output UUID
    public class UUIDResult {
        @InvocableVariable
        public String generatedUUID;
    }

    @InvocableMethod(label='Generate UUID' description='Generates a UUID and returns it as an output')
    public static List<UUIDResult> generateUUID(List<Id> recordIds) {
        List<UUIDResult> results = new List<UUIDResult>();

        // Loop through each ID (even though we only generate one UUID per record)
        for (Id recordId : recordIds) {
            
            // Use the UUIDUtility class to generate a UUID without specific record reference
            String generatedUUID = UUIDUtility.generateUUID();

            // Create a new result wrapper
            UUIDResult result = new UUIDResult();
            result.generatedUUID = generatedUUID;

            // Add result to results list
            results.add(result);
        }

        // Return the UUIDResult list
        return results;
    }
}