public without sharing class LoginController {
    
    @AuraEnabled
    public static string login(String username, String password){
        try {
            String starturl = '/wbconnectplus/';
            ApexPages.PageReference pageRef = Site.login(username, password, starturl);
            if(pageRef != null){
                return pageRef.getUrl();
            } else {
                throw new AuraHandledException('Error Logging in. Please contact to administrator.');
            }
        } catch (Exception e) {
            // Common login errors include INVALID_LOGIN, so return a clean error
            if (e.getMessage().contains('INVALID_LOGIN')) {
                throw new AuraHandledException('Invalid username or password.');
            }
            // For anything else, show a general error
            throw new AuraHandledException('Login error: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> forgotPassword(String usernameval){
        try {
            List<User> lstUser = [SELECT Id, Username FROM User WHERE Username =: usernameval];

            if(!lstUser.isEmpty()) {
                    boolean blnSuccess = Site.forgotPassword(usernameval);
                    System.debug(blnSuccess);
                    List<string> str = new List<string>{'Success', 'Success'};
                    return str;
            }else {
                List<string> str = new List<string>{'Error', 'Username does not match any records in our System. Please Enter a valid Username!'};
                return str;
            }
        } catch (Exception e) {
            System.debug(e);
            List<string> str = new List<string>{'Error', 'Something Went Wrong', 'getMessagelogin => '+e.getMessage() + 'line no => '+e.getLineNumber()};
            return str;
        }
    }
}