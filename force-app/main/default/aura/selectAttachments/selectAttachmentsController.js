({
    doInit : function( component, event, helper ) {
        component.set( "v.showLoader", true );
        console.log("In Init Select Attachment");
        var recordId    = component.get( "v.recordId" );
		var action = component.get("c.getAttachments");
        action.setParams({
            caseId : recordId
        });
        action.setCallback( this, function( response ){
            var state = response.getState();
            if( state === "SUCCESS" ){
                var result = response.getReturnValue();
                console.log( result );
                if( result == null ){
                    component.set( "v.hasData", "false" );
                }else{
                    component.set( "v.hasData", "true" );
                }
                console.log( "result of Attach display component" );
                console.log( result );
                component.set( "v.fileIds", result );
                component.set( "v.showLoader", false );
            }
        });
        $A.enqueueAction( action );
	},
    
    closeModal : function( component, event, helper ) {
        component.set("v.isOpen", false);
    }, 
    
    onCheckboxChange : function( component, event, helper ) {
        console.log( "In on change " );
        var change = event.getSource().get( "v.value" );
        var val    = event.getSource().get( "v.checked" );
        console.log( JSON.stringify( change ));
        console.log( JSON.stringify( val ));
        var selected = component.get( "v.selectedFiles" );
        if( val === true ){
        selected.push( change ); 
        }else{
            selected.pop( change );
        }
        console.log( JSON.stringify( selected ));
        component.set( "v.selectedFiles", selected );  
    },
    
    onOk : function( component, event, helper ) {
        console.log( "In on onOk " );
        var selected = component.get( "v.selectedFiles" );
        console.log( JSON.stringify( selected ));
        
        var cmpEvent = component.getEvent( "selectedAttachmentsNotifyEvent" );
        cmpEvent.setParams({
            "selectedIds" : selected
        });
        cmpEvent.fire();
        console.log( "Event fired" );
        component.set( "v.isOpen", false );
        component.set( "v.selectedFiles", [] );
    },
    
    handleFilesChange: function( component, event, helper ){
        var fileName = 'No File Selected..';
        if ( event.getSource().get( "v.files" ).length > 0 ) {
            fileName = event.getSource().get( "v.files" )[0][ 'name' ];
        }
        component.set( "v.fileName", fileName );
        if(component.find( "fileId" ).get( "v.files" ).length > 0 ){
            helper.uploadHelper( component, event, helper );
            
        }else {
            alert( 'Please Select a Valid File' );
        }
    }
})