/*
(default customization: out of the box functionality)
Implement out of the box logic. Includes IWS events handling, event routing, search calls, screen pop calls.

Listens to events:
"workspace/message"

*/

(function(window, jQuery, undefined) {

var _log = Log ? Log.log : console.log;

jQuery.subscribe("workspace/message", processMessage);


function createAttDataArray(userData) {
	var businessAttributes = Workspace.getBusinessAttributes();
	var attData = new Array();
	$.each(userData, function(key, value) {
		if (! (key in businessAttributes)) {
			return;
		}
		var attr = $.extend(true, {}, businessAttributes[key]);
		attr.value = value;
		attData.push(attr);
	});
	return attData;
}

function showAttachedData(userData) {
    if (!userData) {
    	return;
    }

    Connector.showAttachedData(createAttDataArray(userData));
    if(Workspace.getAutoOpenDataDisplay == 'true')
    	sforce.interaction.setVisible(true);
}

////////////////////////////////////////////////////////////////////////////////////////
// event processing
//
// processMessage is called for all received communications from Interaction Workspace
// that contains valid work to be performed.
////////////////////////////////////////////////////////////////////////////////////////

function processMessage(obj) {
    if (obj.action == "OpenObject") {
        _log("in OpenObject");
        
        if(Salesforce.inServiceCloudConsole())
        	showAttachedData(obj.userData);

        // open based on type attribute
        if (obj.type == "Voice") {
            // if we have a userData attribute of MainMenu, then go to case processing
            if (obj.userData.MainMenu !== undefined) {
                _log("processMessage: Voice Case handling for menu = " + obj.userData.MainMenu);
                performCaseAction(obj);
            } else {
                // Inbound or internal voice
                //if (obj.calltype == "Inbound" || obj.calltype == "Internal") {
                if (obj.calltype == "Inbound" || obj.calltype == "Internal" || obj.calltype == "Consult") {
                    _log("processMessage: Inbound Voice handling for caller ID = " + obj.source);
                    performInboundVoiceAction(obj);
                }

                // Outbound voice
                if (obj.calltype == "Outbound") {
                    // attempt to open on outbound
                    _log("processMessage: Outbound Voice handling for party = " + obj.destination);
                    performOutboundVoiceAction(obj);
                }
                if (obj.calltype == "Unknown") {
                    _log("processMessage: Unknown, clickToDialNum = " + clickToDialNum + ", destination = " + obj.destination);
                    clickToDialNum = "";
                    //performOutboundVoiceAction(obj);
                }
            }
        }
        else if (obj.type == "Email") {
            _log("processMessage: Email pop action");
            performEmailAction(obj);
        }
        else if (obj.type == "Chat") {
            _log("processMessage: Chat pop action");
            performChatAction(obj);
        }
        else if (obj.type == "InteractionWorkItem") {
            _log("processMessage: Workitem pop action for mediaType: " + obj.mediaType);
            performWorkItemAction(obj);
        }
        else if (obj.type == "Sms") {
            _log("processMessage: Sms pop action");
            performSmsAction(obj);
        }
        else if (obj.type == "WebCallback") {
            _log("processMessage: WebCallback pop action");
            performWebCallbackAction(obj);
        }
        else if (obj.type == "OpenMedia") {
            _log("processMessage: OpenMedia pop action");
            performOpenMediaAction(obj);
        }

    }
    else if (obj.action == "CreateActivity") {
    	//var ixnId = Salesforce.getIxnId(obj.id);
    	var objectIdForActivity = "";
    	
    	//TODO 
        //_log("CreateActivity for connID " + obj.id + " delete Windows - " + ixnId);
        //Salesforce.removeIxnWindow(ixnId);

    	var useFocusedRecord = obj.useFocusedRecord;
    	_log("useFocusedRecord " + useFocusedRecord);
	    
    	if(useFocusedRecord!=null && (useFocusedRecord=="True" || useFocusedRecord=="true") && (!Salesforce.inServiceCloudConsole()))
    	{
	    	sforce.interaction.getPageInfo(function(o) {
	    		if(o!=null && o.result!=null)
	    		{ 
	    			var jsonResult = jQuery.parseJSON(o.result);
	    			if(jsonResult!=null && jsonResult.objectId!=null)
	    			{
			            objectIdForActivity = jsonResult.objectId;
				        _log("CreateActivity for connID " + obj.id + " using object " + objectIdForActivity);
				
				        // create the task
				        createTask(obj, objectIdForActivity);	    			
	    				return;
	    			}
	    		}
    			prepareCreateTask(obj, objectIdForActivity);
	    	});	    
	    	clickToDialNum = "";
	    	return;
    	}
    	else
    	{
	        //check for attached data sfdcObjectId - if it is there, then use that
	        if (obj.userData.sfdcObjectId != null) 
	        {
	            objectIdForActivity = obj.userData.sfdcObjectId;
		        _log("CreateActivity for voice using object " + objectIdForActivity);
		
		        // create the task
		        createTask(obj, objectIdForActivity);
		        
		        clickToDialNum = "";
	    		return;		        	    
	        }
    	}
    	prepareCreateTask(obj, objectIdForActivity);
    }
    else if (obj.action == "MarkedDone") {
    	//TODO
    	//var ixnId = Salesforce.getIxnId(obj.id);
        //_log("MarkedDone for connID " + obj.id + " delete Windows - " + ixnId);
        //Salesforce.removeIxnWindow(ixnId);
    }
    else if (obj.action == "FocusTab") {
        _log("FocusTab for " + obj.id);
        //TODO
        //Salesforce.focusIxnTab(obj.id);
    }
    else if (obj.action == 'ConnectionDenied') {
    	//PJB: Don't reconnect if denied
    	_log("Connection denied, do not retry");
    	if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null)
    	{
    		window.sessionStorage.setItem("Genesys_sfdc_Banned", "True");
    	}
    }
    else if (obj.action == 'PerformSFDCRequest') {
    	_log("PerformSFDCRequest");
    }    
    
    clickToDialNum = "";
}

//PJB: Moved some code that I would have had to move to a function to create the task
function prepareCreateTask(obj, objectIdForActivity)
{
	if (obj.type == "Voice")
	{        		
    	var lookupNumber='';
        if (obj.calltype == "Inbound" || obj.calltype == "Internal"  || obj.calltype=="Consult" || obj.calltype=="Conference") {
		    lookupNumber = obj.source;
		    if (obj.role == 'RoleOrigination') {
		        lookupNumber = obj.destination;
		    }
		}
		else if(obj.calltype == "Outbound") {
            lookupNumber = obj.destination;
        }
		
		if(obj.userData.CaseNumber !== undefined)
		{
			_log("CreateActivity for voice under User since CaseNumber processing did not yield a match");
			createTask(obj, objectIdForActivity);
			return;
		}
		
		if(obj.fieldName != undefined && obj.fieldValue != undefined){
        	var searchFieldName = obj.fieldName;
        	var searchFieldValue = obj.fieldValue;
        	_log("CreateActivity for voice using search field " + searchFieldName + " for a value of " + searchFieldValue);
        	 g_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {
        	     if (o != null) {
		      			objectIdForActivity = o.Id;
		      			_log("Id found " + objectIdForActivity);
        	     } else {
        	    	 	_log("Id not found ");
        	     }
 	             _log("CreateActivity for connID " + obj.id + " using object " + objectIdForActivity);
	             createTask(obj, objectIdForActivity);
        	 });
        }
		else{		
			_log("CreateActivity for voice with lookup " + lookupNumber);
			
	        g_WorkspaceConnectorController.findObjectFromANI(lookupNumber, function(o) {
	            if (o != null) {
		      		if(o != 'not found' && o != 'multiple found')
		      		{
		      			objectIdForActivity = o.Id;
		      			_log("Id found " + objectIdForActivity);
		      		}
		      		else if(o == 'multiple found')
					{
						_log("Multiple results");
						//find the one with the most recent completed activity and create the task there
						//findMostRecentlyCompletedActivity(lookupNumber, false, obj.id, obj);
						//return;
					}
	            }
	            else
	            {
	            	_log("No results");
	            }		
	            _log("CreateActivity for connID " + obj.id + " using object " + objectIdForActivity);
	            createTask(obj, objectIdForActivity);		            
			});
		}
		clickToDialNum = "";
		return;
	}

    _log("CreateActivity for connID " + obj.id + " using object " + objectIdForActivity);

    // create the task
    createTask(obj, objectIdForActivity);
}

