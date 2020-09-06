({
    doInit: function(component, event, helper) {        
        
        // Getting the Task and RecordType details
        helper.getTaskData(component, event);
        helper.getCaseRecordType(component, event);
        
        
        //Load non-dependent picklist values on form
       // helper.getPicklistValues(component, event,"Status","v.statusList");
        helper.getPicklistValues(component, event,"How_many_users_affected__c","v.howManyUsersEffectedList");
        helper.getPicklistValues(component, event,"Severity__c","v.severityOfIssueList");
        helper.getPicklistValues(component, event,"Case_Group__c","v.caseGroupList");
        helper.getCaseRTypePicklist(component, event,"Origin","v.caseOriginList");
        helper.getCaseRTypePicklist(component, event,"Status","v.statusList");
        helper.getCaseRTypePicklist(component, event,"Sub_Status__c","v.subStatusList");
        helper.getCaseRTypePicklist(component, event,"Resolution_Code__c","v.resolutionCodeList");
       
        //Getting the Picklist Maps that contain details of Controller and Dependent picklist values
        helper.getMasterPKLMap(component,event,"Status","Sub_Status__c","v.statusPKLMap");
        helper.getMasterPKLMap(component,event,"Product_Type__c","PSSSubProduct__c","v.prodSubPKLMap");
        helper.getMasterPKLMap(component,event,"Product_Type__c","Nature_of_Client_enquiry__c","v.pickListMap");
        helper.getMasterPKLMap(component,event,"Feature__c","Function__c","v.functionPKLMap");
        helper.getMasterPKLMap(component,event,"Nature_of_Client_enquiry__c","Was_there_a_self_service_portal_to_facil__c","v.selfServicePKLMap");
		helper.getMasterPKLMap(component,event,"Nature_of_Client_enquiry__c","Feature__c","v.featurePKLMap");
		helper.getMasterPKLMap(component,event,"Nature_of_Client_enquiry__c","Is_the_Service_Internal_External_to_MYOB__c","v.serviceINTPKLMap");
		helper.getMasterPKLMap(component,event,"Nature_of_Client_enquiry__c","Knowledge_Requirement__c","v.knowledgePKLMap");
		helper.getMasterPKLMap(component,event,"Nature_of_Client_enquiry__c","Partner_or_Client_issue__c","v.partnerIssuePKLMap");
       
        //Getting the values of Product picklist
        var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : component.get("v.objectName"),
            parentField : "Product_Type__c",
            childField : "Nature_of_Client_enquiry__c"
   			}); 
        
        action.setCallback(this, function(response){
         	var status = response.getState();
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();  
                //save response 
                component.set("v.pickListMap",pickListResponse.pickListMap);
                
                // create a empty array for store parent picklist values 
                var parentkeys = []; // for store all map keys 
                var parentField = []; // for store parent picklist value to set on lightning:select. 
                
                // Iterate over map and store the key
                for (var pickKey in pickListResponse.pickListMap) {
                    parentkeys.push(pickKey);
                }
                
                //set the parent field value for lightning:select
                if (parentkeys != undefined && parentkeys.length > 0) {
                   parentField.push('--- None ---');
                }
                
                for (var i = 0; i < parentkeys.length; i++) {
                    parentField.push(parentkeys[i]);
                }  
                // set the parent picklist
                component.set("v.parentList", parentField);
                
            }
            helper.getTaskData(component, event);
            helper.getCaseRecordType(component, event);
      
        // Getting UserId
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.objCase.OwnerId", userId);
       
           
         //component.find("caseGroup").set("v.value","---None---");
         component.find("caseOrigin").set("v.value","Phone");
         component.find("caseSubStatus").set("v.value","In Progress");
         component.find("caseStatus").set("v.value","Open");   
			   
        });
        
        $A.enqueueAction(action);
       
	},

    // Loading dependent picklist values on change of Controller picklist
    caseProductfieldChange : function(component, event, helper) {
        component.set("v.natureValue","");
        helper.getDepPKLValues(component,event,"v.pickListMap","v.childList","caseProduct");
        helper.getDepPKLValues(component,event,"v.prodSubPKLMap","v.subProductList","caseProduct");
	} ,
    
     caseStatusfieldChange : function(component, event, helper) {
        //component.set("v.caseStatus","");
        helper.getDepPKLValues(component,event,"v.statusPKLMap","v.subStatusList","caseStatus");
     
	} ,
    
    // Loading dependent picklist values on change of Controller picklist
    caseNaturefieldChange : function(component, event, helper) {
       component.set("v.natureValue","");
       component.set("v.objCase.Knowledge_Requirement__c","");
       component.set("v.objCase.Business_Case__c","");
       component.set("v.objCase.Partner_or_Client_issue__c","");
       component.set("v.objCase.Was_there_a_self_service_portal_to_facil__c","");
       component.set("v.objCase.Is_the_Service_Internal_External_to_MYOB__c",""); 
       component.set("v.objCase.Incident_Number__c",""); 
        
       helper.getDepPKLValues(component,event,"v.featurePKLMap","v.featureList","caseNature");
       helper.getDepPKLValues(component,event,"v.serviceINTPKLMap","v.serviceINTList","caseNature");
       helper.getDepPKLValues(component,event,"v.knowledgePKLMap","v.knowledgeList","caseNature");
       helper.getDepPKLValues(component,event,"v.partnerIssuePKLMap","v.partnerIssueINTList","caseNature");        
       helper.getDepPKLValues(component,event,"v.selfServicePKLMap","v.selfServeList","caseNature");
       var natureOfEnquiry = component.find("caseNature").get("v.value");
        if(natureOfEnquiry.includes("How To")){
           component.set("v.natureValue","How To");
    	}
    	else if(natureOfEnquiry.includes("Enhancement Request")){
           component.set("v.natureValue","Enhancement Request");
    	}
        else if(natureOfEnquiry.includes("Account Management")){
           component.set("v.natureValue","Account Management");
    	}
		else if(natureOfEnquiry.includes("Billing")){
           component.set("v.natureValue","Billing");
    	}
        else if(natureOfEnquiry.includes("Outage")){
           component.set("v.natureValue","Outage");
    	}
        else{
            console.log(natureOfEnquiry);
        }
    },
    
    // Loading dependent picklist values on change of Controller picklist
    caseFeaturefieldChange : function(component,event,helper){
           helper.getDepPKLValues(component,event,"v.functionPKLMap","v.functionList","caseFeature");
    },
    
    //Creating the Case
    createCaseJs : function(component,event,helper){
        
        var caseObj = component.get("v.objCase");
        var taskObjMap = component.get("v.objTask");
        
        var caseSubject = component.find("caseSubject");
        var caseDescription = component.find("caseDescription");
        var caseProduct = component.find("caseProduct");
        var caseNature = component.find("caseNature");
        var caseHowManyUserAff = component.find("caseHowManyUserAff");
        var caseSeverity = component.find("caseSeverity");
        var caseFeature = component.find("caseFeature");
        var caseFunction = component.find("caseFunction");
        var caseGroup = component.find("caseGroup");
        var caseOrigin = component.find("caseOrigin");
        var caseStatus = component.find("caseStatus");
        var caseSubStatus = component.find("caseSubStatus");
        var caseSubPro    = component.find("caseSubPro"); 
        
        var isValid       =  'true';
        
        // validation check of static fields on the form
        if ( $A.util.isEmpty( caseObj.Subject ) ) {
            caseSubject.set('v.validity', { valid :false, badInput : true});
            caseSubject.showHelpMessageIfInvalid();
            isValid = 'false';
        }

        if ( $A.util.isEmpty( caseObj.Description ) ) {
            caseDescription.set('v.validity', { valid :false, badInput : true});
            caseDescription.showHelpMessageIfInvalid();
            isValid = 'false';
        }
		// Rohit 17/06/2020 Inactivate code for SOE-1074 
        /*console.log(' Product_Type__c values >>> '+component.find('caseProduct').get("v.value"));
        console.log(' caseObj.Product_Type__c  >>> '+caseObj.Product_Type__c);
        if ( $A.util.isEmpty( caseObj.Product_Type__c ) ) {
            console.log(' Inside If Product_Type__c');
            caseProduct.set('v.validity', { valid :false, badInput : true});
            caseProduct.showHelpMessageIfInvalid();
            isValid = 'false';
        }

        if ( $A.util.isEmpty( caseObj.PSSSubProduct__c ) ) {
            caseSubPro.set('v.validity', { valid :false, badInput : true});
            caseSubPro.showHelpMessageIfInvalid();
            isValid = 'false';
        }

        if ( $A.util.isEmpty( caseObj.Nature_of_Client_enquiry__c ) ) {
            caseNature.set('v.validity', { valid :false, badInput : true});
            caseNature.showHelpMessageIfInvalid();
            isValid = 'false';
        }*/
        
        if ( $A.util.isEmpty( caseObj.How_many_users_affected__c ) ) {
            caseHowManyUserAff.set('v.validity', { valid :false, badInput : true});
            caseHowManyUserAff.showHelpMessageIfInvalid();
            isValid = 'false';
        }
       
        if ( $A.util.isEmpty( caseObj.Severity__c ) ) {
            caseSeverity.set('v.validity', { valid :false, badInput : true});
            caseSeverity.showHelpMessageIfInvalid();
            isValid = 'false';
        }
		// Rohit 17/06/2020 Inactivate code for SOE-1074
        /*if ( $A.util.isEmpty( caseObj.Feature__c ) ) {
            caseFeature.set('v.validity', { valid :false, badInput : true});
            caseFeature.showHelpMessageIfInvalid();
            isValid = 'false';
        }

        if ( $A.util.isEmpty( caseObj.Function__c ) ) {
            caseFunction.set('v.validity', { valid :false, badInput : true});
            caseFunction.showHelpMessageIfInvalid();
            isValid = 'false';
        }*/

        console.log(' Case_Group__c >>> '+caseObj.Case_Group__c);
        if ( $A.util.isEmpty( caseObj.Case_Group__c ) ) {
            console.log(' Inside If Case_Group__c');
            caseGroup.set('v.validity', { valid :false, badInput : true});
            caseGroup.showHelpMessageIfInvalid();
            isValid = 'false';
        }

        if ( $A.util.isEmpty( caseObj.Origin ) ) {
            caseOrigin.set('v.validity', { valid :false, badInput : true});
            caseOrigin.showHelpMessageIfInvalid();
            isValid = 'false';
        }

        if ( $A.util.isEmpty( caseObj.Status ) ) {
            caseStatus.set('v.validity', { valid :false, badInput : true});
            caseStatus.showHelpMessageIfInvalid();
            isValid = 'false';
        }
        if ( $A.util.isEmpty( caseObj.Sub_Status__c ) ) {
            caseSubStatus.set('v.validity', { valid :false, badInput : true});
            caseSubStatus.showHelpMessageIfInvalid();
            isValid = 'false';
        }
        console.log( 'isValid >>> '+isValid );
        

        // Check validation on dynamic fields
        var natureValue = component.get("v.natureValue");
        var hasError = "false";
        var errBody = 'Please complete the mentioned fields:'
        
        if( natureValue == 'How To' &&  $A.util.isEmpty( caseObj.Knowledge_Requirement__c ) ){
            errBody += ' Knowledge Requirement,'
            hasError = "true";
        }

        if( natureValue == 'Enhancement Request' &&  $A.util.isEmpty( caseObj.Business_Case__c ) ){
            errBody += ' Business Case,'
            hasError = "true";
        }

        if( natureValue == 'Account Management' &&  $A.util.isEmpty( caseObj.Partner_or_Client_issue__c ) ){
            errBody += ' Partner or Client Issue,'
            hasError = "true";
        }

        if( natureValue == 'Account Management' &&  $A.util.isEmpty( caseObj.Was_there_a_self_service_portal_to_facil__c ) ){
            errBody += ' Self service portal to facilitate this?,'
            hasError = "true";
        }

        if( natureValue == 'Billing' &&  $A.util.isEmpty( caseObj.Was_there_a_self_service_portal_to_facil__c ) ){
            errBody += ' Self service portal to facilitate this,'
            hasError = "true";
        }

        if( natureValue == 'Outage' &&  $A.util.isEmpty( caseObj.Is_the_Service_Internal_External_to_MYOB__c ) ){
            errBody += ' Is the Service Internal / External To Myob?,'
            hasError = "true";
        }

        /*if( natureValue == 'Outage' &&  $A.util.isEmpty( caseObj.Incident_Number__c ) ){
            errBody += ' Incident Number,'
            hasError = "true";
        }*/

        if( caseObj.Sub_Status__c == 'Resolved' &&  $A.util.isEmpty( caseObj.Resolution_Code__c ) ){
            errBody += ' Resolution Code,'
            hasError = "true";
        }

        if( caseObj.Sub_Status__c == 'Resolved' &&  $A.util.isEmpty( caseObj.Resolution__c ) ){
            errBody += ' Resolution,'
            hasError = "true";
        }
        
        if( caseObj.Subject.startsWith('Voice-Inbound')){
            if(errBody == 'Please complete the mentioned fields:'){
                errBody = ' Please change case subject.'
                hasError = "true";                
            }
            else{
                errBody += ' Please change case subject.'
                hasError = "true";                     
            }
        }        

        errBody = errBody.substring(0, errBody.length - 1);
        if( hasError == "true" ){
            component.set( 'v.hasError', hasError );
            component.set( 'v.msgBody', errBody );
        }else{
            component.set("v.hasError", "false");
        }
        
        
        if( isValid == 'true' && hasError == "false" ){
            console.log( ' Call main function ');
            component.set("v.hasError", "false");
            helper.createCaseHelper( component,event,helper );
        }
                
    },
    
    
  
})