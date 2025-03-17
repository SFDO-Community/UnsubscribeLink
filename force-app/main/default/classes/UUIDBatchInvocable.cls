public with sharing class UUIDBatchInvocable {
  @InvocableMethod(
    label='Run UUID Batch Job'
    description='Invokes the batch job to generate UUIDs for Leads or Contacts where the specified field is null'
  )
  public static void runUUIDBatch(List<BatchJobParameters> parameters) {
    if (!parameters.isEmpty()) {
      BatchJobParameters param = parameters[0];
      Integer size = (param.batchSize != null) ? param.batchSize : 200;

      UUIDBatchJob uuidBatch = new UUIDBatchJob(
        param.objectType,
        param.fieldName,
        param.linkText
      );
      Database.executeBatch(uuidBatch, size);
    }
  }

  public class BatchJobParameters {
    @InvocableVariable(
      required=true
      label='Object Name'
      description='API name of the object (Contact or Lead)'
    )
    public String objectType;

    @InvocableVariable(
      required=true
      label='UUID Field Name'
      description='API name of the UUID field'
    )
    public String fieldName;

    @InvocableVariable(
      required=false
      label='Batch Size'
      description='Number of records to process in each batch (default 200)'
    )
    public Integer batchSize;

    @InvocableVariable(
      required=false
      label='Link text'
      description='The friendly name of the URL for the Unsubscribe Link'
    )
    public String linkText;
  }
}
