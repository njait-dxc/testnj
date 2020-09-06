({
    loadPaymentProfile : function(component) {
        component.set("v.showSpinner",true);
        let action = component.get("c.getPaymentProfiles");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.paymentProfiles", response.getReturnValue());
                if(response.getReturnValue().length > 0) {
                    component.set("v.showPaymentProfiles", true);
                } else {
                    component.get("v.showPaymentProfiles", false);
                }
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },

    setPaymentProfile : function(component, profileId) {
        component.set("v.showSpinner",true);
        let action = component.get("c.updateOpportunityPaymentProfileId");
        action.setParams({
            recordId: component.get("v.recordId"),
            profileId: profileId
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue()) {
                this.showToast("Success","Payment profile updated successfully.","success");
                this.changeRadioButtonSelection(component,profileId);
            } else {
                this.showToast("Error","Failed to update payment profile","error");
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },

    changeRadioButtonSelection : function(component, selectedProfileId) {
        let paymentProfiles = component.get("v.paymentProfiles");
        for(let profileIndex = 0; profileIndex < paymentProfiles.length; profileIndex++) {
            paymentProfiles[profileIndex].selected = paymentProfiles[profileIndex].paymentProfile.id === selectedProfileId;
        }
        component.set("v.paymentProfiles",paymentProfiles);
    },

    showToast : function(title, message, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type":type
        });
        toastEvent.fire();
    }
});