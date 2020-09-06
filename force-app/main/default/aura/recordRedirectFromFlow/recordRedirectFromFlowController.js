/**
 * Created by Ankit.Bhardwaj on 17/04/2020.
 */

({
    invoke : function(component, event, helper) {
        var redirectToNewRecord = $A.get( "e.force:navigateToSObject" );

        redirectToNewRecord.setParams({
            "recordId": component.get( "v.recordId" ),
            "slideDevName": "detail"
        });
        redirectToNewRecord.fire();
    }
})