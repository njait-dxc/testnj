/*
    Date            : 27-10-2016
    Author          : SMS Management & Technology
    Description     : Unit test class for LP_BatchUtil
*/
@IsTest
public with sharing class LP_BatchUtil_UT {
    
    // Test for retreiving access token
    @IsTest static void testGetTokenPass() {
        LP_Resource__c resource = new LP_Resource__c();
        resource.Name = 'e4139687-3ec7-4371-bfb0-f638c353347c';
        insert resource;
   
        String accesstoken;
        try {
            accesstoken = LP_BatchUtil.getToken('707p000000FmbOlAAJ','LP_OutboundPartnerBatch');
            System.assertEquals(accesstoken != null, false);
        } catch(Exception e) {
            List<LP_Error_Log__c> lstErr = [SELECT Id FROM LP_Error_Log__c];
            System.assertEquals(accesstoken == null, true);
            System.assertEquals(lstErr.size(),1,true);
        }
    }
    
    // Test for posting data to loyalty service
    @IsTest static void testPostData() {
        LP_Resource__c resource = new LP_Resource__c();
        resource.Name = 'e4139687-3ec7-4371-bfb0-f638c353347c';
        insert resource;

        String accesstoken;
        Integer respStatus;
        String activitydata = '{"Name" : "Test Activity","LP_Agreement_End_Date" : "21/12/2016","LP_Agreement_Start_Date" : "21/12/2017","LP_End_of_Grace_Period" : "80","LP_Next_Status" : "Gold","LP_Parent_Archie_Client_Id" : "ARCH-1001","LP_Partner_Archie_Client_Id" : "ARCH-1003","LP_Partner_GUID" : "GUID-ABC-1001","LP_Partner_Trading_Name" : "Test Company","LP_Points" : 40,"LP_Points_to_upgrade" : 30,"LP_Program_Agreement" : "Current","LP_Start_of_Grace_Period" : "21/11/2016","LP_Status" : "Silver"}';
    
        try {
            accesstoken = LP_BatchUtil.getToken('707p000000FmbOlAAJ','LP_OutboundPartnerBatch');
            System.assertEquals(accesstoken != null, false);
            
            //Test.setMock(HttpCalloutMock.class, new LP_APIMockServiceImpl());
            respStatus = LP_BatchUtil.postData('POST','Loyalty_Service_Transactions',accesstoken,activitydata);
            
            System.assertEquals(respStatus,200,true);
            System.debug('+++++++++++++++++++++++ resp code ' + respStatus);

        } catch(Exception e) {
            System.assertNotEquals(respStatus,200,true);
            System.debug('+++++++++++++++++++++++ resp code ' + respStatus);

        }
    }
    
    public static testMethod void testEmail() {
        User runningUser = LP_UnitTestFactory.createUser();
        insert runningUser;
        
        System.runAs(runningUser) {
            
            LS_Email_Group__c objEmail = new LS_Email_Group__c();
            objEmail.Name = 'test_support_group@myob.com';
            insert objEmail;
            
            Integer emailbefore = Limits.getEmailInvocations();
            
            try {
                LP_BatchUtil.sendEmail('Partner job from Loyalty Engine to Service','707p000000FmbOlAAJ',true);
                System.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
            } catch(Exception e) {
                
            }
        }
    }
}