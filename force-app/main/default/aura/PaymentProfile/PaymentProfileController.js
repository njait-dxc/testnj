({
    loadData : function(cmp, evt, hlp) {
        console.log('Payment Profile init');
        hlp.loadPaymentProfile(cmp);
    },

    onSelectChange : function (cmp, evt, hlp) {
        console.log('Payment Profile onSelectChange');
        let selected = evt.getSource().get("v.value");
        let selectedProfileId = evt.getSource().get("v.text");
        hlp.setPaymentProfile(cmp,selectedProfileId);
    }
})