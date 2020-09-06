/**
 * Created by Ankit.Bhardwaj on 4/03/2020.
 */

@IsTest
public class TEST_Flow_PSSCaseCreation {

    @TestSetup static void setUpTempCaseData() {
        Account acc = new Account();

        acc.Client_ID__c = '123456';
        acc.Name = 'Test Account';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'testcontact@myob.com';
        con.AccountId = acc.Id;
        insert con;

        AccountContactRelation accountContactRelation = [SELECT Primary_Contact__c FROM AccountContactRelation WHERE AccountId = :acc.Id AND ContactId = :con.Id];
        accountContactRelation.Primary_Contact__c = true;
        update accountContactRelation;

        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Record';
        con1.Email = 'testrecord@myob.com';
        insert con1;

        MYOB_Temporary_Case_Object__c temporaryCaseObject = new MYOB_Temporary_Case_Object__c();

        temporaryCaseObject.First_Name__c = 'Test';
        temporaryCaseObject.Last_Name__c = 'Record';
        temporaryCaseObject.Email_Address__c = 'testrecord@myob.com';
        temporaryCaseObject.Practice_Web_Product__c = 'AU Tax Product';
        temporaryCaseObject.Practice_Web_Sub_Product__c = 'MYOB AE Tax';
        temporaryCaseObject.Client_Id__c = '123456';
        insert temporaryCaseObject;

        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;

//Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

//Create ContentDocumentLink
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = temporaryCaseObject.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        insert cdl;
    }

    @IsTest static void updateTempCase() {
        MYOB_Temporary_Case_Object__c tempObject = [SELECT Id,Trigger_Case_Creation__c FROM MYOB_Temporary_Case_Object__c];
        System.debug(tempObject.Id);
        tempObject.Trigger_Case_Creation__c = true;
        update tempObject;

        List<Case> cs = [SELECT Id FROM Case];
        Integer count = cs.size();
        System.assertEquals(count, 1);
    }

    @IsTest static void updateTempCase1() {
        MYOB_Temporary_Case_Object__c temporaryCaseObject = new MYOB_Temporary_Case_Object__c();

        temporaryCaseObject.First_Name__c = 'Test';
        temporaryCaseObject.Last_Name__c = 'Record';
        temporaryCaseObject.Email_Address__c = 'testrecord@myob.com';
        temporaryCaseObject.Practice_Web_Product__c = 'Client Accounting';
        temporaryCaseObject.Practice_Web_Sub_Product__c = 'MYOB AE/AO Corporate Compliance';
        temporaryCaseObject.Client_Id__c = '123456';
        insert temporaryCaseObject;

        MYOB_Temporary_Case_Object__c tempObject = [SELECT Id,Trigger_Case_Creation__c FROM MYOB_Temporary_Case_Object__c where Id = :temporaryCaseObject.Id];
        System.debug(tempObject.Id);
        tempObject.Trigger_Case_Creation__c = true;
        update tempObject;

        List<Case> cs = [SELECT Id FROM Case];
        Integer count = cs.size();
        System.assertEquals(count, 1);
    }


}