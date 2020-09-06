/**
 * Created by Ankit.Bhardwaj on 13/02/2020.
 */

@IsTest
private class TEST_MYOBService_BLAccountCancellation {
    @TestSetup static void setUpData()
    {
        Case ca = new Case(Subject ='Test Controller Acct Case');
        ca.Primary_Category__c ='Onboarding Request';
        ca.Categ__c ='BL - Essentials';
        ca.Sub_Category__c ='Migration Services';
        insert ca;

    }

    @IsTest static void callBanklinkCancellator()
    {
        Case cs = [Select Id from Case];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MYOBServicesMockResponse());
        MYOBService_BLAccountCancellation.callBanklinkCancellator(cs.Id);
        Test.stopTest();
    }
}