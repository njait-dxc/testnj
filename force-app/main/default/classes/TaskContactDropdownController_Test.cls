/**************************************************************************************************
* Name               : TaskContactDropdownController_Test                                         *
* Description        : Test Class for TaskContactDropdownController class                         *
* Created Date       : 02/05/2020                                                                 *
* Created By         : Nikhil Jaitly                                                              *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR    DATE            COMMENTS                                                     *
* 1.0      Nikhil    02/05/2020      Initial Draft.                                               * 
**************************************************************************************************/
@isTest
public class TaskContactDropdownController_Test {
	
    @isTest
    private static void Test_GetContacts(){
        
        Account acc=new Account( Name = 'testAccount' );
        insert acc;
        
        Contact con1 = new Contact( LastName = 'Test Con1', AccountId = acc.Id );
        insert con1;
        
        Contact con2 = new Contact( LastName = 'Test Con2', AccountId = acc.Id );
        insert con2;
        
        Task tsk=new Task( WhatId= acc.Id, WhoId = con1.Id );
        insert tsk;
        
        List< TaskContactDropdownController.ContactInfoWrapper > lstConWrap = TaskContactDropdownController.getContacts( tsk.Id );
        system.assertEquals( true, lstConWrap.size()>0 );
    }
    
    @isTest
    private static void Test_UpdateTask(){
        
        Account acc=new Account( Name = 'testAccount' );
        insert acc;
        
        Contact con1 = new Contact( LastName = 'Test Con1', AccountId = acc.Id );
        insert con1;
        
        Contact con2 = new Contact( LastName = 'Test Con2', AccountId = acc.Id );
        insert con2;
        
        Task tsk=new Task( WhatId= acc.Id, WhoId = con1.Id );
        insert tsk;
        
        TaskContactDropdownController.updateTask( tsk.Id, con2.Id );
        
        Task t = [ SELECT Id, WhatId, WhoId FROM Task WHERE Id = :tsk.Id ];
        system.assertEquals( con2.Id, t.WhoId );
    }
}