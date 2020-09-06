@isTest public class ContentDocumentTriggerTest {
    @isTest static void caseAfterInsertTest() {
        Case randomCase = new Case(Subject = 'ContentDocumentTriggerTest');
        insert randomCase;
		ContentVersion contentVersion = new ContentVersion(PathOnClient = 'PathOnClient', VersionData = Blob.valueOf('Test'));
		insert contentVersion;
        ContentVersion createdContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        ContentDocumentLink randomContentDocumentLink = 
            new ContentDocumentLink(
                ContentDocumentId = createdContentVersion.ContentDocumentId, 
                LinkedEntityId = randomCase.Id,
                ShareType = 'V'
            );
        JCFS.JiraTriggerTestHelper.testAfterInsert(randomContentDocumentLink);
    }
}