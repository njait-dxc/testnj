/**
 * @author alexvolkov
 * @date 21/10/2019
 * @description Common Utility class for generic methods
 */

public with sharing class UtilityClass_MYOB
{
    /**
    * @description Construct an OutputLabel component with unescaped HTML (XSS vulnerability alert workaround)
    * Please note that this method ONLY hides the Security Risk alert and is only to be used where the Security Risk alerts are false positives (e.g. escape=false on a string that was already escaped before)
    * @param pValue Label text value
    * @return Component.Apex.OutputLabel
    */
    public static Component.Apex.OutputLabel getUnescapedLabelComp(String pValue)
    {
        Component.Apex.OutputLabel vLabelComp = new Component.Apex.OutputLabel(escape = false);
        vLabelComp.value = pValue;
        return vLabelComp;
    }

    /**
    * @description Method to check if fields in SOQL query have Read permission
    * @param objectName name of the object
    * @param fields set of field names
    * @return Boolean
    */
    public static Boolean checkFLSPermissions(String objectName, Set<String> fields) {
        Boolean isAccessible = true;
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, SObjectField> fieldsByName =  objectType.getDescribe().fields.getMap();
        for(String field : fields) {
            if(!fieldsByName.get(field).getDescribe().isAccessible()) {
                return false;
            }
        }
        return isAccessible;
    }
    /**
   * This method tells if current job is running in async job context or not
   * @Author : Nikhil Jaitly
   * @CreatedDate : 04/06/2020
   */
   public static Boolean isAsync() {
     return System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled();
   }
   
   /**
   * This method gets support settings
   * @Author : Nikhil Jaitly
   * @CreatedDate : 29/06/2020
   */
  public static Support_Setting__mdt getSupportSetting(String settName) {
    Support_Setting__mdt sett;
    for(Support_Setting__mdt ss : [SELECT Id, Value__c
                                   FROM Support_Setting__mdt 
                                   WHERE MasterLabel = :settName]) {
      sett = ss;                               
    }
    return sett;
  }
    
     /**
   * This method gets support settings
   * @Author : Nikhil Jaitly
   * @CreatedDate : 25/08/2020
   */
  public static PublishEvents__mdt getPublishEventsSetting(String pubEvent) {
    PublishEvents__mdt pbEvent;
    for(PublishEvents__mdt pe : [SELECT Id, CreateEvents__c
                                   FROM PublishEvents__mdt 
                                   WHERE MasterLabel = :pubEvent]) {
      pbEvent = pe;                               
    }
    return pbEvent;
  } 
    
    
    
}