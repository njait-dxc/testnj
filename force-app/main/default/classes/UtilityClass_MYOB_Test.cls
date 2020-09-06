/**
 * @author alexvolkov
 * @date 21/10/2019
 * @description Test class for UtilityClass_MyOB
 */

@IsTest
public with sharing class UtilityClass_MYOB_Test
{
  static testMethod void testGetLabelComp()
  {
    System.assert(UtilityClass_MYOB.getUnescapedLabelComp('<font color="blue">'+ 'TestString' + '</font>'+';<br/>')!=null, 'No component returned');
  }

  @IsTest
  static void testFLSPermissions() {
    Set<String> fields = new Set<String>{'Phone','Email'};
    Boolean status = UtilityClass_MYOB.checkFLSPermissions('Contact', fields);
    System.assertEquals(true,status);
  }
    
    @IsTest
    static void testSupportSetting(){
        String sett = 'Support_Setting__mdt';
        Support_Setting__mdt sptSetting = UtilityClass_MYOB.getSupportSetting(sett);
       
    }
    
    @IsTest
    static void testIsSync(){
        Boolean result = UtilityClass_MYOB.isAsync();
    }
    
    @IsTest
    static void testPlatformEventsPublishing(){
        String pbEvent = 'PublichEvents__mdt';
        PublishEvents__mdt raisePbEvents = UtilityClass_MYOB.getPublishEventsSetting(pbEvent);
    }
    
}