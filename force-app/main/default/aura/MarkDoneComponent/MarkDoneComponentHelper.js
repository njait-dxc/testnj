({
    getRecord: function (component) {
        // the record id is populated by Lightning
        var genesysIDFieldName = component.get("v.GenesysIDFieldName");
        var dispositionFieldName = component.get("v.DispositionFieldName");
        var recordId = component.get("v.recordId");
        var action = component.get("c.getRecord");
        var fields = genesysIDFieldName;
        if (dispositionFieldName !== "") {
            fields += "," + dispositionFieldName;
        }

        if (recordId) {
            // make the apex call and get the disposition etc
            action.setParams({recordId: recordId, fieldsToShow: fields});

            action.setCallback(this, function (a) {
                var sobjectrecord = a.getReturnValue();

                if (sobjectrecord != null) {
                    //console.log(a.getReturnValue());
                    var genesysID = sobjectrecord[genesysIDFieldName];
                    //console.log("genesysIDFieldName=" + genesysID);
                    component.set("v.GenesysID", genesysID);

                    if (dispositionFieldName !== "") {
                        var disposition = sobjectrecord[dispositionFieldName];
                        //console.log("dispositionFieldName=" + disposition);
                        component.set("v.Disposition", disposition);
                    }
                }
            });

            $A.enqueueAction(action);
        }
    }
})