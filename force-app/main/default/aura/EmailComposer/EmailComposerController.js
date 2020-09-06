({
    OpneModel : function( component, event, helper ) {
        helper.loadEmailFields( component, event, helper );
    },
    
    closeModel : function( component, event, helper ) {
		console.log( 'closeModel' );
        component.set( "v.isModalOpen", false );
        var email = component.get( "v.email" );
        email.toAddress = '';
        email.ccAddress = '';
        email.subject = '';
        email.orgWideAddress = '';
        component.set( "v.email", email );
        component.set( "v.selected", null );
        component.set( "v.templDetail",null );
	},
    
    toOpenAttachments : function( component, event, helper ) {
        console.log("Opened small modal to select attachments");
        component.set("v.openAttach", true);
	},
    
    selectedAction : function(component, event, helper) {       
        var select = event.getParam("selectedIds");
        component.set("v.selected", select);
    },
    
    handleRemoveOnly : function( component, event, helper ) {
        console.log("in remove");
        helper.handleRemove( component, event, helper );
    },

    loadTemplate : function(component, event, helper) {
        helper.getTemplate(component, event);
        
    },
    
    sendMail : function( component, event, helper ) {
        console.log("in sendMail");
        var email     = component.get( "v.email" );
        if( $A.util.isEmpty( email )  || $A.util.isEmpty( email.toAddress ) || $A.util.isEmpty( email.subject ) ){
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title"   : "Error!",
                "message" : "Please populate the required fields : To Email Addresses, Template",
                "type"    : "error"
            });
            toast.fire();
        }else{
            helper.NotifyUsers( component, event, helper );
        }
        
    }
})