/**************************************************************************************************
* Name               : TaskContactDropdownController                                              *
* Description        : Controller Class for TaskContactDropdown component                         *
* Created Date       : 01/05/2020                                                                 *
* Created By         : Nikhil Jaitly                                                              *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR    DATE            COMMENTS                                                     *
* 1.0      Nikhil    01/05/2020      Initial Draft.                                               * 
**************************************************************************************************/
public class TaskContactDropdownController {
    
    /******************************************************************************************************
    * @Description        : Function to get the contact details for taskContactDropdown component         *
    * @Author             : Nikhil Jaitly                                                                 *
    * @Last Modified By   : Nikhil Jaitly                                                                 *
    * @Last Modified On   : 01/05/2020                                                                    *
    * @Params             : taskId                                                                        * 
    * @Return             : List< ContactInfoWrapper >                                                    * 
    *******************************************************************************************************/
    @AuraEnabled
    public static List< ContactInfoWrapper > getContacts(String taskId){ 
        
        List< ContactInfoWrapper > lstContactInfoWrapper = new List< ContactInfoWrapper >();
    	List< Task > taskRec = [ SELECT Id, WhatId, WhoId FROM Task Where Id = :taskId ];
        
        if( !taskRec.isEmpty() ) {
            String whatId = taskRec[0].whatId; // Account Id
            String whoId = taskRec[0].whoId;   // Contact Id
            if( whatId.startsWith( '001' ) ){
                for( Contact con : [ SELECT Id, Name FROM Contact WHERE AccountId = :whatId ] ){
                    ContactInfoWrapper conWrap = new ContactInfoWrapper( con.Id, con.Name, con.Id == whoId ? true : false );
                    lstContactInfoWrapper.add( conWrap );
                }
                return lstContactInfoWrapper;
            }
        }
        return null;
    }

    /******************************************************************************************************
    * @Description        : Function to updat the contact id of task in whoId                             *
    * @Author             : Nikhil Jaitly                                                                 *
    * @Last Modified By   : Nikhil Jaitly                                                                 *
    * @Last Modified On   : 01/05/2020                                                                    *
    * @Params             : taskId, ConId                                                                 * 
    * @Return             : void                                                                          * 
    *******************************************************************************************************/
    @AuraEnabled
    public static void updateTask(String taskId, String ConId){ 
        
        Task t = new Task( Id = taskId, WhoId = ConId );
        update t;
    }
    
    // Inner Class
    public class ContactInfoWrapper{
        @AuraEnabled public String conId;
        @AuraEnabled public String conName;
        @AuraEnabled public Boolean selected;
        
        public ContactInfoWrapper( String conId, String conName, Boolean selected ){
            this.conId 	  = conId;
            this.conName  = conName;
            this.selected = selected;
        }
    }

}