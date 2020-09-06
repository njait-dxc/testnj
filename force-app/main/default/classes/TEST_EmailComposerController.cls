/**************************************************************************************************
* Name               : TEST_EmailComposerController                                               *
* Description        : Test class for Controller class for EmailComposer Lightning component      *
* Created Date       : 16/03/2020                                                                 *
* Created By         : Nikhil Jaitly                                                              *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR            DATE            COMMENTS                                             *
* 1.0      Nikhil Jaitly     16/03/2020      Initial Draft.                                       * 
**************************************************************************************************/
@isTest
public class TEST_EmailComposerController {

    /****************************************************************************************************
    * @Description        : Function to test Load Email Data functionality                              * 
    * @Author             : Nikhil Jaitly                                                               *
    * @Last Modified By   : Nikhil Jaitly                                                               *
    * @Last Modified On   : 16/03/2020                                                                  * 
    * @Params             : null                                                                        *
    * @Return             : void                                                                        *
    *****************************************************************************************************/
    @isTest
    private static void testLoadEmailData(){
        
        Account ac = new Account(Name = 'TestAccount');
        insert ac;
        Contact ct = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = ac.Id, Email = 'test@test.com');
        insert ct;
        Case cs1 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Nothing', Cancellation_Reason_Competitor__c = 'Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
        insert cs1;
        Case cs2 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Nothing', Cancellation_Reason_Competitor__c = 'Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
        insert cs2;
        
        cs2.ParentId = cs1.Id;
        update cs2;
        
        List< ContentVersion > lstContentVersion = new List< ContentVersion >();
        EmailComposerController.EmailWrapper emailWrap = new EmailComposerController.EmailWrapper();
        
        Test.startTest();
        emailWrap = EmailComposerController.loadEmailData( cs1.Id );
        Test.stopTest();
        
        system.assertNotEquals( null , emailWrap.toAddress );
        //system.assertNotEquals( null , emailWrap.orgWideAddress );
        system.assertNotEquals( null , emailWrap.emailTemps );
        
    }
    
    @isTest
    private static void testFetTemplateDetails(){
        
        EmailTemplate et = new EmailTemplate(); 
        et.isActive = true; 
        et.Name = 'testTemplate'; 
        et.DeveloperName = 'testTemplate' + System.now().getTime(); 
        et.TemplateType = 'text'; 
        et.FolderId = UserInfo.getUserId(); 
        et.Body = 'Test Body'; 
        
        insert et; 
        EmailTemplate emailTemp;
        
        Test.startTest();
        emailTemp = EmailComposerController.getTemplateDetails( et.Id );
        Test.stopTest();
        
        system.assertNotEquals( null , emailTemp );       
    }
    
    /****************************************************************************************************
    * @Description        : Function to test Load Email Data functionality                              * 
    * @Author             : Nikhil Jaitly                                                               *
    * @Last Modified By   : Nikhil Jaitly                                                               *
    * @Last Modified On   : 16/03/2020                                                                  * 
    * @Params             : null                                                                        *
    * @Return             : void                                                                        *
    *****************************************************************************************************/
    @isTest
    private static void testSendEmailApex(){
        
        Account ac = new Account(Name = 'TestAccount');
        insert ac;
        Contact ct = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = ac.Id, Email = 'test@test.com');
        insert ct;
        Case cs1 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Nothing', Cancellation_Reason_Competitor__c = 'Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
        insert cs1;
        Case cs2 = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Nothing', Cancellation_Reason_Competitor__c = 'Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
        insert cs2;
        
        cs2.ParentId = cs1.Id;
        update cs2;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EmailTemplate et = new EmailTemplate(); 
        system.runAs( thisUser ) {
            et.isActive = true; 
            et.Name = 'testTemplate'; 
            et.DeveloperName = 'testTemplate' + System.now().getTime(); 
            et.TemplateType = 'text'; 
            et.FolderId = UserInfo.getUserId(); 
            et.Body = 'Test Body'; 
            
            insert et; 
        }

        OrgWideEmailAddress[] addresses = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        
        EmailComposerController.EmailWrapper emailWrap = new EmailComposerController.EmailWrapper();
        emailWrap.orgWideAddress = addresses[0];
        emailWrap.toAddress = 'test@test.com';
        
        Test.startTest();
        EmailComposerController.sendEmailApex( emailWrap, cs1.Id, et, null );
        Test.stopTest();
        
        
    }
}