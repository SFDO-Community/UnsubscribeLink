// This is currently working for org name and screen1part1. Keep adding in additional variables and seeing if it works.
public class unsubscribeInvocableMethod {
  //primary source https://www.biswajeetsamal.com/blog/create-or-update-custom-metadata-type-using-apex/

  //I update a custom metadata type from Flow with an invocable action because I can't do it directly.

  //Flow screen takes information and passes to this invocable method
  @InvocableMethod(
    label='Create Unsubscribe Record 2024'
    description='CreateUnsubscribe'
  )
  //pass a list of records from the flow, but it's actually just one record
  //the type of variable being passed is a record variable of a custom metadatatype
  public static void Unsubscribe(List<Unsubscribe_Link__mdt> recordPassed) {
    //declare a new map
    system.debug(recordPassed);

    Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
    //add values to the map of Field Name on CMT and value passed in from the Flow
    /*
     metadataFieldValueMap.put(
      'Send_Confirmation_Email__c',
      recordPassed[0].Send_Confirmation_Email__c
    );
    
    metadataFieldValueMap.put(
      'Confirmation_Email__c',
      recordPassed[0].Confirmation_Email__c
    );
    metadataFieldValueMap.put(
      'type_in_Unsubscribe__c',
      recordPassed[0].type_in_Unsubscribe__c
    );
    metadataFieldValueMap.put(
      'Error_Email_Recipients__c',
      recordPassed[0].Error_Email_Recipients__c
    );
    metadataFieldValueMap.put('Link_Text__c', recordPassed[0].Link_Text__c);
    metadataFieldValueMap.put(
      'Org_Wide_Email_Address__c',
      recordPassed[0].Org_Wide_Email_Address__c
    );
    */
    metadataFieldValueMap.put(
      'Our_Organization__c',
      recordPassed[0].Our_Organization__c
    );

    metadataFieldValueMap.put(
      'Screen_1_Part_1__c',
      recordPassed[0].Screen_1_Part_1__c
    );
    /*
    metadataFieldValueMap.put(
      'Screen_1_Part_2__c',
      recordPassed[0].Screen_1_Part_2__c
    );
    metadataFieldValueMap.put(
      'Screen_2_Part_1__c',
      recordPassed[0].Screen_2_Part_1__c
    );
    metadataFieldValueMap.put(
      'Screen_2_Part_2__c',
      recordPassed[0].Screen_2_Part_2__c
    );
    metadataFieldValueMap.put('Screen_3__c', recordPassed[0].Screen_3__c);

    metadataFieldValueMap.put(
      'Site_Domain__c',
      URL.getOrgDomainUrl().toExternalForm()
    );
    
         metadataFieldValueMap.put('Site_Domain__c', recordPassed[0].Site_Domain__c);
            metadataFieldValueMap.put('type_in_Unsubscribe__c', recordPassed[0].type_in_Unsubscribe__c);
            metadataFieldValueMap.put('Error_Email_Recipients__c', recordPassed[0].Error_Email_Recipients__c);
            
*/
    //call the class and method to update the CMT
    customMetaDataUtils.updateCustomMetadata(
      'Unsubscribe_Link__mdt',
      'Unsubscribe',
      'Unsubscribe',
      metadataFieldValueMap
    );
  }
}
