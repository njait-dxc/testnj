/**************************************************************************************************
* Name               : SelectAttachmentsController                                                *
* Description        : Controller class for SelectAttachment Lightning component                  *
* Created Date       : 25/02/2020                                                                 *
* Created By         : Nikhil Jaitey                                                              *
* ------------------------------------------------------------------------------------------------*
* VERSION  AUTHOR    		 DATE            COMMENTS                                             *
* 1.0      Nikhil Jaitey     25/02/2020      Initial Draft.                                       * 
**************************************************************************************************/
public class SelectAttachmentsController {
	
    /******************************************************************************************************
    * @Description        : Function to send all the attach ContentVersion related to a record Id         *
    * @Author             : Nikhil Jaitey                                                                 *
    * @Last Modified By   : Nikhil Jaitey                                                                 *
    * @Last Modified On   : 25/02/2020                                                                    *
    * @Params             : caseId                                                                        * 
    * @Return             : List<ContentVersion>                                                          * 
    *******************************************************************************************************/
    @AuraEnabled
    public static List< ContentVersion > getAttachments( String caseId ){
        
        List< ContentDocumentLink > lstContentDocuments = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = : caseId];
        if( lstContentDocuments != NULL && lstContentDocuments.size() > 0 ){
            Set< Id > CDIdList 				  = new Set< Id >();
            List< ContentVersion > CVmainList = new List< ContentVersion >();
            for ( ContentDocumentLink nextCDL : lstContentDocuments ) {
                CDIdList.add( nextCDL.ContentDocumentId ); 
            }            
            List< ContentDocument > entries = [ SELECT Id, Title, FileType FROM ContentDocument WHERE ContentDocument.Id IN :CDIdList ];
            List< ContentVersion > CVList   = [ SELECT Id, ContentDocumentId, isLatest, Title 
                                       		    FROM   ContentVersion 
                                       		    WHERE  ContentDocumentId = :CDIdList AND isLatest = true ];
            return CVList;
        }
        else{
            List< ContentVersion > CV = new List< ContentVersion >();
            CV = NULL;
            return CV;
        }
    }
    
    /****************************************************************************************************
    * @Description 		  : Function to save file in chunks if greater than 4MB else normally           * 
    * @Author             : Nikhil Jaitey                                                        		*
    * @Last Modified By   : Nikhil Jaitey                                                        		*
    * @Last Modified On   : 02/03/2020                                                          		* 
    * @Params     		  : Id, String, String, String, String                                          *
    * @Return     		  : Id                                                                          *
    *****************************************************************************************************/
    @AuraEnabled
    public static Id saveChunk(Id caseId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (String.isBlank(fileId)) {
            fileId = saveTheFile(caseId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        system.debug(fileId);
        return Id.valueOf(fileId);
    }
    
    /****************************************************************************************************
    * @Description 		  : Function to save file                                                       *  
    * @Author             : Nikhil Jaitey                                                        		*
    * @Last Modified By   : Nikhil Jaitey                                                        		*
    * @Last Modified On   : 02/03/2020                                                          		* 
    * @Params      		  : Id, String, String, String                                                  *
    * @Return      		  : Id                                                                          *
    *****************************************************************************************************/
    public static Id saveTheFile(Id caseId, String fileName, String base64Data, String contentType){
        system.debug('############ saveTheFile ');
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
        conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conver.IsMajorVersion = false;
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        conVer.VersionData =EncodingUtil.base64Decode(base64Data); // converting your binary string to Blob
        insert conVer;
        
        // First get the content document Id from ContentVersion
        Id conDocID = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDocID;
        cDe.LinkedEntityId = caseId; // you can use objectId,GroupId etc
        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.Visibility = 'AllUsers';
        insert cDe;
        
        return conVer.ID;
        
    }
    
    /****************************************************************************************************
    * @Description 		  : Function to append the rest of the chunk to already uploaded part of file   *  
    * @Author             : Nikhil Jaitey                                                        		*
    * @Last Modified By   : Nikhil Jaitey                                                        		*
    * @Last Modified On   : 02/03/2020                                                          		* 
    * @Params      		  : Id, String                                                                  *
    * @Return      		  : void                                                                        *
    *****************************************************************************************************/
    private static void appendToFile(Id fileId, String base64Data) {
        system.debug(fileId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion a = [ SELECT Id, VersionData FROM ContentVersion WHERE Id =: fileId ];
            
        String existingBody = EncodingUtil.base64Encode(a.VersionData);
        a.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
        update a;
    }
}