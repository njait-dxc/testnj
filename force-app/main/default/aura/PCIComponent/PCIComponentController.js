({
   init : function(cmp, event, helper) {
       var hostname = window.location.hostname;
       var arr = hostname.split(".");
       var instance = arr[0];
       if(instance == 'myob'){
       		cmp.set("v.iframeUrl", 'https://pcicardportal.myob.com/portals/selfportalweb/');  
       		//cmp.set("v.iframeUrl", 'https://sit.pcicardportal.myob.com/portals/selfportalweb/');  
       }else{
           	cmp.set("v.iframeUrl", 'https://sit.pcicardportal.myob.com/portals/selfportalweb/');
       }
     
       window.addEventListener('message', function(e){
           var data = JSON.parse(e.data);
           //console.log(data.data.outcome.cardDetails);
           if(typeof data === "undefined"){
               console.log('data section');
           }else if(typeof data.data === "undefined"){
               console.log('undefined 2nd data section');
           }else if(typeof data.data.outcome === "undefined"){
               console.log('undefined outcome section');
           }else if(data.data.outcome.cardDetails){
               console.log('defined section');
               cmp.set("v.cardToken", data.data.outcome.cardDetails.card_token);
               cmp.set("v.name_on_card", data.data.outcome.cardDetails.name_on_card);
               cmp.set("v.last_four_digits", data.data.outcome.cardDetails.last_four_digits);
               cmp.set("v.type", data.data.outcome.cardDetails.type);
               cmp.set("v.expiry_month", data.data.outcome.cardDetails.expiry_month);
               cmp.set("v.expiry_year", data.data.outcome.cardDetails.expiry_year); 
               cmp.set("v.message", "The credit card information is validated.");
               $A.util.removeClass(cmp.find("createPaymentProfileButton"), 'slds-hide');
           }else{
               cmp.set("v.message", "The credit card information is either incomplete or invalid. Upon the all information is validated, the button will be displayed for creating payment profile");
               $A.util.addClass(cmp.find("createPaymentProfileButton"), 'slds-hide');
           }          
       }, false);
   },

   createPaymentProfile : function(cmp, event, helper) {
	   var successToastEvent = $A.get("e.force:showToast");
       successToastEvent.setParams({
            "title": "Success",
            "message": "Payment profile has been created successfully",
            "type": "success",
            "mode": "sticky"
       });

       var errorToastEvent = $A.get("e.force:showToast");
       errorToastEvent.setParams({
           "title": "Error",
           "message": "Failed to create payment profile. Please contact your System Administrator.",
           "type": "error",
           "mode": "sticky"
       });

       var action = cmp.get("c.callPaymentProfileCreation");
	   action.setParams({ 
           "oppId" : cmp.get("v.recordId"),
           "name_on_card" : cmp.get("v.name_on_card"),
           "card_token" : cmp.get("v.cardToken"),
           "last_four_digits" : cmp.get("v.last_four_digits") ,
           "type" : cmp.get("v.type") ,
           "expiry_month" : cmp.get("v.expiry_month"),
           "expiry_year" : cmp.get("v.expiry_year"),
           "payment_schedule" : 'Monthly',
           "payment_method" : 'Credit Card'
       });      
	   console.log('set up parameter');     
       
       action.setCallback(this, function(response) {
           	var state = response.getState();

           	if (state === "SUCCESS") {
                var paymentProfileId = response.getReturnValue();
                if(paymentProfileId != null && paymentProfileId !=""){
                   successToastEvent.setParams({
                        "title": "Success",
                        "message": "Payment profile " + paymentProfileId + " has been created successfully",
                        "type": "success",
                        "mode": "sticky"
                   });                    
                   successToastEvent.fire(); 
                }else{
                	errorToastEvent.fire();    
                }
                
           	} else if (state === "ERROR") {
                errorToastEvent.fire();
            }
            //var paymentProfileId = response.getReturnValue();
            //component.set("v.paymentProfileId", paymentProfileId);
       })
       $A.enqueueAction(action);               
   },
     
    handleShowSpinner: function(component, event, helper) {
        component.set("v.isSpinner", true); 
    },
     
    handleHideSpinner : function(component,event,helper){
        component.set("v.isSpinner", false);
    },
     
    closeQuickAction : function(component,event,helper){
        window.removeEventListener('message');
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }        
})