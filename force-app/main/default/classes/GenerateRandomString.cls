// Written by Jon Sayer of Data Geeks Lab
// April 2022
// jon@datageekslab.com
//
// This class creates functionality for a random string to be generated and used within a Flow.

public with sharing class GenerateRandomString {
  @InvocableMethod(
    label='Generate Random Text String'
    description='Returns a random string of text at the provided length.'
  )
  public static List<FlowOutputs> generateRandomStringInvoke(
    List<FlowInputs> input
  ) {
    List<FlowOutputs> results = new List<FlowOutputs>();
    for (FlowInputs i : input) {
      FlowOutputs outWrap = new FlowOutputs();
      //outWrap.out = generateRandomString(i.len);
      outWrap.out = generateRandomString(i.recordId);
      results.add(outWrap);
    }
    return results;
  }

  public static String generateRandomString(String recordId) {
    String randStr = '';
    String algorithmName = 'AES128';
    Blob key = Crypto.generateAesKey(128);
    Blob data = Blob.valueOf(recordId);
    Blob encrypted = Crypto.encryptWithManagedIV(algorithmName, key, data);
    String encryptedString = EncodingUtil.base64Encode(encrypted);
    randStr = EncodingUtil.urlEncode(encryptedString, 'UTF-8');
    return randStr;
  }

  //input details that comes to apex from flow
  public class FlowInputs {
    @InvocableVariable
    public String recordId;
  }

  //input details that comes to apex from flow
  public class FlowOutputs {
    @InvocableVariable
    public String out;
  }
}
