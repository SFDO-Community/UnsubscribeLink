public class jrsl_unsubscribeInVoke {

    
//primary source https://www.biswajeetsamal.com/blog/create-or-update-custom-metadata-type-using-apex/

//I update a custom metadata type from Flow with an invocable action because I can't do it directly. 
    
    //Flow screen takes information and passes to this invocable method
    @InvocableMethod (label='Create Unsubscribe Record 2023'description='CreateUnsubscribe')
    
    //pass a list of records from the flow, but it's actually just one record
    //the type of variable being passed is a record variable of a custom metadatatype
    public static void Unsubscribe(List<jrsl_ul_Unsubscribe_Link__mdt> recordPassed) {
        //declare a new map
        Map<String, Object> metadataFieldValueMap = new Map<String, Object>();
        //add values to the map of Field Name on CMT and value passed in from the Flow
        metadataFieldValueMap.put('jrsl_ul_Our_Organization__c', recordPassed[0].jrsl_ul_Our_Organization__c);
        metadataFieldValueMap.put('jrsl_ul_Site_Domain__c', recordPassed[0].jrsl_ul_Site_Domain__c);
        metadataFieldValueMap.put('jrsl_ul_Campaign_Type__c', recordPassed[0].jrsl_ul_Campaign_Type__c);
        metadataFieldValueMap.put('jrsl_ul_Enable_Preference_Center__c', recordPassed[0].jrsl_ul_Enable_Preference_Center__c);
		metadataFieldValueMap.put('jrsl_ul_type_in_Unsubscribe__c', recordPassed[0].jrsl_ul_type_in_Unsubscribe__c);
		metadataFieldValueMap.put('jrsl_ul_Error_Email_Recipients__c', recordPassed[0].jrsl_ul_Error_Email_Recipients__c);
		metadataFieldValueMap.put('jrsl_ul_Opt_in_Status__c', recordPassed[0].jrsl_ul_Opt_in_Status__c);
		metadataFieldValueMap.put('jrsl_ul_Opt_Out_Status__c', recordPassed[0].jrsl_ul_Opt_Out_Status__c);
		metadataFieldValueMap.put('jrsl_ul_Send_Confirmation_Email__c', recordPassed[0].jrsl_ul_Send_Confirmation_Email__c);

        
        //call the class and method to update the CMT
        jrsl_customMetaDataUtils.updateCustomMetadata('jrsl_ul_Unsubscribe_Link__mdt', 'Unsubscribe','Unsubscribe', metadataFieldValueMap);
    }
}