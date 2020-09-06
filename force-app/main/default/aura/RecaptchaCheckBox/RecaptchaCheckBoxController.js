({
    onInit: function (component, event, helper){ 
        document.addEventListener("grecaptchaVerified", function(e) {
            component.set('v.recaptchaResponse', e.detail.response);
			component.set('v.recaptchaResult', 'Verified');
        });
        
        document.addEventListener("grecaptchaExpired", function() {
			component.set('v.recaptchaResult', 'Expired');
        }); 
    },
    onRender: function (component, event, helper){ 
        document.dispatchEvent(new CustomEvent("grecaptchaRender", { "detail" : { element: 'recaptchaCheckbox'} }));
    }
})