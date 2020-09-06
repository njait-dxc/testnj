/**************************************************************************************************
* Name               : TEST_SelectAttachmentsController                                           *
* Description        : Test class for Controller class for SelectAttachment Lightning component   *
* Created Date       : 16/03/2020                                                                 *
* Created By         : Nikhil Jaitly                                                               *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR            DATE            COMMENTS                                             *
* 1.0      Nikhil Jaitly     16/03/2020      Initial Draft.                                       * 
**************************************************************************************************/
@isTest
public class TEST_SelectAttachmentsController {
    
    /****************************************************************************************************
    * @Description        : Function to test save file in chunks functionality and get attachment       * 
    * @Author             : Nikhil Jaitly                                                                *
    * @Last Modified By   : Nikhil Jaitly                                                                *
    * @Last Modified On   : 16/03/2020                                                                  * 
    * @Params             : null                                                                        *
    * @Return             : void                                                                        *
    *****************************************************************************************************/
    @isTest
    private static void testSaveChunk(){
        
        Account ac = new Account(Name = 'TestAccount');
        insert ac;
        Contact ct = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = ac.Id);
        insert ct;
        Case cs = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Nothing', Cancellation_Reason_Competitor__c = 'Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
        insert cs;
        
        List< ContentVersion > lstContentVersion = new List< ContentVersion >();
        
        Test.startTest();
        Id FileId = SelectAttachmentsController.saveChunk( cs.Id, 'Test File', 'Dummy Data', 'pdf', null );
        SelectAttachmentsController.saveChunk( cs.Id, 'Test File', 'Dummy Data 1', 'pdf', FileId );
        lstContentVersion = SelectAttachmentsController.getAttachments( cs.Id );
        Test.stopTest();
        
        system.assertEquals( true, lstContentVersion.size() > 0 );
    }
    
    /****************************************************************************************************
    * @Description        : Function to test/cover get attachments if no attachment is available        * 
    * @Author             : Nikhil Jaitly                                                               *
    * @Last Modified By   : Nikhil Jaitly                                                               *
    * @Last Modified On   : 16/03/2020                                                                  * 
    * @Params             : null                                                                        *
    * @Return             : void                                                                        *
    *****************************************************************************************************/
    @isTest
    private static void testGetAttachmentElsePart(){
        
        Account ac = new Account(Name = 'TestAccount');
        insert ac;
        Contact ct = new Contact (LastName = 'Ln1', FirstName = 'fn1', AccountId = ac.Id);
        insert ct;
        Case cs = new Case (AccountId = ac.Id, ContactId = ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c = 'Nothing', Cancellation_Reason_Competitor__c = 'Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
        insert cs;
        
        List< ContentVersion > lstContentVersion = new List< ContentVersion >();
        
        Test.startTest();
        lstContentVersion = SelectAttachmentsController.getAttachments( cs.Id );
        Test.stopTest();
        
        system.assertEquals( true, lstContentVersion == null );
    }
}