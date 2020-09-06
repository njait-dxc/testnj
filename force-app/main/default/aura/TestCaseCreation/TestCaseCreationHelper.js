({
	helperMethod : function() {
		
	},
    
    getTaskData : function(component, event) {
        var tId = component.get("v.recordId");
        var action = component.get("c.getTaskData");
        action.setParams({
            taskId : tId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var result = response.getReturnValue();
               component.set("v.objCase.AccountId",result.WhatId);
               component.set("v.objCase.ContactId",result.WhoId);
               component.set("v.objCase.CallObject",result.CallObject);
               component.set("v.objCase.Subject",result.Subject);
               component.set("v.objCase.Description",result.Description);
               
               var conid=result.WhoId;
               var accid=result.WhatId;
                
               component.set("v.objTask", result);
               var action = component.get("c.getContactName");
               action.setParams({
                    ContId : conid
                });
               	    action.setCallback(this, function(response) {
                    var state = response.getState();
                   
                    if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.contactName",result.name);
                    }
                        var action = component.get("c.getAccountName");
                        action.setParams({
                            AccId : accid
                        });
                        action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                        var result1 = response.getReturnValue();
                        component.set("v.accountName",result1.name);
                       
                        }
                
                        });
                        $A.enqueueAction(action);
                });
            
                $A.enqueueAction(action);
              }
            else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        }      
   
        );
        $A.enqueueAction(action);
       
    },
    getCaseRecordType : function(component, event) {
     
        var action = component.get("c.getCaseRecordType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var result = response.getReturnValue();
               component.set("v.objCase.RecordTypeId", result.Id);
            }
        });
        $A.enqueueAction(action);
    },
  
    getPicklistValues: function(component, event,pklName,pkList) { 
        var action = component.get("c.preloadPKL");
        action.setParams({
            pklName : pklName,
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var prodMap = [];
                for(var key in result){
                    prodMap.push(result[key]);
                }
               component.set(pkList, prodMap); 
          
       }
       });
        $A.enqueueAction(action);
    },
  
        getCaseRTypePicklist: function(component, event,pklName,pkList) { 
        
        var action = component.get("c.getPickListElementsHttp");
        action.setParams({
            recordTypeId : 	"0122y000000GqYmAAK",
            fldName : pklName
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
               //alert("http pkls"+JSON.stringify(result));
               // console.log("http pkls"+JSON.stringify(result));
                var prodMap = result.values;
                var lst=[];
                //console.log(result);
                //console.log(prodMap);
               for(var obj in prodMap){
                   // Rohit 17/06/2020 Added if condition for SOE-1074 
                   if(pklName=="Status" && prodMap[obj].value =="Closed")
                   {}
                   else
                    lst.push(prodMap[obj].value);
                   //alert(obj.value);
                }
                 console.log(lst);
                 component.set(pkList, lst); 
            }
                 else {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                alert(errors[0].message);
                            }
                        }
                 }  
               
                /*
               component.set(pkList, prodMap); 
               ----- 
                //Set default values for case Status and case Origin fields
               / alert("//Set default values for case Status and case Origin fields");
                */
                if(pklName=="Origin"){
                    component.find("caseOrigin").set("v.value","Phone");
                }else if(pklName=="Sub_Status__c"){
                     component.find("caseSubStatus").set("v.value","In Progress");
                }else if(pklName=="Status"){
                 component.find("caseStatus").set("v.value","Open");   
                }
       
       });
        $A.enqueueAction(action);
    },

    getProductSubtypePKL : function(component,event){
    var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : component.get("v.objectName"),
            parentField : "Product_Type__c",
            childField : "PSSSubProduct__c"
           });
        
        action.setCallback(this, function(response){
         	var status = response.getState();
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();  
                //save response 
                component.set("v.prodSubPKLMap",pickListResponse.pickListMap)
           } 
        });
        
        $A.enqueueAction(action);
},
  
    getMasterPKLMap : function(component,event,parentFLD,childFLD,pklMap){
        var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : "Case",
            parentField : parentFLD,
            childField : childFLD
           });
        action.setCallback(this, function(response){
         	var status = response.getState();
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();  
                //save response 
                component.set(pklMap,pickListResponse.pickListMap);
				 } 
            
        });
        
        $A.enqueueAction(action);
},
    getDepPKLValues : function(component,event,mapPKL,childList,controllerVal){
        
        var controllerValue = component.find(controllerVal).get("v.value");
        
        console.log( 'controllerValue >>> '+controllerValue );
        
       
        var pickListMap = component.get(mapPKL);
       
        if (controllerValue != '--- None ---') {
             //get child picklist value
            var childValues = pickListMap[controllerValue];
            var childValueList = [];
            childValueList.push('--- None ---');
            
            for (var i = 0; i < childValues.length; i++) {
                childValueList.push(childValues[i]);
           }
            // set the child list
            component.set(childList, childValueList);
            
            if(childValues.length > 0){
                component.set("v.disabledChildField" , false);  
            }else{
                component.set("v.disabledChildField" , true); 
            }      
        } else {
            component.set(childList, ['--- None ---']);
            component.set("v.disabledChildField" , true);
        }  
  },
    createCaseHelper : function(component,event,helper) {
        var action = component.get("c.createCase");
        action.setParams({
            'caseObj' : component.get("v.objCase"),
            'taskRecordId':component.get("v.recordId")
           });
        
        action.setCallback(this, function(response){
         	var status = response.getState();
            if(status === "SUCCESS"){
               console.log('Case Created  >>> '+ JSON.stringify(response.getReturnValue()) );
               component.set("v.caseRecordId",response.getReturnValue());
                
                    var caseRecordId=response.getReturnValue();
                    
                   //Display case record created in a new Tab
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": caseRecordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                
            }   else if(status === "ERROR"){
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                alert(errors[0].message);
                            }
                        }
                }   else if (status === "INCOMPLETE") {
                    alert('No response from server or client is offline.');
                }
     
        });
        
       $A.enqueueAction(action);
    }
})