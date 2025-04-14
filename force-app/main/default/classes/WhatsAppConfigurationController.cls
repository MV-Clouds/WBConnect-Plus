public without sharing class WhatsAppConfigurationController {

    public static String userAccountId = WhatsAppWebhook.getUserAccount();
    
    @AuraEnabled
    public static WBConnect_Meta_Configuration__c getConfiguration(){
        
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c();
        try {
            List<WBConnect_Meta_Configuration__c> configList = [SELECT Id, Access_Token__c, Phone_Number_Id__c, Application_Id__c, Business_Account_Id__c FROM WBConnect_Meta_Configuration__c WHERE Is_WBA_Configured__c = true LIMIT 1];

            if(!configList.isEmpty()){
                config = configList[0];
            } else{
                config.Access_Token__c = '';
                config.Phone_Number_Id__c = '';
                config.Application_Id__c = '';
                config.Business_Account_Id__c = '';
                config.Account__c = userAccountId;
                config.Is_WBA_Configured__c = false;
            }
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'WhatsAppConfigurationController', 'methodName' => 'getConfiguration', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
        return config;
    }

    @AuraEnabled
    public static String saveConfiguration(String WBAccountId, String AppId ,String AccessToken, String PhoneNumberId) {

        try {
            
            List<WBConnect_Meta_Configuration__c> configList = [SELECT Id, Access_Token__c, Phone_Number_Id__c, Application_Id__c, Business_Account_Id__c FROM WBConnect_Meta_Configuration__c WHERE Is_WBA_Configured__c = true LIMIT 1];
            if(!configList.isEmpty()){
                configList[0].Access_Token__c = AccessToken;
                configList[0].Phone_Number_Id__c = PhoneNumberId;
                configList[0].Application_Id__c = AppId;
                configList[0].Business_Account_Id__c = WBAccountId;
                configList[0].Is_WBA_Configured__c = true;
                update configList[0];
            } else {
                WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c();
                config.Access_Token__c = AccessToken;
                config.Phone_Number_Id__c = PhoneNumberId;
                config.Application_Id__c = AppId;
                config.Business_Account_Id__c = WBAccountId;
                config.Is_WBA_Configured__c = true;
                config.Account__c = userAccountId;
                insert config;
            }

            return 'Success';
        }
        catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'WhatsAppConfigurationController', 'methodName' => 'saveConfiguration', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
            return 'Error';
        }
    }
}