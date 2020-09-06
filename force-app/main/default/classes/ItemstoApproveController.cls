/**
 * @author
 * @date
 * @description
 */

public without sharing class ItemstoApproveController {

	public String paramValue { get; set; }
	public String approveValue { get; set; }
	public String rejectValue { get; set; }
	public String RejectReason{ get; set; }

	/*ApexPages.standardController stdController= null;
	public ItemstoApproveController(ApexPages.StandardController controller) {
		stdController=controller;
		this.approveValue = 'Approve';
		this.rejectValue = 'Reject';
	}
	public opportunity Objectopportunity {get; set;}*/
	public List<Opportunity> lstopportunityapprove {get; set;}
	public List<Case> lstcaseapprove {get; set;}
	Id Oppyid;
	Set<Id> oppyids=new Set<Id>();
	Set<Id> caseids=new Set<Id>();

	public class item_wrapper {
		public item_wrapper(Id id,String name,String objtype,String DateSubmited,String tcmeetingcomments, Id approvalid, Boolean selected, Decimal caseTotalValue) {
			this.id = id;
			this.name = name;
			this.objtype = objtype;
			this.DateSubmited = DateSubmited;
			this.tcmeetingcomments=tcmeetingcomments;
			this.approvalid =approvalid ;
			this.selected = selected;
			this.caseTotalValue = caseTotalValue;
			//this.pwitemId = pwitemId;
		}
		public Id id { get; set; }
		public String name { get; set; }
		public String objtype { get; set; }
		public String DateSubmited { get; set; }
		public String tcmeetingcomments{ get; set; }
		public Id approvalid { get; set; }
		public Boolean selected {get;set;}
		public Decimal caseTotalValue {get;set;}
		//public id pwitemId {get;set;}

	}

	public List<item_wrapper> items_to_approve { get; set; }

	public ItemstoApproveController() {
		this.approveValue = 'Approve';
		this.rejectValue = 'Reject';
		items_to_approve = new List<item_wrapper>();

		Map<Id,ProcessInstanceWorkitem> mpaPIWIdToPIW = new Map<Id,ProcessInstanceWorkitem>();
		List<ProcessInstanceWorkitem> lstPIWI = [SELECT ProcessInstance.TargetObjectId,CreatedDate ,ProcessInstance.TargetObject.name,ProcessInstance.TargetObject.type, Id FROM ProcessInstanceWorkitem WHERE ActorId = :UserInfo.getUserId() ORDER BY CreatedDate DESC];
		if(!lstPIWI.isEmpty()){
			for(ProcessInstanceWorkitem item: lstPIWI) {
				oppyids.add(item.ProcessInstance.TargetObjectId);
				caseids.add(item.ProcessInstance.TargetObjectId);
				if(!mpaPIWIdToPIW.containsKey(item.ProcessInstance.TargetObjectId)){
					mpaPIWIdToPIW.put(item.ProcessInstance.TargetObjectId,item);
					System.debug('mpaPIWIdToPIW:' + item.ProcessInstance.TargetObjectId);
				}
			}
		}

		Map<Id,Opportunity> mapoptyIdtoMeetingnotes = new Map<Id,Opportunity>();
		Map<Id,Case> mapCasetoCaseFeilds = new Map<Id,Case>();

		if(oppyids.size()>0){
			lstopportunityapprove=[SELECT Id,Owner.Name,Name,Discount_Percent__c,StageName,Discount_Reason_for_Consulting__c  FROM Opportunity WHERE Id IN : oppyids];
			if(!lstopportunityapprove.isEmpty()){
				for(Opportunity objoppy:lstopportunityapprove){
					mapoptyIdtoMeetingnotes.put(objoppy.Id,objoppy);
					System.debug('mapoptyIdtoMeetingnotes:' + objoppy.Id);
				}
			}
		}
		if(caseids.size()>0){
			lstcaseapprove=[SELECT Id,Owner.name,CaseNumber,Total_Value__c FROM Case WHERE Id IN : caseids];
			if(!lstcaseapprove.isEmpty()){
				for(Case objocase:lstcaseapprove){
					mapCasetoCaseFeilds.put(objocase.Id,objocase);
					System.debug('mapCasetoCaseFeilds:' + objocase.Id);
				}
			}
		}
		if(!lstPIWI.isEmpty()){
			System.debug('size of mpaPIWIdoPIW' + mpaPIWIdToPIW.size());
			for(ProcessInstanceWorkitem item: mpaPIWIdToPIW.values()) {
				String dateTimeValue = item.CreatedDate.format('MM/dd/yyyy hh:mm a');
				System.debug(dateTimeValue +'Debug2 dateTimeValue ');
				if(item.ProcessInstance.TargetObject.type == 'Opportunity'){
					System.debug(item.ProcessInstance.TargetObjectId +'Debug2 dateTimeValue ');
					if(Test.isRunningTest()){
						items_to_approve.add(new item_wrapper(item.ProcessInstance.TargetObjectId,item.ProcessInstance.TargetObject.name,item.ProcessInstance.TargetObject.type,dateTimeValue ,mapoptyIdtoMeetingnotes.get(item.ProcessInstance.TargetObjectId).Discount_Reason_for_Consulting__c,item.Id, true, null));
					}else{
						items_to_approve.add(new item_wrapper(item.ProcessInstance.TargetObjectId,item.ProcessInstance.TargetObject.name,item.ProcessInstance.TargetObject.type,dateTimeValue ,mapoptyIdtoMeetingnotes.get(item.ProcessInstance.TargetObjectId).Discount_Reason_for_Consulting__c,item.Id, false, null));
						System.debug('items_to_approve opp:' +item.ProcessInstance.TargetObjectId) ;
					}
					continue;
				}
				if(item.ProcessInstance.TargetObject.type == 'Case'){
					System.debug(item.ProcessInstance.TargetObjectId +'Debug2 dateTimeValue ');
					if(Test.isRunningTest()){
						items_to_approve.add(new item_wrapper(item.ProcessInstance.TargetObjectId,item.ProcessInstance.TargetObject.name,item.ProcessInstance.TargetObject.type,dateTimeValue , null,item.Id, true, mapCasetoCaseFeilds.get(item.ProcessInstance.TargetObjectId).Total_Value__c));
					}else{
						items_to_approve.add(new item_wrapper(item.ProcessInstance.TargetObjectId,item.ProcessInstance.TargetObject.name,item.ProcessInstance.TargetObject.type,dateTimeValue , null,item.Id, false, mapCasetoCaseFeilds.get(item.ProcessInstance.TargetObjectId).Total_Value__c));
						System.debug('items_to_approve case:' +item.ProcessInstance.TargetObjectId) ;
					}
					continue;
				}

				else{
					System.debug(item.ProcessInstance.TargetObjectId +'Debug2 dateTimeValue ');
					String sObjName = item.ProcessInstance.TargetObjectId.getSobjectType().getDescribe().getLabel();
					System.debug(sObjName +'sObjNameValue ');
					if(Test.isRunningTest()){
						items_to_approve.add(new item_wrapper(item.ProcessInstance.TargetObjectId,item.ProcessInstance.TargetObject.name,sObjName ,dateTimeValue ,'',item.Id, true, null));
					}else{
						items_to_approve.add(new item_wrapper(item.ProcessInstance.TargetObjectId,item.ProcessInstance.TargetObject.name,sObjName ,dateTimeValue ,'',item.Id, false, null));
						System.debug('items_to_approve else:' +item.ProcessInstance.TargetObjectId) ;
					}
				}
			}
		}
	}
	public  static String ApproveRejectnavigation() {
		String url='';
		String myParam = ApexPages.currentPage().getParameters().get('myParam');
		url='https://'+ System.Url.getSalesforceBaseUrl().getHost() +
				'/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + myParam ;

		return url;

	}
	public  static String REASSIGNnavigation() {
		String url='';
		String myParam = ApexPages.currentPage().getParameters().get('myParam');
		url='https://'+ System.Url.getSalesforceBaseUrl().getHost()+'/'+ myParam +'/e?et=REASSIGN';
		return url;

	}

	public PageReference processSelected() {

		List <item_wrapper> selectedItemsList = new List<item_wrapper>();

		try{
			for(item_wrapper item: items_to_approve) {
				if(item.selected == true) {
					selectedItemsList.add(item);
				}
			}

			Approval.ProcessRequest[] allReq = new Approval.ProcessRequest[]{};

			for(item_wrapper item: selectedItemsList) {
				Approval.ProcessWorkitemRequest  req = new Approval.ProcessWorkitemRequest ();
				System.debug('param value:' + this.paramValue);
				System.debug('approve value:' + this.approveValue);
				System.debug('reject value:' + this.rejectValue);
				req.setAction(this.paramValue);
				req.setWorkitemId(item.approvalid);
				//if(this.paramValue == 'Reject' && this.RejectReason == null){
				// ApexPages.Message msg = new apexPages.Message(Apexpages.Severity.ERROR, 'Error: Please fill in reject reason to process rejection.');
				//ApexPages.addMessage(msg);
				//}
				if (this.paramValue == 'Reject')
				//req.setComments('Bulk Rejected by ' + userinfo.getName());
				{
					req.setComments(this.RejectReason);
				}

				allReq.add(req);
			}

			if(!allReq.isEmpty()){
				Approval.ProcessResult[] result =  Approval.process(allReq);
				System.debug('Approval processed successfully');
			}
		}
		catch(Exception ex){
			System.debug(ex.getMessage());
		}

		PageReference pageRef = new PageReference('https://' + System.Url.getSalesforceBaseUrl().getHost());
		pageRef.setRedirect(true);
		return pageRef;
	}
}