/**
 * An apex class that updates portal user details.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {

    private User user;
    private Boolean isEdit = false;

    public User getUser() {
        return user;
    }

    public MyProfilePageController() {
        user = [SELECT Id, Email, Username, UserType, CommunityNickname, TimeZoneSidKey, LanguageLocaleKey, FirstName, LastName, Phone, Title,
                Street, City, Country, PostalCode, State, LocaleSidKey, MobilePhone, Extension, Fax, Contact.Email
                FROM User
                WHERE Id = :UserInfo.getUserId()];
        // guest users should never be able to access this page
        if (user.UserType == 'GUEST') {
            throw new NoAccessException();
        }
    }

    public Boolean getIsEdit() {
        return isEdit;
    }

    public void edit() {
        isEdit=true;
    }

    public void save() {
        try {
            update user;
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public PageReference changePassword() {
        return Page.ChangePassword;
    }

    public void cancel() {
        isEdit=false;
        user = [SELECT Id, Email, Username, CommunityNickname, TimeZoneSidKey, LanguageLocaleKey, FirstName, LastName, Phone, Title,
                Street, City, Country, PostalCode, State, LocaleSidKey, MobilePhone, Extension, Fax, Contact.Email
                FROM User
                WHERE Id = :UserInfo.getUserId()];
    }    
}