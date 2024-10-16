public class UUIDUtility {
    public static void generateUUIDsForRecords(List<SObject> records, String uuidFieldName) {
        for (SObject record : records) {
            // Set the UUID field if it's null
            if (record.get(uuidFieldName) == null) {
                // Use EncodingUtil.urlDecode to prevent any automatic encoding
                record.put(uuidFieldName, EncodingUtil.urlDecode(generateUUID(), 'UTF-8'));
            }
        }
    }

    // Generates a UUID for a single record
    public static void generatedPublicUUIDForSingleRecord(SObject record, String uuidFieldName) {
        if (record.get(uuidFieldName) == null) {
            record.put(uuidFieldName, EncodingUtil.urlDecode(generateUUID(), 'UTF-8'));
        }
    }

    // Helper method for generating a UUID without involving any specific record
    public static String generateUUID() {
        return UUID.randomUUID().toString();
    }
}