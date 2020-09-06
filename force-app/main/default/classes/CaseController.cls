public class CaseController {
   private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    @AuraEnabled 
    public static Map<String,String> getTaskData(String taskId){
        List<Task> taskDet =[select id, WhatId, CallObject, WhoId, Subject,Description, OwnerId from Task where id=:taskId];
        system.debug(taskDet);
        Map<String,String> taskDMap = new Map<String, String>();
        for(Task tsk : taskDet){
            taskDMap.put('Id',tsk.Id);
            taskDMap.put('WhatId',tsk.WhatId);
            taskDMap.put('CallObject',tsk.CallObject);
            taskDMap.put('WhoId',tsk.WhoId);
            taskDMap.put('Subject',tsk.Subject);
            taskDMap.put('Description',tsk.Description);
            taskDMap.put('OwnerId',tsk.OwnerId);
        }
        return taskDMap;
       
    }
    
    @AuraEnabled 
    public static Map<String,String> getCaseRecordType(){
       List<RecordType> recType =[select id, DeveloperName, name from RecordType where DeveloperName ='PSS_Support_Case'];
       Map<String,String> rTypeDMap = new Map<String, String>();
        for(RecordType r : recType){
            rTypeDMap.put('Id',r.Id);
            rTypeDMap.put('DeveloperName',r.DeveloperName);
            rTypeDMap.put('name',r.name);
        }
        return rTypeDMap;
        
    }
    
    @AuraEnabled 
    public static Map<String,String> getAccountName(String AccId){
       List<Account> acc =[select id, name from Account where Id =:AccId];
       Map<String,String> rTypeDMap = new Map<String, String>();
        for(Account r : acc){
            rTypeDMap.put('Id',r.Id);
            rTypeDMap.put('name',r.name);
        }
        return rTypeDMap;
    }
    
    @AuraEnabled 
    public static Map<String,String> getContactName(String ContId){
       List<Contact> cont =[select id, name from Contact where Id =:ContId];
       Map<String,String> rTypeDMap = new Map<String, String>();
        for(Contact r : cont){
            rTypeDMap.put('Id',r.Id);
            rTypeDMap.put('name',r.name);
        }
        return rTypeDMap;
    }
    
     @AuraEnabled 
    public static List<Contact> getContactIdDetails(String ObjType,String ObjId){
       List<Contact> cont =new List<Contact>();
        If(ObjType=='acc'){
             cont =[select id, name from Contact where Account.Id =:ObjId];
        }
        If(ObjType=='case'){
             List<Case> AccId=[select Account.Id from Case where Id=:ObjId ];
             Case c=AccId.get(0);
            
             cont =[select id, name from Contact where Account.Id=:c.AccountId ];
           
        }

        return cont;
    }
    @AuraEnabled 
    public static Map<String,String> preloadPKL(String pklName){ 
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult=null;
        switch on pklName {
            when 'How_many_users_affected__c' {
                  fieldResult = Case.How_many_users_affected__c.getDescribe();
            }	
            when 'Severity__c' {	
                  fieldResult = Case.Severity__c.getDescribe();
            }
            when 'Case_Group__c' {	
                  fieldResult = Case.Case_Group__c.getDescribe();
            }
            when 'Origin' {	
                  fieldResult = Case.Origin.getDescribe();
            }
            when 'Status' {	
                  fieldResult = Case.Status.getDescribe();
            }
            when 'Sub_Status__c' {	
                  fieldResult = Case.Sub_Status__c.getDescribe();
            }
            when 'Resolution_Code__c' {	
                  fieldResult = Case.Resolution_Code__c.getDescribe();
            }
        }
      
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
        
    }
    
    @AuraEnabled 
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
         
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
 
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public class PicklistWrapper{
    	@AuraEnabled
        public Map<String, List<String>> pickListMap;
        @AuraEnabled
        public String parentFieldLabel;
        @AuraEnabled
        public String childFieldLabel;      
    }
        
    public class PicklistEntryWrapper{
        public String active;
        public String defaultValue;
        public String label;
        public String value;
        public String validFor;
        
    }
    @AuraEnabled
    public static string createCase(Case caseObj,String taskRecordId){
      
      Task task = [SELECT Id, CallObject from Task WHERE ID  = :taskRecordId];
      
      try{
           caseObj.Call_Object_Identifier__c = task.CallObject;
           insert caseObj;
           system.debug(caseObj.Id);
           //Task t=new Task();
           task.WhatId = caseObj.Id;
           task.Status= 'Completed';
           task.id= taskRecordId;
           upsert task;    
           return caseObj.Id;
       }catch (exception e){
             throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String,Object> getPickListElementsHttp(String recordTypeId,String fldName){
     HttpRequest req = new HttpRequest();
     req.setMethod('GET');
     //req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());

     String sessionId;
     if(!test.isRunningTest()){
        sessionId = getSessionIdFromVFPage();
     }
     
     req.setHeader('Authorization', 'OAuth ' +sessionId);  //NJ    
        
     req.setHeader('Content-Type', 'application/json');       
     //req.setEndpoint(URL.getOrgDomainUrl().toExternalForm()+'/services/data/v48.0/ui-api/object-info/Case/picklist-values/'+recordTypeId ); //+'/'+fldName);
     req.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm() +'/services/data/v48.0/ui-api/object-info/Case/picklist-values/'+recordTypeId+'/'+fldName);
     req.setTimeout(120000);
      
       // System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v41.0/ui-api/object-info/'
        
        Http http = new Http();
        
        HTTPResponse res = new HttpResponse();
        
        if(!Test.isRunningTest()){
           res = http.send(req);
        }
        else{
            res.setStatusCode(200);
            res.setBody('{"res":"testresult"}"');
        }
        
      if(res.getStatusCode() == 200){
                        
            //return (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
         
            Map<String,Object> mp=new Map<String, Object>();
            mp=(Map<String,Object>)JSON.deserializeUntyped(res.getBody());
           
            
            return mp;
            
        }
        else{
           Map<String,Object> m= new Map<String,Object>{'Status'=>res.getStatus(),'StatusCode'=>res.getStatusCode()};
        	return m;
            }
       
   }
    
    //NJ for Session ID
    
    public static String getSessionIdFromVFPage() {
     return Page.NJ_SessionId.getContent().toString();
}
  
@AuraEnabled
    public static void updateTask(String taskRecordId, String relateToId, String contactId){
      try
      {
           
           Task t=new Task();
           t.WhatId =relateToId;
           t.WhoId= contactId;
           t.id= taskRecordId;
           upsert t;    
       }
        catch (exception e){
             throw new AuraHandledException(e.getMessage());
        }
    }
}