////////////////////////////////////////////////////////////////////////////////////////
// Inbound and Outbound Voice handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for inbound voice. If role is RoleDestination, then this is inbound, if
// RoleOrigination, then it is an manual outbound dial
function performInboundVoiceAction(obj) {
    _log("in performInboundVoiceAction()");
    

    // determine number to use based on role
    _log("Role is " + obj.role);
    var lookupNumber = obj.source;
    if (obj.role == 'RoleOrigination') {
        lookupNumber = obj.destination;
    }
	if(obj.calltype == "Consult" && obj.userData.primaryANI != undefined && obj.userData.primaryANI != ""){
		_log("Using primaryANI from Consult");
		lookupNumber = obj.userData.primaryANI;
	}

    // if contains a CaseNumber attached data, pop on it
    if (obj.userData.CaseNumber !== undefined) {
        g_WorkspaceConnectorController.findCaseFromNumber(obj.userData.CaseNumber, function(o) {
            if (o != null) {
                _log("Screen popping CASE record: " + o.Name);
                if (Salesforce.inServiceCloudConsole()) {
                	Salesforce.screenPop(o.Id); 
                }
                else Workspace.sendFocusChange(o.Id, true);
                var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
                Workspace.sendAttachData(newData);                
            } else {
                _log("No records found with Case Number containing: " + obj.userData.CaseNumber);
                Salesforce.openSearchCase(obj.userData.CaseNumber, obj.id);
            }
        });
    } else {
        if (Salesforce.screenPopUser(obj)) {
            return;
        }
        if(obj.fieldName != undefined && obj.fieldValue != undefined){
        	var searchFieldName = obj.fieldName;
        	var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
        	_log("search field " + searchFieldName + " for a value of " + searchFieldValue);
        	 g_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {
        	     if (o != null) {
        	    	 if (Salesforce.inServiceCloudConsole()) {
        	    			Salesforce.screenPop(o.Id); 
        	    	 }
        	    	 else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
        	         //inform workspace of SFobject id for subsequent use in activity creation and transfer
        	         var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
        	         Workspace.sendAttachData(newData);
        	     } else {
        	         _log("performInboundVoiceAction: result = " + o);
        	         //open search
        	         Salesforce.openSearch("", obj.id); 
        	     }
        	 });
        }
        else{
        	//using the source attribute locate the account/contact/lead
        	_log("Using lookupNumber = " + lookupNumber);
	        g_WorkspaceConnectorController.findObjectFromANI(lookupNumber, function(o) {
	            if (o != null) {
	                if (o == 'multiple found' || o == 'not found') {
	                    Salesforce.openSearch(lookupNumber, obj.id);
	                    return;
	                }
	                Salesforce.addIxnWindow(obj.id, o.Id);
	                if (Salesforce.inServiceCloudConsole()) {
	                	Salesforce.screenPop(o.Id); 
	                }
	                else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
	                //inform workspace of SFobject id for subsequent use in activity creation and transfer
	                var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
	                Workspace.sendAttachData(newData);			            
	            } else {
	                _log("No records found with phone field containing: " + lookupNumber);
	            }
	        });
        }
    }
}

