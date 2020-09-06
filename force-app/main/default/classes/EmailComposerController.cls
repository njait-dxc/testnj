/**************************************************************************************************
* Name               : EmailComposerController                                                    *
* Description        : Controller class for EmailComposer Lightning component                     *
* Created Date       : 24/02/2020                                                                 *
* Created By         : Nikhil Jaitly                                                              *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR            DATE            COMMENTS                                             *
* 1.0      Nikhil Jaitly     24/02/2020      Initial Draft.                                       * 
**************************************************************************************************/
public without sharing class EmailComposerController {
    
    /******************************************************************************************************
    * @Description        : Function to auto populate toAddress, ccAddress, Subject of the email          *
    * @Author             : Nikhil Jaitly                                                                 *
    * @Last Modified By   : Nikhil Jaitly                                                                 *
    * @Last Modified On   : 24/02/2020                                                                    *
    * @Params             : CaseId                                                                        * 
    * @Return             : EmailWrapper                                                                  * 
    *******************************************************************************************************/
    @AuraEnabled
    public static EmailWrapper loadEmailData( String caseId ){

        EmailWrapper email = new EmailWrapper();
 
          Support_Setting__mdt folderId = [SELECT Value__c FROM Support_Setting__mdt WHERE DeveloperName = 'MassCommsFolderId'];
        
          List< EmailTemplate > lstEmailTemp = [ SELECT Id, Name, Body, HtmlValue, DeveloperName FROM EmailTemplate WHERE FolderId = :folderId.Value__c];
           
        email.emailTemps = lstEmailTemp;
        
        for( OrgWideEmailAddress orgEml : [ SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'MYOB - PS - Client Support AU' LIMIT 1 ] ) {
            email.orgWideAddress = orgEml;
        }
        
        for( Case cs : [ SELECT Id, CaseNumber, OwnerId, Owner.Email, ContactEmail, (SELECT Id, ContactEmail FROM Cases) FROM Case WHERE Id = :caseId ] ){
            email.toAddress = cs.ContactEmail;
            //email.ccAddress = cs.Owner.Email;
                
            for( Case childCase : cs.Cases ){
                email.toAddress +=   ','+childCase.ContactEmail;       
            } 
        }
        return email;
    }

    /******************************************************************************************************
    * @Description        : Function to get Template details                                              *
    * @Author             : Nikhil Jaitly                                                                 *
    * @Last Modified By   : Nikhil Jaitly                                                                 *
    * @Last Modified On   : 03/03/2020                                                                    *
    * @Params             : templteId                                                                     * 
    * @Return             : EmailTemplate                                                                  * 
    *******************************************************************************************************/
    @AuraEnabled 
    public static EmailTemplate getTemplateDetails(string templteId){
        
        EmailTemplate emailTemp = new EmailTemplate();
        list<EmailTemplate> emailTempLst = new list<EmailTemplate>();
        emailTempLst = [SELECT Id,Name,Subject,TemplateType,body,HtmlValue FROM EmailTemplate WHERE ID=: templteId];
        
        emailTemp = emailTempLst.size()>0 ? emailTempLst[0] : emailTemp;
        return emailTemp;
        
    }
    
    /******************************************************************************************************
    * @Description        : Function to send an email from apex                                           *
    * @Author             : Nikhil Jaitly                                                                 *
    * @Last Modified By   : Nikhil Jaitly                                                                 *
    * @Last Modified On   : 27/02/2020                                                                    *
    * @Params             : toAddress, ccAddress, subject, body, files                                    * 
    * @Return             : EmailWrapper                                                                  * 
    *******************************************************************************************************/
    @AuraEnabled
    public static void sendEmailApex( EmailWrapper emailData, String caseId, EmailTemplate emailTemp, List< String > files  ) {

        List< Messaging.SingleEmailMessage > emailList = new List< Messaging.SingleEmailMessage >();
        List< String > toAddressList                   = new List< String >();
        List< String > ccAddressList                   = new List< String >();
        
        if( emailData != null  ){
            toAddressList = emailData.toAddress.split( ',' );
            if( String.isNotEmpty( emailData.ccAddress )){
                ccAddressList = emailData.ccAddress.split( ',' );
            }
        }

        try{
            for( Case cs : [ SELECT Id, ContactId, Owner.Email, ContactEmail, (SELECT Id, Owner.Email, ContactId, ContactEmail FROM Cases) FROM Case WHERE Id = :caseId ] ){
                Messaging.SingleEmailMessage email;
                if( toAddressList.contains( cs.ContactEmail )){
                    email = Messaging.renderStoredEmailTemplate( emailTemp.Id , cs.ContactId, cs.Id );
                    email.setTreatTargetObjectAsRecipient( false );
                    email.setToAddresses( new List< String >{ cs.ContactEmail } );
                    email.setCcAddresses( ccAddressList );
                    email.setOrgWideEmailAddressId( emailData.orgWideAddress.Id );
                    email.setWhatId( cs.Id );
                    emailList.add( email );
                }
                    

                for( Case chileCase : cs.Cases ){
                    if( toAddressList.contains( chileCase.ContactEmail )){
                        email = Messaging.renderStoredEmailTemplate( emailTemp.Id , chileCase.ContactId, chileCase.Id );
                        email.setTreatTargetObjectAsRecipient( false );
                        email.setToAddresses( new List< String >{ chileCase.ContactEmail } );
                        email.setCcAddresses( ccAddressList );
                        email.setOrgWideEmailAddressId( emailData.orgWideAddress.Id );
                        email.setWhatId( chileCase.Id );
                        emailList.add( email );
                    }
                }
            }
            system.debug( 'emailList >>> '+emailList.size() );
            system.debug( 'emailList >>> '+emailList );
            if( !emailList.isEmpty() ){
                Messaging.sendEmail( emailList );
            }
        }
        catch ( exception e ){
            throw new AuraHandledException( e.getMessage() );
        }
    }
    
    // Inner Class
    public class EmailWrapper{
        @AuraEnabled public OrgWideEmailAddress orgWideAddress{get;set;}
        @AuraEnabled public String toAddress{get;set;}
        @AuraEnabled public String ccAddress{get;set;}
        @AuraEnabled public String subject{get;set;}
        @AuraEnabled public List< EmailTemplate > emailTemps{get;set;}
    }
}