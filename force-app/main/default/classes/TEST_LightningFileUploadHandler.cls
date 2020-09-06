@IsTest
public class TEST_LightningFileUploadHandler 
{
    @IsTest
    static void testExtension()
    {
        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;          
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Account ac = new Account(Name= 'Account Test');
        insert ac;
        
        Contentdocumentlink cdl = new Contentdocumentlink(LinkedEntityId = ac.id, ContentDocumentId = documents[0].Id, ShareType= 'V', Visibility = 'AllUsers');
		insert cdl;
    
        Test.startTest();
        List <ContentDocument> listCD = MYOB_LightningFileUploadHandler.getFiles(ac.id);
        system.assertEquals(1, listCD.size());
        MYOB_LightningFileUploadHandler.deleteFile(documents[0].id);
        listCD = MYOB_LightningFileUploadHandler.getFiles(ac.id);
        system.assertEquals(0, listCD.size());
        Test.stopTest();             
    }
}