// screen pop for outbound voice
function performOutboundVoiceAction(obj) {
    _log("in performOutboundVoiceAction()");

    if (Salesforce.screenPopUser(obj)) {
        return;
    }

    var lookupNumber = obj.destination;
    // using the destination attribute locate the contact
    g_WorkspaceConnectorController.findObjectFromANI(lookupNumber, function(o) {
        //WorkspaceConnectorController.findContactFromANI(obj.destination,function(o) {
        if (o != null) {
            if (o == 'multiple found' || o == 'not found') {
                Salesforce.openSearch(lookupNumber, obj.id);
                return;
            }
            _log("Screen popping record: " + o.Id);
            if (Salesforce.inServiceCloudConsole()) {
            	Salesforce.screenPop(o.Id); 
            }
            else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
            //inform workspace of SFobject id for subsequent use in activity creation and transfer
            var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
            Workspace.sendAttachData(newData);
        } else {
            _log("No records found with phone field containing: " + lookupNumber);
        }
    });
}

////////////////////////////////////////////////////////////////////////////////////////
// Email handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for email

function performEmailAction(obj) {
    _log("in performEmailAction()");
    if (Salesforce.screenPopUser(obj)) {
        return;
    }
    var searchFieldName = "";
    var searchFieldValue = "";
    var lookupContact;
    if(obj.source != undefined && obj.source != '') {
    	lookupContact = obj.source;
    	searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
    	searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
    }
    else{
    	if(obj.destination != undefined){
        	var emailAddr = obj.destination;
    		//remove trailing ; or ,
    		var lastChar1 = emailAddr.lastIndexOf(";");
    		var lastChar2 = emailAddr.lastIndexOf(",");
    		if(lastChar1 == (emailAddr.length-1) || lastChar2 == (emailAddr.length-1)){
    			//remove last character
    			emailAddr = emailAddr.slice(0,-1);			
    		}			
    		_log("emailAddr " + emailAddr);
    		lookupContact = emailAddr;
    		searchFieldName = "email";
    		searchFieldValue = emailAddr;
    	}
    }
	_log("search field " + searchFieldName + " for a value of " + searchFieldValue);
    //g_WorkspaceConnectorController.findContactFromEmailAddress(lookupContact, function(o) {
    g_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {
        if (o != null) {
        	if (Salesforce.inServiceCloudConsole()) {
        		Salesforce.screenPop(o.Id); 
        	}
        	else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
            //inform workspace of SFobject id for subsequent use in activity creation and transfer
            var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
            Workspace.sendAttachData(newData);
        } else {
        	 _log("performEmailAction: No records found");
            Salesforce.openSearch("", obj.id);            
        }
    });
}

