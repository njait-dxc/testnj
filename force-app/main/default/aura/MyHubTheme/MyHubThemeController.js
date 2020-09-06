({
    init: function (component, event, helper) {
        var observer = new MutationObserver(function (mutations) {
            // Perform a minor fix up on class names to get magnifying glass icon to appear
            // in omniBox/search component.
            var searchIconElem = document.querySelector(".search-button-icon");
            if (searchIconElem) {
                searchIconElem.className = "forceIconDeprecated selfServiceIcon search-icon";
                observer.disconnect();
            }
        });

        observer.observe(document.body, {childList: true, subtree: true, attributes: false, characterData: false});
    },

    toggleSearch: function (component, event, helper) {
        $A.util.toggleClass(component.find('searchContainer'), 'searchVisible');
        $A.util.toggleClass(component.find('headerSearch'), 'searchVisible');
    },

    handleRouteChange: function (component, event, helper) {
        $A.util.removeClass(component.find('searchContainer'), 'searchVisible');
        $A.util.removeClass(component.find('headerSearch'), 'searchVisible');
    },

    navigateToHome: function (component, event, helper) {
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({"url": '/MyHub/s/'});
        urlEvent.fire();
    }
})