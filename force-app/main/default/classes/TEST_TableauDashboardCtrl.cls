@IsTest
public class TEST_TableauDashboardCtrl
{
    @TestSetup
    static void setup()
    {
        Account testAccount = new Account(Name = 'test', Client_ID__c = '12345', Phone = '0000');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'test', AccountId = testAccount.Id, Phone = '6789');
        insert testContact;
    }

    @IsTest
    static void getObjectDataWithMergeFieldsInOptions()
    {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        String options = '"{"Client ID": "{{Client_ID__c}}","hideTabs":true }"';
        String returnedOptions = TableauDashboardCtrl.getObjectData(testAccount.Id, options);
        System.assert(returnedOptions.contains('12345'));
    }

    @IsTest
    static void getObjectDataWithRelatedObjectFieldInOptions()
    {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        String options = '"{"Client ID": "{{Account.Client_ID__c}}","hideTabs":true }"';
        String returnedOptions = TableauDashboardCtrl.getObjectData(testContact.Id, options);
        System.assert(returnedOptions.contains('12345'));
    }

    @IsTest
    static void getObjectDataWithMultipleMergeFieldsInOptions()
    {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        String options = '"{"Client ID": "{{Account.Client_ID__c}}","Phone":"{{Phone}}","hideTabs":true }"';
        String returnedOptions = TableauDashboardCtrl.getObjectData(testContact.Id, options);
        System.assert(returnedOptions.contains('12345'));
        System.assert(returnedOptions.contains('6789'));
    }

    @IsTest
    static void getObjectDataWithMultipleRelatedObjectFieldsInOptions()
    {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        String options = '"{"Client ID": "{{Account.Client_ID__c}}","Phone":"{{Account.Phone}}","hideTabs":true }"';
        String returnedOptions = TableauDashboardCtrl.getObjectData(testContact.Id, options);
        System.assert(returnedOptions.contains('12345'));
        System.assert(returnedOptions.contains('0000'));
    }

    @IsTest
    static void getObjectDataWithNoMergeFields()
    {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        String options = '"{"Client ID": "9703445","hideTabs":true }"';
        String returnedOptions = TableauDashboardCtrl.getObjectData(testContact.Id, options);
        System.assertEquals(options, returnedOptions);
    }
}