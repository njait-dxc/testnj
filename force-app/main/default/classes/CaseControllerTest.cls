@isTest(seeAllData=false)
public class CaseControllerTest {

    @isTest
    public static void setupData(){
        Account acc=new Account( Name = 'testAccount' );
        insert acc;
            
        Contact con1 = new Contact( LastName = 'Test Con1', AccountId = acc.Id );
        insert con1;
        
        Task tsk=new Task();
        tsk.WhatId = acc.Id ;
        tsk.WhoId = con1.Id ;
        insert tsk;
    }

    public static testmethod void getTaskData_TestMethod1(){
        Task tsk=new Task();
        tsk.Subject='sub';
        tsk.Description='desc';
        insert tsk;
       
        id tid=tsk.id;
    	Map<String,String> res=new Map<String,String>();
        res=caseController.getTaskData(tid);
        system.assertEquals(true, res.get('Subject') == 'sub');
    }

    public static testmethod void getgetCaseRecordType_TestMethod1(){
        Map<String,String> res=new Map<String,String>();
        res=caseController.getCaseRecordType();
        system.assertEquals(true, res.get('name') != null);
    } 

    public static testmethod void getAccountName_TestMethod1(){
       Account acc=new Account();
       acc.name='accname';
       insert acc;
       
        id aid=acc.id;
    	Map<String,String> res=new Map<String,String>();
        res=caseController.getAccountName(aid);
        system.assertEquals(true, res.get('name') == 'accname');
    }

    public static testmethod void getContactName_TestMethod1(){
        Account acc=new Account();
        acc.name='accname';
        insert acc;
        Contact cont=new Contact();
        cont.AccountId=acc.id;
        cont.LastName='lname';
        insert cont;
        
        Map<String,String> res=new Map<String,String>();
        res=caseController.getContactName(cont.id);
        system.assertEquals(true, res.get('name') == 'lname');
    }

     public static testmethod void getContactIdDetails_TestMethod1(){
        Account acc=new Account();
        acc.name='accname';
        insert acc;
        id aid=acc.id;
         
        Contact cont=new Contact();
        cont.AccountId=aid;
        cont.LastName='lname';
        insert cont;
         
        Case cse=new Case();
        cse.AccountId=aid;
        cse.Subject='abc';
        insert cse;
    	
        List<Contact> res=new List<Contact>();
        res=caseController.getContactIdDetails('acc',aid);
        system.assertEquals(true, res.get(0) != null);
         
        List<Contact> cres=new List<Contact>();
        cres=caseController.getContactIdDetails('case',cse.Id);
        system.assertEquals(true, cres.get(0) != null);
    }
    
    public static testmethod void createCase_TestMethod1(){

        Account acc=new Account();
        acc.name='accname';
        insert acc;
        id aid=acc.id;
        
        Contact cont=new Contact();
        cont.AccountId=aid;
        cont.LastName='lname';
        insert cont;
    
        Case caseObj=new Case();
        caseObj.AccountId=aid;
        caseObj.ContactId=cont.id;
        // caseObj.Product_Type__c= 'Corporate Admin';
        // caseObj.PSSSubProduct__c= 'MYOB Corporate Admin';
        // caseObj.Nature_of_Client_enquiry__c= 'Account Management - CA';
        // caseObj.How_many_users_affected__c='One';
        // caseObj.Severity__c= 'Cosmetic';
        // caseObj.Feature__c='2FA - CAA';
        // caseObj.Function__c= 'Email undelivered';
        // caseObj.Subject='testsubject';
        // caseObj.Description='testdescription';
        // caseObj.Case_Group__c= 'PS Support - Client Accounting';
        // caseObj.Origin='Phone';
        // caseObj.Status= 'Open';
        // caseObj.Sub_Status__c= 'Awaiting Forms';
        // caseObj.Call_Object_Identifier__c= '';
        // caseObj.Knowledge_Requirement__c= '';
        // caseObj.Business_Case__c= 'TestBusiness';
        // caseObj.Partner_or_Client_issue__c= 'Client';
        // caseObj.Was_there_a_self_service_portal_to_facil__c= 'No';
        // caseObj.Is_the_Service_Internal_External_to_MYOB__c= '';
        // caseObj.Incident_Number__c= '12345';
        // caseObj.Resolution_Code__c= 'Process Change';
        // caseObj.Resolution__c= 'test resolution';
        
        Task tsk=new Task();
        tsk.Subject='sub';
        tsk.Description='desc';
        insert tsk;
        
        String res=caseController.createCase(caseObj,tsk.id);
        system.assertEquals(true, res != null);
    }
     public static testmethod void preloadPKL_TestMethod1(){
   
    	Map<String,String> res=new Map<String,String>();
        res=caseController.preloadPKL('How_many_users_affected__c');
        system.assertEquals(true, res.get('All')=='All');
    }
    
   public static testmethod void Test_getDependentPicklist(){
       
    CaseController.PicklistWrapper res=new CaseController.PicklistWrapper();
        res=caseController.getDependentPicklist('Case','Product_Type__c','PSSSubProduct__c');
    }    

    @isTest
    private static void Test_updateTask(){
        Account acc1=new Account( Name = 'testAccount1' );
        insert acc1;

        Account acc2=new Account( Name = 'testAccount2' );
        insert acc2;
        
        Contact con1 = new Contact( LastName = 'Test Con1', AccountId = acc1.Id );
        insert con1;

        Contact con2 = new Contact( LastName = 'Test Con2', AccountId = acc2.Id );
        insert con2;
        
        Task tsk=new Task( WhatId= acc1.Id, WhoId = con1.Id );
        insert tsk;
        
        CaseController.updateTask( tsk.Id, acc2.Id, con2.Id );
    }

    @isTest
    private static void Test_getPickListElementsHttp(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PSS_Support_Case').getRecordTypeId();
        CaseController.getPickListElementsHttp( recordTypeId ,'Case_Group__c' );
    }
   
}