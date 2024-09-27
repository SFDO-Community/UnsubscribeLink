public class UUIDUtility {

    public static void generateUUIDsForRecords(List<SObject> records, String uuidFieldName) {
        for (SObject record : records) {
            // Set the UUID field if it's null
            if (record.get(uuidFieldName) == null) {
                record.put(uuidFieldName, generateUUID());
            }
        }
    }

    // Generates a UUID for a single record
    public static void generatedPublicUUIDForSingleRecord(SObject record, String uuidFieldName) {
        if (record.get(uuidFieldName) == null) {
            record.put(uuidFieldName, generateUUID());
        }
    }

    // Helper method for generating a UUID without involving any specific record
    public static String generateUUID() {
        return UUID.randomUUID().toString();
    }
}