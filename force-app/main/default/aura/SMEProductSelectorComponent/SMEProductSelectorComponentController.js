({
    initRecords: function (component, event, helper) {
        console.log('Add Product init');
        // call the apex class method and fetch wrapperobject list
        helper.fetchData(component, event, helper);
    },
    save: function (component, event, helper) {
        var opportunityId = component.get("v.recordId");
        var wrapperList = component.get("v.wrapperList");
        var action = component.get("c.updateOpportunityProducts");
        var successToastEvent = $A.get("e.force:showToast");
        let valid = true;
        let totalQtyCount = 0;

        for (let i = 0; i < wrapperList.length; i++){
            //Ankit & Ruchi - added the Quantity validation to check max allowed on the Opportunity
            totalQtyCount = totalQtyCount + wrapperList[i].quantity;
            if ((wrapperList[i].quantityRestriction < wrapperList[i].quantity) || totalQtyCount > wrapperList[i].maxAllowedQtyOnOpty){
                valid = false;
            }
        }
        successToastEvent.setParams({
            "title": "Success",
            "message": "Opportunity Line Items saved successfully",
            "type": "success",
            "mode": "sticky"
        });
        var errorToastEvent = $A.get("e.force:showToast");
        action.setParams({
            "oppLineItem": wrapperList,
            "oppId": opportunityId
        });
        if (valid)
        {
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    successToastEvent.fire();
                    component.set("v.showSaveCancelBtn", false);
                } else if (state === "ERROR") {
                    errorToastEvent.setParams({
                        "title": "Error",
                        "message": "An error occured while saving the records. Please contact your System Administrator.",
                        "type": "error",
                        "mode": "sticky"
                    });
                    errorToastEvent.fire();
                }
                $A.get('e.force:refreshView').fire();
            });
            $A.enqueueAction(action);
        }
        else
        {
            errorToastEvent.setParams({
                "title": "Error",
                "message": "Product quantity is exceeding restrictions",
                "type": "error",
                "mode": "sticky"
            });
            errorToastEvent.fire();
        }
    },
    cancel: function (component, event, helper) {
        component.set("v.showSaveCancelBtn", false);
        helper.fetchData(component, event, helper);
        $A.get('e.force:refreshView').fire();
    },
    showSpinner: function (component, event, helper) {
        component.set("v.Spinner", true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.Spinner", false);
    }
})