// Written by Jon Sayer of Data Geeks Lab
// April 2022
// jon@datageekslab.com
// 
// This class creates functionality for a random string to be generated and used within a Flow. 

public with sharing class GenerateRandomString {
    @InvocableMethod(label='Generate Random Text String' description='Returns a random string of text at the provided length.')
    public static List<FlowOutputs> generateRandomStringInvoke(List<FlowInputs> input){
        List<FlowOutputs> results = new List<FlowOutputs>();
        for(FlowInputs i : input){
            FlowOutputs outWrap = new FlowOutputs();
            outWrap.out = generateRandomString(i.len);
        	results.add(outWrap);
        }
        return results;
    }

	public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    
    //input details that comes to apex from flow
    public class FlowInputs{
        @InvocableVariable
        public Integer len;
    }
    
    //input details that comes to apex from flow
    public class FlowOutputs{
        @InvocableVariable
        public String out;
    }
}