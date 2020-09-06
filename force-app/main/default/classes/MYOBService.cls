public with sharing class MYOBService
{
    public static MYOB_Service_API__mdt getMYOBService(String apiName)
    {
        String environment = getEnvironment();

        List <MYOB_Service_API__mdt> myobServiceAPIs = [SELECT Id, Endpoint__c, Resource_Id__c FROM MYOB_Service_API__mdt WHERE MasterLabel = :apiName AND Environment__c = :environment];

        if (myobServiceAPIs.size() != 1)
        {
            throw new ErrorException('Service information for ' + apiName + ' could not be found in MYOB Service API custom metadata.');
        }

        return myobServiceAPIs.get(0);
    }

    private static String getEnvironment()
    {
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        System.debug('IsSandbox'+isSandbox);
        return isSandbox ? 'SIT' : 'Production';
        //return 'Production';
    }

    public class ErrorException extends Exception {}
}