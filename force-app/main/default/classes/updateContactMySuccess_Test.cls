@IsTest
private class updateContactMySuccess_Test
{
    private static testMethod void updatecontact()
    {
      Account Acct = new Account(Name='Test Account',Client_ID__c='123123123', OwnerId='00528000000JKTC');
      insert Acct;
      Contact Cont = new Contact(AccountId=Acct.Id,LastName='Apex UT LN', FirstName='Apex UT FN',Email='apexUT@test.com');
      insert Cont;
      List<Id> listid=new List<Id>();
      listid.add(Cont.Id);
      updateContactMySuccess.updateContact(listid);
      User user = [SELECT Username FROM User WHERE Email = :Cont.Email];
      System.assertEquals(Cont.Email.toLowerCase(), user.Username);
    }
}