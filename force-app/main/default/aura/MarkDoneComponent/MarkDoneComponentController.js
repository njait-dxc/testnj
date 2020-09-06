({
    markDone: function (component, event, helper) {
        //console.log("mark done");
        var id = component.get("v.GenesysID");
        var disposition = component.get("v.Disposition") || "";
        var message = {
            action: "MarkDone",
            ActionData: {
                id: id,
                reason: disposition
            }
        };

        sendToWDE(message);
    },
    doInit: function (component, event, helper) {
        helper.getRecord(component);
    }
})