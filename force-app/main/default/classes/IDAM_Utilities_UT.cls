@IsTest
public with sharing class IDAM_Utilities_UT {   
    // Test for retreiving access token
    @IsTest static void testGetTokenPass() {
      
        String accesstoken;
        try {   
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());                     
                accesstoken = IDAM_Utilities.getToken('test123');
                System.debug('TokenFetchedfromIDAM-------' + accesstoken);
                System.assertEquals(accesstoken,'abcde');
            
        } catch(Exception e) {
            System.assertEquals(accesstoken == null, true);
        }
    }
  }