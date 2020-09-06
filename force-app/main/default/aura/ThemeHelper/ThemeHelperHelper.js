({
    updateBackgroundClass: function () {
        var containerClassName = "carouselRegion";
        var containerSelector = "." + containerClassName;
        var layoutElem = document.querySelector(containerSelector);
        var path = window.location.pathname;
        var sitePathSuffix = '/s/';

        if (layoutElem) {
            if (path.indexOf(sitePathSuffix, path.length - sitePathSuffix.length) === -1) {
                //if it is not the home page hide the carousel
                layoutElem.className = containerClassName + "";
            } else {
                //if it is the home page show Carousel
                layoutElem.className = containerClassName + " showCarousel";
            }
        }
    }
})