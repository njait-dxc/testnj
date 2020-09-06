({
    initialise: function (component, event, helper) {
        var applyStickyFilters = component.get('v.stickyFilters');
        var communityBuilderActive = window.location.search.includes('app=commeditor');
        if (communityBuilderActive == false && applyStickyFilters == true) {
            var stickyFiltersCookie = helper.getCookie('stickyFilters');
            if (stickyFiltersCookie == '') {
                helper.setCookie('stickyFilters', 'forceRefresh', 1);
                location.reload();
            } else if (stickyFiltersCookie == 'forceRefresh') {
                helper.setCookie('stickyFilters', '', 1);
            }
        }
    },

    afterScriptsLoaded: function (component, event, helper) {
        helper.getRecordData(component);
    }
});