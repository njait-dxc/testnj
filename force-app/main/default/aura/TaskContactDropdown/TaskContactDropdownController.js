({
	doinit : function(component, event, helper) {
		var recordId = component.get("v.recordId");
		console.log( 'recordId >>> '+recordId );
		component.set( 'v.showSpinner', "true" );
		var action = component.get( "c.getContacts" );
		action.setParams({
			"taskId" : recordId
		});
		action.setCallback(this, function(response){
			var status = response.getState();
			if(status === "SUCCESS"){
				var contactWrapper = response.getReturnValue();

				if( contactWrapper == null ){
					component.set( 'v.showCmp', "false" );
				}else{
					var selectListWrap = [];
					for( var i=0; i< contactWrapper.length; i++){
						selectListWrap.push({ label : contactWrapper[i].conName, value : contactWrapper[i].conId, selected : contactWrapper[i].selected });
						if( contactWrapper[i].selected == true ){
							console.log( 'Set Con Id' );
							component.set( 'v.contactId', contactWrapper[i].conId );
						}
					}
					component.set( 'v.showCmp', "true" );
					component.set( 'v.hasError', "false" );
					component.set( "v.ConWrapper" , selectListWrap );
					component.set( 'v.showSpinner', "false" );
				}
			}else if(status === "ERROR"){
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						component.set( 'v.hasError', "true" );
						component.set( 'v.msgBody', errors[0].message );
						component.set( 'v.showSpinner', "false" );
					}
				}
			}
	   });
	   
	   $A.enqueueAction(action);
	  
	},

	updateTaskContactJs : function(component, event, helper) {
		console.log( 'updateTaskContactJs' );
		component.set( 'v.showSpinner', "true" );
		var recordId = component.get("v.recordId");
		var ContactId = component.get("v.contactId");
		var taskWhoIdValue = component.find('taskWhoId').get("v.value");
		var taskWhoIdtext = component.find('taskWhoId').get("v.text");

		
		var action = component.get( "c.updateTask" );
		action.setParams({
			"taskId" : recordId,
			"ConId"  : ContactId

		});
		action.setCallback(this, function(response){
			var status = response.getState();
			if(status === "SUCCESS"){
				component.set( 'v.hasError', "false" );
				component.set( 'v.showSpinner', "false" );
				$A.get('e.force:refreshView').fire();
			}else if(status === "ERROR"){
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						component.set( 'v.hasError', "true" );
						component.set( 'v.msgBody', errors[0].message );
						component.set( 'v.showSpinner', "false" );
					}
				}
			}
	   });
	   
	   $A.enqueueAction(action);
	
	},

	toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    }
})