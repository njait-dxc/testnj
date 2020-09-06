({
	loadEmailFields : function( component, event, helper ) {
        component.set( "v.isModalOpen", true );
        component.set("v.showLoader", true);
        var recordId = component.get( "v.recordId" );

        var action =  component.get( "c.loadEmailData" );
        action.setParams({
            caseId : recordId
        });
        action.setCallback( this, function( response ) {
            var state = response.getState();
            if ( state === "SUCCESS" ) {
                var emailData = response.getReturnValue();
                component.set( "v.email", emailData );
                component.set("v.showLoader", false);
            }else{
                console.log( 'ERROR' );
            }
        });
        $A.enqueueAction( action );
	},
    
    handleRemove : function( component, event, helper ) {
        var sel = event.getSource().get( "v.name" );
        var selectList = component.get( "v.selected" );
        for( var i = 0; i < selectList.length; i++ ){
            if( selectList[i].Id == sel.Id ){
                selectList.splice( i,1 );
            }
        }
        component.set( "v.selected", selectList );
    },
    
    getTemplate : function(component, event) {
        var templId = component.get("v.selTempl");
        component.set("v.showLoader", true);
        
        if(!$A.util.isEmpty(templId)){
            var action = component.get("c.getTemplateDetails");
            action.setParams({
                "templteId":templId
            });
            action.setCallback(this,function(response){
                component.set("v.showLoader", false);
                var responseVal = response.getReturnValue();
                
                if(!$A.util.isEmpty(responseVal)){
                    var email =  component.get(" v.email ");
                    email.subject = responseVal.Subject;
                    component.set("v.templDetail",responseVal);
                    component.set("v.email",email);
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.showLoader", false);
        }
    },
    
    NotifyUsers : function( component, event, helper ) {
        component.set( "v.showLoader", true );
        var recordId  = component.get( "v.recordId" );
        var emailTemp = component.get( "v.templDetail" );
        var fileIds   = component.get( "v.selected" );
        var email     = component.get( "v.email" );
        var file      = [];
        if( fileIds ){
            for( var i = 0; i < fileIds.length; i++ ){
                file.push( fileIds[ i ].Id );
            }
        }
        var action = component.get( "c.sendEmailApex" );
        action.setParams({
            "emailData"   : email,
            "caseId"      : recordId,
            "emailTemp"   : emailTemp,
            "files"       : file
        });
        
        action.setCallback(this, function(response){
            component.set( "v.showLoader", true );
            console.log("In call back of notify component on send button");
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                console.log("In success");
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title"   : "Success!",
                    "message" : "Notify message sent successfully",
                    "type"    : "success"
                });
                toast.fire();
                
                $A.get("e.force:refreshView").fire(); 
                
                component.set( "v.isModalOpen", false );
                var email = component.get( "v.email" );
                email.toAddress = '';
                email.ccAddress = '';
                email.subject = '';
                email.orgWideAddress = '';
                component.set( "v.email", email );
                component.set( "v.selected", null );
                component.set( "v.templDetail",null );
                
            }else if(state === "ERROR"){
                console.log("In error");
                var errors = response.getError();
                console.log(errors);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title" : "Error!",
                    "message" : errors[0].message,
                    "type" : "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})