public class customMetaDataUtils implements Metadata.DeployCallback {
  //https://www.biswajeetsamal.com/blog/create-or-update-custom-metadata-type-using-apex/

  //Interface method
  public void handleResult(
    Metadata.DeployResult result,
    Metadata.DeployCallbackContext context
  ) {
    if (result.status == Metadata.DeployStatus.Succeeded) {
      //Success
      System.debug('Success Result-' + result);
    } else {
      //Failed
      System.debug('Failed Result-' + result);
    }
  }

  //Create Custom Metadata record
  public static void createCustomMetadata(
    String metdataName,
    String label,
    Map<String, Object> metadataFieldValueMap
  ) {
    String recordDevName = label.replaceAll(' ', '_');
    Metadata.CustomMetadata cMetadata = new Metadata.CustomMetadata();
    cMetadata.fullName = metdataName + '.' + recordDevName;
    cMetadata.label = label;

    for (String key : metadataFieldValueMap.keySet()) {
      Metadata.CustomMetadataValue cMetadataValue = new Metadata.CustomMetadataValue();
      cMetadataValue.Field = key;
      cMetadataValue.Value = metadataFieldValueMap.get(key);
      cMetadata.values.add(cMetadataValue);
    }

    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(cMetadata);
    jrsl_CustomMetadataUtils callback = new jrsl_CustomMetadataUtils();
    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
  }

  //Update Custom Metadata record
  public static void updateCustomMetadata(
    String metdataName,
    String recordDevName,
    String label,
    Map<String, Object> metadataFieldValueMap
  ) {
    Metadata.CustomMetadata cMetadata = new Metadata.CustomMetadata();
    cMetadata.fullName = metdataName + '.' + recordDevName;
    cMetadata.label = label;

    for (String key : metadataFieldValueMap.keySet()) {
      Metadata.CustomMetadataValue cMetadataValue = new Metadata.CustomMetadataValue();
      cMetadataValue.Field = key;
      cMetadataValue.Value = metadataFieldValueMap.get(key);
      cMetadata.values.add(cMetadataValue);
    }

    Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
    mdContainer.addMetadata(cMetadata);
    jrsl_CustomMetadataUtils callback = new jrsl_CustomMetadataUtils();
    Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
  }
}
