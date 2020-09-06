global inherited sharing class QuickCasecomment
{
     
  public QuickCasecomment(ApexPages.StandardController controller)  {  
  }
  
  @RemoteAction
  global static Boolean CreateComment(Id CaseId,String comment,String publish)
  {
    if (Schema.SObjectType.Case.isUpdateable() || Schema.SObjectType.Case.isCreateable())
    {
      CaseComment newCom = new CaseComment();
      newCom.ParentId = CaseId;
      newCom.CommentBody = comment;

      if (publish == 'true')
      {
        newCom.IsPublished = true;
      }
      else
      {
        newCom.IsPublished = false;
      }

      try
      {
        //insert newCom;
        try
          {
                Database.SaveResult insertCommunitiesUserResult = Database.insert(newCom,true);
          }
          catch(Exception e){
                LogUtilityException.throwException('QuickCasecomment', 'CreateComment', e,new List<CaseComment>{newCom});
          }

        return true;
      } catch (Exception ex)
      {
        return false;
      }
    }
    else
    {
      return false;
    }
  }
}