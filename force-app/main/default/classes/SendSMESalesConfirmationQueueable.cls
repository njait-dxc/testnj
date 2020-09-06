public class SendSMESalesConfirmationQueueable implements Queueable, Database.AllowsCallouts {
    public List<Id> OpportunityId ;
    
    public SendSMESalesConfirmationQueueable(List<Id> OppId)
    {
        this.OpportunityId = OppId ;  
    }    

    public void execute(QueueableContext context) 
    {
        Integer counter = Limits.getLimitEmailInvocations();
        Map<Id,Id> processedIds = new Map<Id,Id>();
        List<Id> remainingIds = new List<Id>();

        List<Opportunity> opp = [Select Id, CurrencyIsoCode, name, StageName,Main_Contact__c, Main_Contact_Name__c, Main_Contact_Email__c,owner.email, Owner.FirstName,Owner.LastName From Opportunity Where Id = :OpportunityId];
        EmailTemplate emailTemplate = [Select id from EmailTemplate where name = 'SME Sales Confirmation'];
        System.debug('Scope Size'+opp.size());
        for (Opportunity o : opp) {
            if(counter <= Limits.getEmailInvocations())
            {
                System.debug('Email Sent'+ Limits.getEmailInvocations());
                break;
            }
            processedIds.put(o.Id,o.Id);
            PageReference pdf = Page.SMESalesConfirmation;
            pdf.getParameters().put('id', o.Id);

            Blob b;
            if (Test.IsRunningTest()) {
                b = Blob.valueOf('UNIT.TEST');
            } else {
                b = pdf.getContentAsPDF();
            }


            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('MYOB Wholesale Receipt' + '.pdf');
            efa.setBody(b);

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(emailTemplate.Id);
            email.setTargetObjectId(o.Main_Contact__c);
            email.setWhatId(o.Id);
            //email.setSubject('MYOB Sales Confirmation');
            email.setToAddresses(new List<String>{
                    o.Main_Contact_Email__c
            });
            email.setCcAddresses(new List<String>{
                    o.owner.email
            });
            /*email.sethtmlBody('Hi '+opp.Main_Contact_Name__c + ',<br/><br/> '
                                    +'Please find the attached MYOB sales confirmation.'
                                    +'<br/><br/>'+'Thanks,'+'<br/>'
                                    +opp.owner.FirstName+' ' + opp.owner.LastName+ '<br/>'
                                    +UserInfo.getOrganizationName());*/
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{
                    efa
            });

            try {
                //MYOB AB 06/02/2020 Added the code to create the document link in opportunity
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = b;
                cv.Title = 'MYOB Wholesale Receipt';
                cv.PathOnClient = 'MYOB Wholesale Receipt' + '.pdf';

                insert cv;


                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = o.Id;
                cdl.ShareType = 'V';
                insert cdl;

                Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        email
                });

            } catch (System.Exception e) {
                LogUtilityException.throwException('SendSMESalesConfirmationQueueable','execute',e,opp);
            }
        }

        //still needs more email to send, recall this class again
        for(Opportunity op : opp)
        {
            if(!processedIds.containsKey(op.Id))
            {
                remainingIds.add(op.Id);
            }
        }
        if(remainingIds.size() > 0)
        {
            System.debug(remainingIds.size());
           System.enqueueJob(new SendSMESalesConfirmationQueueable(remainingIds));
        }
    }
}