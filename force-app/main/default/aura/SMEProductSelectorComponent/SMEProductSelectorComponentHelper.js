({
    fetchData: function (component, event, helper) {
        var action = component.get("c.getOpportunityLineItems");
        action.setParams({
            'oppId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set wrapperList list with return value from server.
                component.set("v.wrapperList", storeResponse);
                //component.set('v.loaded', !component.get('v.loaded'));
            } else if (state === "ERROR") {
            }
        });
        $A.enqueueAction(action);
    }
})