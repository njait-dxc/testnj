({
   init : function(cmp, event, helper) {
      var availableActions = cmp.get('v.availableActions');
      for (var i = 0; i < availableActions.length; i++) {
         if (availableActions[i] == "PAUSE") {
            cmp.set("v.canPause", true);
         } else if (availableActions[i] == "BACK") {
            cmp.set("v.canBack", true);
         } else if (availableActions[i] == "NEXT") {
            cmp.set("v.canNext", true);
         } else if (availableActions[i] == "FINISH") {
            cmp.set("v.canFinish", true);
         }
      }
   },
        
   onButtonPressed: function(cmp, event, helper) {
      var actionClicked = event.getSource().getLocalId();
      var recordId = cmp.get("v.navigateToId"); 
      var URL = cmp.get("v.navigateToURL");
      var ExternalURL = cmp.get("v.navigateToExternalURL");
      console.log('onButtonPressed event');
       
      var navigate = cmp.get('v.navigateFlow');
      if(actionClicked == 'FINISH' && !$A.util.isEmpty(recordId)){
          sforce.one.navigateToSObject(recordId, 'detail');
      }else if(actionClicked == 'FINISH' && !$A.util.isEmpty(URL)){
          //sforce.one.navigateToURL(URL);
          	console.log('URL is' + URL);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
            "url": URL
            });
            urlEvent.fire();        
      }else if(actionClicked == 'FINISH' && !$A.util.isEmpty(ExternalURL)){
			window.open(ExternalURL,'_top');      	
      }else {
         navigate(actionClicked);
      }
   }
})