////////////////////////////////////////////////////////////////////////////////////////
// Chat handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for chat
function performChatAction(obj) {
    _log("in performChatAction()");
    // check for attached data sfdcObjectId - if it is already there, then pop that
    if (Salesforce.screenPopUser(obj)) {
        return;
    }

    var name = obj.source;
    var searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
    var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
    _log("search field " + searchFieldName + " for a value of " + searchFieldValue);
    
    // using the source attribute locate the contact
    //g_WorkspaceConnectorController.findContactFromChatAddress(name, function(o) {
    g_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {    	
        if (o != null) {
        	if (Salesforce.inServiceCloudConsole()) {
        		Salesforce.screenPop(o.Id); 
        	}
        	else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
            //inform workspace of SFobject id for subsequent use in activity creation and transfer
            var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
            Workspace.sendAttachData(newData);
        } else {
            _log("performChatAction: No records found");
            //open search
            Salesforce.openSearch("", obj.id); 
        }
    });
}


////////////////////////////////////////////////////////////////////////////////////////
// WorkItem handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for WorkItem
function performWorkItemAction(obj) {
    _log("in performWorkItemAction()");
    // check for attached data sfdcObjectId - if it is already there, then pop that
    if (Salesforce.screenPopUser(obj)) {
        return;
    }

    var name = obj.source;
    var searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
    var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
    _log("search field " + searchFieldName + " for a value of " + searchFieldValue);
    
    // using the source attribute locate the contact
    //g_WorkspaceConnectorController.findContactFromWorkItemAddress(name, function(o) {
    g_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {    	
        if (o != null) {
        	if (Salesforce.inServiceCloudConsole()) {
        		Salesforce.screenPop(o.Id); 
        	}
        	else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
            //inform workspace of SFobject id for subsequent use in activity creation and transfer
            var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
            Workspace.sendAttachData(newData);
        } else {
            _log("performWorkItemAction: No records found");
            //open search
            Salesforce.openSearch("", obj.id);            
        }
    });
}

////////////////////////////////////////////////////////////////////////////////////////
//SMS handling
////////////////////////////////////////////////////////////////////////////////////////

//screen pop for SMS
function performSmsAction(obj) {
 _log("in performSmsAction()");
 // check for attached data sfdcObjectId - if it is already there, then pop that
 if (Salesforce.screenPopUser(obj)) {
     return;
 }

 var name = obj.source;
 var searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
 var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
 _log("search field " + searchFieldName + " for a value of " + searchFieldValue);

 // using the source attribute locate the contact
 //g_WorkspaceConnectorController.findContactFromOpenMediaAddress(name, function(o) {
 g_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {
     if (o != null) {
    	 if (Salesforce.inServiceCloudConsole()) {
    			Salesforce.screenPop(o.Id); 
    	 }
    	 else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
         //inform workspace of SFobject id for subsequent use in activity creation and transfer
         var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
         Workspace.sendAttachData(newData);
     } else {
         _log("performSmsAction: result = " + o);
         //open search
         Salesforce.openSearch("", obj.id); 
     }
 });
}

////////////////////////////////////////////////////////////////////////////////////////
//WebCallback handling
////////////////////////////////////////////////////////////////////////////////////////

//screen pop for WebCallback
function performWebCallbackAction(obj) {
	_log("in performWebCallbackAction()");
	 // check for attached data sfdcObjectId - if it is already there, then pop that
	 if (Salesforce.screenPopUser(obj)) {
	     return;
	 }

	 var name = obj.source;
	 var searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
	 var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
	 _log("search field " + searchFieldName + " for a value of " + searchFieldValue);

	 // using the source attribute locate the contact
	 //g_WorkspaceConnectorController.findContactFromOpenMediaAddress(name, function(o) {
	 g_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {
	     if (o != null) {
	    	 if (Salesforce.inServiceCloudConsole()) {
	    			Salesforce.screenPop(o.Id); 
	    	 }
	    	 else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
	         //inform workspace of SFobject id for subsequent use in activity creation and transfer
	         var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
	         Workspace.sendAttachData(newData);
	     } else {
	         _log("performWebCallbackAction: result = " + o);
	         //open search
	         Salesforce.openSearch("", obj.id); 
	     }
	 });
}

