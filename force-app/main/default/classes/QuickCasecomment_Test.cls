@IsTest
private class QuickCasecomment_Test {
    @IsTest
    static void testWithNewCaseComment(){
        List<Case> newCaseList = new List<Case>();
        String subject = 'Request';
        String description = 'Test Desc';
        Account accnt1 = TestDataFactory.createAccount('Alpha', 'Partner_Success_Accounts', '8131725111111', true);
        Contact contact1 = TestDataFactory.createContact('Partner_Success_Contacts', accnt1.Id, true);
        String comment = 'good';
        String isPublic1 = 'true';
        String isPublic2 = 'false';
        Boolean result;

       Case testCase = new Case(
                AccountId = accnt1.Id,
                ContactId = contact1.Id,
                Subject =   subject,
                Description = description,
                IsEscalated = false
        );
        Test.startTest();
        insert testCase;
        CaseComment cc1 = new CaseComment(ParentId = testCase.Id, IsPublished = true, CommentBody = 'test');
        ApexPages.StandardController sc = new ApexPages.StandardController(cc1);
        QuickCasecomment qcc = new QuickCasecomment(sc);
        
        result = QuickCasecomment.CreateComment(testCase.Id, comment, isPublic1);
        System.debug('result:' + result);
        result = QuickCasecomment.CreateComment(testCase.Id, comment, isPublic2);
        
        comment = '1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
        for(Integer i = 0;i<=20; i++ ){
            comment = comment + '1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111';
         }
        result = QuickCasecomment.CreateComment(testCase.Id, comment, isPublic2);
        Test.stopTest();
    }
        
}