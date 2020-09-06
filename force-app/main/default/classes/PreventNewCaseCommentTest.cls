@IsTest
public class PreventNewCaseCommentTest {
	@IsTest
    static void testPreventNewCaseComment(){
        Account ac = new Account(Name = 'TestAccount');
        insert ac;
        Contact ct = new Contact (LastName='Ln1', FirstName='fn1', AccountId=ac.Id);
        insert ct;
        Case cs = new Case (AccountId=ac.Id, ContactId=ct.Id, Primary_Category__c = 'Billing & Finance', Categ__c = 'Cancellations', Serial_Number__c = '1212121', Cancellation_Reason__c ='Nothing', Cancellation_Reason_Competitor__c='Closure of Business', Refund_Required__c = 'No', Description = 'Testing');
		insert cs;
        CaseComment cc = new CaseComment(ParentId = cs.Id, CommentBody = 'testing' );
        
        Test.startTest();
        
        List<CaseComment> caseCommentList =[SELECT Id FROM CaseComment WHERE ParentId =: cs.Id];
        System.assertEquals(caseCommentList.size(), 0);
        
        try {
        	insert cc;
            //throw new MyException('An exception should have been thrown by the trigger but was not.'); // 1. If we get to this line it means an error was not added and the test class should throw an exception here. 2. MyException class extends Exception. 
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Because we are retiring Case Comment, please use Chatter to leave new comment. Thank you!') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }         
	    Test.stopTest();
    }
}