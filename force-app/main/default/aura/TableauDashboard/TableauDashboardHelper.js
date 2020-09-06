({
    // Helper method to get record data from apex controller
    getRecordData: function (component) {
        let options = component.get("v.options");
        if (options !== undefined && options !== null && options !== '' && options.includes("{{")) {
            let recordId;
            if (component.get("v.recordId") !== undefined && component.get("v.recordId") !== '') {
                recordId = component.get("v.recordId");
            } else {
                recordId = this.getURLParameter("c__sfObjectId");
            }

            let action = component.get("c.getObjectData");
            action.setParams({
                recordId: recordId,
                optionsJSON: options
            });
            action.setCallback(this, function (a) {
                if (a.getState() === "SUCCESS") {
                    component.set("v.options", a.getReturnValue());
                    this.loadTableauDashboard(component);
                }
            });
            $A.enqueueAction(action);
        } else {
            this.loadTableauDashboard(component);
        }
    },

    getURLParameter: function (param) {
        let result = decodeURIComponent
        ((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [, ""])[1].replace(/\+/g, '%20')) || null;
        console.log('Param ' + param + ' from URL = ' + result);
        return result;
    },

    // Helper method to load Tableau dashboard based on the values entered in component settings
    loadTableauDashboard: function (component) {
        //Reading the tableau settings entered in components design settings.
        let width = component.get("v.width");
        let height = component.get("v.height");
        let server = component.get("v.server");
        let workbook;
        let sheet;
        // Check if the current user is a NZ user and if there is any value entered in NZ workbook name.
        // If true, then it loads dashboard related to NZ, otherwise, it loads dashboard related to AU.
        if (component.get("v.nzWorkbook") !== "" && !this.checkAUUser()) {
            workbook = component.get("v.nzWorkbook");
            sheet = component.get("v.nzSheet");
        } else {
            workbook = component.get("v.workbook");
            sheet = component.get("v.sheet");
        }

        let tbOptions = component.get("v.options");
        let optionsJSON;
        let url;
        if (server !== "" && server !== undefined && workbook !== "" && workbook !== undefined
            && sheet !== "" && sheet !== undefined) {
            url = server + "/views/" + workbook + "/" + sheet;
        }

        if (tbOptions !== undefined && tbOptions !== null && tbOptions !== "") {
            //Parsing the JSON options entered in component setting and then customize dashboard height
            // and width based on value entered in setting.
            optionsJSON = JSON.parse(JSON.parse(JSON.stringify(tbOptions)));
            optionsJSON.width = width;
            optionsJSON.height = height;
        }

        if (typeof url !== "undefined" && url !== null && url !== "") {
            let globalId = component.getGlobalId();
            let containerDiv = document.getElementById(globalId + "_tableau");
            new tableau.Viz(containerDiv, url, optionsJSON);
        }
    },

    // Check current user's timezone to determine if the user in AU or NZ user
    checkAUUser: function () {
        let timezone = $A.get("$Locale.timezone");
        return timezone.includes("Australia");
    },

    setCookie: function(cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        var expires = "expires="+d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    },

    getCookie: function(cname) {
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }
});