////////////////////////////////////////////////////////////////////////////////////////
// Open Media handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for OpenMedia
function performOpenMediaAction(obj) {
    _log("in performOpenMediaAction()");
    // check for attached data sfdcObjectId - if it is already there, then pop that
    if (Salesforce.screenPopUser(obj)) {
        return;
    }

    var name = obj.source;

    // using the source attribute locate the contact
    g_WorkspaceConnectorController.findContactFromOpenMediaAddress(name, function(o) {
        if (o != null) {
        	if (Salesforce.inServiceCloudConsole()) {
        		Salesforce.screenPop(o.Id); 
        	}
        	else Workspace.sendFocusChange(o.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
            //inform workspace of SFobject id for subsequent use in activity creation and transfer
            var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
            Workspace.sendAttachData(newData);
        } else {
            _log("performOpenMediaAction: No records found with Name containing: " + name);
            //open search
            Salesforce.openSearch("", obj.id); 
        }
    });
}


////////////////////////////////////////////////////////////////////////////////////////
// Case handling
////////////////////////////////////////////////////////////////////////////////////////

/*
 Opens an existing Case if MainMenu = 'Existing Ticket'
 or creates a new Case if MainMenu = 'New Ticket'
 */
function performCaseAction(openObj) {
    _log("in performCaseAction() with main menu=" + openObj.userData.MainMenu);

    // Existing Ticket
    if (openObj.userData.MainMenu == 'Existing Ticket') {
        _log("Opening an Existing CASE with number: " + openObj.userData.TicketNumber);
        g_WorkspaceConnectorController.findCaseFromNumber(openObj.userData.TicketNumber,
            function(result, event) {
                if (result != null) {
                    _log("found Case.Id=" + result.Id + " (CaseNumber " + result.CaseNumber + ")");
                    if (Salesforce.inServiceCloudConsole()) {
                    	Salesforce.screenPop(result); 
                    }
                    else Workspace.sendFocusChange(result.Id, true); //PJB: Had to move screenpop so that it wasn't called while we were still sending events
                }
                else {
                    _log('No case found, defaulting to navigator tab for user search');
                    try {
                        // display the CaseNotFound page allowing the user to correct
                        // correct the input case and re-pop.
                        Salesforce.consolePop("apex/WSC_CaseNotFound?CaseNumber=" + openObj.userData.TicketNumber, 
                        	"Case Not Found");
                    } catch (e) {
                        //alert("Error=" + e);
                    }
                }
            });
    }

    // New Ticket
    if (openObj.userData.MainMenu == 'New Ticket') {
        _log("New Ticket requested");
        var displayDate = getDisplayDate();
        var mediaType = (openObj.mediaType === undefined) ? "" : openObj.mediaType;
	    var mapCase = {
	    		"IXN Type" : openObj.type,
	    		"Media Type" : mediaType,
	    		"DATE": displayDate
	    }
	    g_WorkspaceConnectorController.createCase(mapCase, function(result){
	    	_log("createCase result = " + result);
	    	if(result != null && result != 'case not created'){
	            //display the case
	            Salesforce.screenPop(result);
	    	}
	    });
        
        // fetch the product line and product IDs
        var canPop = false;            // indicates if all data attributes available to pop form
        /*
        g_WorkspaceConnectorController.getProductFromName(openObj.userData.FunctionalGroup, function(pl) {
            if (pl != null) {
                g_WorkspaceConnectorController.getProductFromName(openObj.userData.ProductGroup, function (sp) {
                    if (sp != null) {
                        _log("Opening new Product Case for " + openObj.userData.Employer + " using product line: " + openObj.userData.FunctionalGroup + " and product: " + openObj.userData.ProductGroup);
                        // open the New Case page forcing bypass of first two forms with prefilled contacts and products
                        Salesforce.consolePop('apex/Portal_Select_Case_Type?isSaas=true&RecordType=012J0000000CsVB'
                            + '&sto=' + openObj.userData.SoldToSFDCId
                            + '&eu=' + openObj.userData.EndUserSFDCId
                            + '&pl=' + pl.Id
                            + '&sp=' + sp.Id
                            + '&conid=' + openObj.userData.ContactSFDCId,
                            'New Case');
                        canPop = true;        // we have popped
                    }
                });
            }
        });
        */
    }

    // Something Else
    if (openObj.userData.MainMenu == 'Something Else') {
        _log("Something else requested");
        // do nothing
    }
}

////////////////////////////////////////////////////////////////////////////////////////
// Task handling
//
// Writes a simple task from provided disposition information
////////////////////////////////////////////////////////////////////////////////////////

function getDisplayDate() {
    var date = new Date();
    var hrs = date.getHours();
    if(hrs < 10)
    	hrs = "0" + hrs;
    var min = date.getMinutes();
    if(min < 10)
    	min = "0" + min;
    var sec = date.getSeconds();
    if(sec < 10)
    	sec = "0" + sec;
    return (date.getMonth() + 1) + '/' + (date.getDate()) + '/' + date.getFullYear()
        //+ " " + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
        + " " + hrs + ':' + min + ':' + sec;
}

function createTask(createObj, objIdForActivity) {
	_log("in createTask");
	var createObjType = (createObj.type === undefined) ? getDisplayDate() : createObj.type;
    _log("createTask for " + createObjType);
    var displayDate = (createObj.startDate === undefined) ? getDisplayDate() : createObj.startDate;
    var lookupSource = "";
    var ixnType = "";
    var mediaType = "";
    var startDate = createObj.startDate;
    var endDate = createObj.endDate;    
    var transferredFrom = (createObj.transferredFrom===undefined) ? "" : createObj.transferredFrom;
    var _FIELDNAME = (createObj.fieldName === undefined) ? "" : createObj.fieldName;
    var _FIELDVALUE = (createObj.fieldValue === undefined) ? "" : createObj.fieldValue;

    switch (createObjType) {
        case "Voice":
            // if outbound then use destination as source
            if (createObj.calltype == "Outbound") {
                lookupSource = createObj.destination;
                //ixnType = "Outbound";
                mediaType = (createObj.mediatype === undefined) ? "" : createObj.mediatype;
                if(createObj.mediatype === undefined || createObj.mediatype === ""){
                	ixnType = "Voice-Outbound Dial"; 
                }
                else ixnType = "Voice-Outbound";
            }
            else {
                if (createObj.role == 'RoleOrigination') {
                    lookupSource = createObj.destination;
                    ixnType = "Voice-Outbound Dial";
                }
                else {
                    lookupSource = createObj.source;
                    ixnType = "Voice-Inbound";
                }
            }
            break;
        case "Email":        	
        	if(createObj.calltype == "Inbound" && createObj.source != undefined && createObj.source != ''){
        		lookupSource = createObj.source;
        		ixnType = "Email-Inbound";
        	}
        	else if(createObj.calltype == "Outbound" && createObj.destination != undefined && createObj.destination != ''){
        			lookupSource = createObj.destination;
        			ixnType = "Email-Outbound";
				 }
            break;
        case "Chat":
            //lookupSource=createObj.userData.FirstName + ' ' + createObj.userData.LastName
            lookupSource = createObj.source;
            ixnType = createObj.type;
            break;
        case "InteractionWorkItem":
            //lookupSource=createObj.userData.FirstName + ' ' + createObj.userData.LastName
            lookupSource = createObj.source;
            ixnType = createObj.type;
            mediaType = createObj.mediaType;
            break;
        case "Sms":
            //lookupSource=createObj.userData.FirstName + ' ' + createObj.userData.LastName
            lookupSource = createObj.source;
            //ixnType = createObj.type;
            //mediaType = createObj.mediaType;
            ixnType = createObj.type;
            break;
        case "WebCallback":
            lookupSource = createObj.source;
            ixnType = createObj.type;
            break;            
        case "OpenMedia":
            //lookupSource=createObj.userData.FirstName + ' ' + createObj.userData.LastName
            lookupSource = createObj.source;
            //ixnType = createObj.type;
            //mediaType = createObj.mediaType;
            ixnType = createObj.mediaType;
            break;
        case "Social":
            lookupSource = createObj.source;
            ixnType = createObj.type;
            break;
        default:
            _log("activity not created for " + createObj.type);
            return;
    }

    if (objIdForActivity != "") {
        _log("createTask: " + ixnType + " using objIdForActivity " + objIdForActivity);
    }
    else {
        _log("createTask: " + ixnType + " using field " + _FIELDNAME + " to search for a value of " + _FIELDVALUE);
        //_log("createTask: " + ixnType + " using lookupSource " + lookupSource + ", not objIdForActivity");
    }

    var _CALL_DURATION = (createObj.duration === undefined) ? "" : createObj.duration;
    var _IXNTYPE = ixnType;
    var _COMMENTS = (createObj.notes === undefined) ? "" : createObj.notes;
    var _DISP = (createObj.userData.DispositionCode === undefined) ? "" :
        createObj.userData.DispositionCode;
    var _DNIS = (createObj.destination === undefined) ? "" : createObj.destination;
    var _GENESYSID = (createObj.id === undefined) ? "" : createObj.id;
    var _ANI = (createObj.source === undefined) ? "" : createObj.source;
    var _SFDC_OBJECT_ID = objIdForActivity;
    
    //email specific
    var _Attachment_Flag = (createObj.Attachment_Flag === undefined) ? "" : createObj.Attachment_Flag;
    var _EMAIL_DESC = (createObj.emailDescription === undefined) ? "" : createObj.emailDescription;
    if(_EMAIL_DESC != ""){
    	_EMAIL_DESC = "\n" + "***EMAIL***" + _EMAIL_DESC;
    }
    
    var _CHAT_TRANSCRIPT = (createObj.transcript === undefined) ? "" : createObj.transcript;
    if(_CHAT_TRANSCRIPT != ""){
    	_CHAT_TRANSCRIPT = "\n" + "***CHAT***" + "\n" + _CHAT_TRANSCRIPT;
    }
    
    if(_COMMENTS != ""){
    	_COMMENTS = "*** NOTES ***" + "\n" + _COMMENTS;
    }
    if(_EMAIL_DESC != ""){
    		_COMMENTS = "\n" +_COMMENTS + _EMAIL_DESC;
    }
    if(_CHAT_TRANSCRIPT != ""){
    		_COMMENTS = "\n" +_COMMENTS + _CHAT_TRANSCRIPT;
    }

    
    var _SFDC1value = (createObj.SFDC1value === undefined) ? "" : createObj.SFDC1value;
    var _SFDC2value = (createObj.SFDC2value === undefined) ? "" : createObj.SFDC2value;
    var _SFDC3value = (createObj.SFDC3value === undefined) ? "" : createObj.SFDC3value;
    var _SFDC4value = (createObj.SFDC4value === undefined) ? "" : createObj.SFDC4value;
    var _SFDC5value = (createObj.SFDC5value === undefined) ? "" : createObj.SFDC5value;
    var _SFDC1field = (createObj.SFDC1field === undefined) ? "" : createObj.SFDC1field;
    var _SFDC2field = (createObj.SFDC2field === undefined) ? "" : createObj.SFDC2field;
    var _SFDC3field = (createObj.SFDC3field === undefined) ? "" : createObj.SFDC3field;
    var _SFDC4field = (createObj.SFDC4field === undefined) ? "" : createObj.SFDC4field;
    var _SFDC5field = (createObj.SFDC5field === undefined) ? "" : createObj.SFDC5field;

    _log("creating task map");
    var mapActivity = {
    	"Call Duration": _CALL_DURATION,
        "IXN Type": _IXNTYPE,
        "Comments": _COMMENTS,
        "Disposition": _DISP, "DNIS": _DNIS,
        "GenesysId": _GENESYSID, "ANI": _ANI,
        "sfdc Object Id": _SFDC_OBJECT_ID,
        "SFDC1value": _SFDC1value, "SFDC2value": _SFDC2value, "SFDC3value": _SFDC3value,
        "SFDC4value": _SFDC4value, "SFDC5value": _SFDC5value,
        "SFDC1field": _SFDC1field, "SFDC2field": _SFDC2field, "SFDC3field": _SFDC3field,
        "SFDC4field": _SFDC4field, "SFDC5field": _SFDC5field,
        "Media Type": mediaType,
        "DATE": displayDate, 
        "fieldName" : _FIELDNAME, "fieldValue" : _FIELDVALUE,
        //"LOOKUP": lookupSource,  NO LONGER USED
        "StartDate": startDate, "EndDate": endDate,
        "TransferredFrom": transferredFrom
    };

    g_WorkspaceConnectorController.createActivity(mapActivity, function(result, event) {
        _log("createActivity RESULT = " + result);

        if (result != null && result != "not found") {
            _log("redirect to new activity - " + result);
            Salesforce.screenPopRefresh(result);
            if(_Attachment_Flag == 'True'){
            	_log("Get attachment info");
	        	//Attachment info is in the form of :
	        	//	"attachments": [
	            //		{"id":"1", "name":"a.zip", "desc":"file a", "mimeType":"gzip"},
	            //		{"id":"2", "name":"b.zip", "desc":"file b", "mimeType":"gzip"}
	        	//	]
	
	        	var attachmentInfo = createObj.attachments;
	            getAttachment(attachmentInfo,createObj.id,0,result);
            }
        }
        else {
            _log("Could not create task for");
        }
    });
}

function getAttachment(arrAttachId,interactionId,idx,myTaskID){
	_log("in getAttachment");
    
    if(arrAttachId.length > idx ){
    	var wsParams = Workspace.getParameters();	
    	var msgJ;
    	if(arrAttachId.length == (idx+1))
    		//final request
    		msgJ = '{"action":"RequestAttachment",' + wsParams.CI_connectionData + ',"actionData":{"id":"' + interactionId + '","attachmentID":"' + arrAttachId[idx].id + '","attachmentName":"' + arrAttachId[idx].name + '","finalRequest":"true"}}';
    	else
    		msgJ = '{"action":"RequestAttachment",' + wsParams.CI_connectionData + ',"actionData":{"id":"' + interactionId + '","attachmentID":"' + arrAttachId[idx].id + '","attachmentName":"' + arrAttachId[idx].name + '"}}';
    	
        //this.requestUrl = wsParams.pollUrl + ":" + wsParams.pollPort + "/request=" + msgJ;
    	//_log("getAttachment url = " + this.requestUrl);
        this.requestUrl = wsParams.pollUrl + ":" + wsParams.pollPort;
        _log("getAttachment data = " + msgJ);
	    $.ajax({
	        url: requestUrl,
	        data: "/request=" + msgJ,
	        timeout: 20000,
	        async: true,
	        crossDomain: true,
	        cache: false,
	        //dataType: 'text',
	        dataType: 'jsonp',
	        success: function (data) {
	            // call the callback on retrieval

            	//setup first time call info
    			var attachmentInfo = arrAttachId[idx];
    			attachmentInfo.positionIndex = 0;
    			var attachmentId = null;
    			uploadAttachment(attachmentId,data,attachmentInfo,myTaskID);
    			getAttachment(arrAttachId,interactionId,idx+1,myTaskID);
        	},
	        error: function (xhr, ajaxOptions, thrownError) {
	            if (thrownError == 'timeout')
	                _log("Failed to connect for attachment request");
	            else
	                _log('Request error ' + xhr.status + ' ' + thrownError);
	        }
	    });
    }
}

/*
* Process the attachment data response
*/


var maxStringSize = 6000000;    //Maximum String size is 6,000,000 characters
var maxFileSize =   4350000;    
var chunkSize =      950000;    //Maximum Javascript Remoting message size is 1,000,000 characters


function uploadAttachment(attachmentId,attachmentData,attachmentInfo,myTaskID) {
    var attachmentBody = "";
    //var descriptionText = "";
    //var nameText = "";
    //var mimeType = "";
    var doneUploading = false;
    var positionIndex = attachmentInfo.positionIndex;
    var attachment = (attachmentData.attachment === undefined) ? "" : attachmentData.attachment;
    var descriptionText = (attachmentInfo.desc === undefined) ? "" : attachmentInfo.desc;
    var nameText = (attachmentInfo.name === undefined) ? "" : attachmentInfo.name;
    var mimeType = (attachmentInfo.mimeType === undefined) ? "" : attachmentInfo.mimeType;
    var fileSize = attachment.length;
    _log("uploadAttachment " + nameText + ", fileSize = " + fileSize);
    //temporary check to prevent this APEX error
    // String length exceeds maximum: 6000000
    if(fileSize > maxStringSize){
    	_log("error adding attachment - String length exceeds maximum: 6000000");
    	return;
    }
    if(fileSize <= positionIndex + chunkSize) {
      attachmentBody = attachment.substring(positionIndex);
      doneUploading = true;
    } else {
      attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
    }
    

    _log("Uploading " + attachmentBody.length + " chars of " + fileSize);
    g_WorkspaceConnectorController.addAttachment(myTaskID,descriptionText,nameText,mimeType,attachmentBody,attachmentId, function(result){
    	_log("addAttachment result = " + result);
    	if(result != null && result != "error") {
        	//OOP = Attachment
          if(result.substring(0,3) == '00P') { 
            if(doneUploading == true) {
              _log("doneUploading");
              //refresh the attachment
              Salesforce.screenPopRefresh(myTaskID);
            } else {
              _log("continueUploading");             
              attachmentInfo.positionIndex += chunkSize; 
              _log("total uploaded so far = " + attachmentInfo.positionIndex);
              uploadAttachment(result,attachmentData,attachmentInfo,myTaskID);
            }
          }
        } else {
          _log("error adding attachment");
        }
      }
    );
  }

var tabId = function tabId(result){
		_log("tabId result = "+result.id);
		sforce.console.refreshPrimaryTabById(result.id,true,function(refreshResult){
			_log("refreshPrimaryTabById result = "+refreshResult.success);
		});
}



})(window, jQuery, undefined);
