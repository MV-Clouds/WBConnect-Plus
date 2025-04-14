/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-11-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global without sharing class EmbeddedSignUpController {

    public static String whatsappBusinessAppId {get; set;}
    public static String clientId {get; set;}
    public static String configurationId {get; set;}
    public static String clientSecret {get; set;}

    // Constructor to load the metadata record
    public EmbeddedSignUpController() {
        // Fetch the metadata record
        List<WBConnect_Meta_Configuration__c  > configList = [SELECT Application_Id__c, Business_Account_Id__c, Access_Token__c, Phone_Number_Id__c FROM WBConnect_Meta_Configuration__c];
        if(configList.size() > 0){
            whatsappBusinessAppId = configList[0].Business_Account_Id__c;
        }else {
            whatsappBusinessAppId = '';
        }

        List<EmbeddedSignUpConfig__c> embeddedConfig = [SELECT Id, Config_Id__c, Client_Secret__c, Client_Id__c FROM EmbeddedSignUpConfig__c];
        if(embeddedConfig.size() > 0){
            clientId = embeddedConfig[0].Client_Id__c;
            clientSecret = embeddedConfig[0].Client_Secret__c;
            configurationId = embeddedConfig[0].Config_Id__c;
        }

    }

    @RemoteAction
    global static String saveFBLoginDetails(String sAccessToken, String phoneId, String wabaId, String appId){
        try{

            List<EmbeddedSignUpConfig__c> embeddedConfig = [SELECT Id, Config_Id__c, Client_Secret__c, Client_Id__c FROM EmbeddedSignUpConfig__c];
            if(embeddedConfig.size() < 1){
                ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsappConfigController', 'methodName' => 'saveFBLoginDetails', 'exceptionObj' => null, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => 'No Embedded Sign Up Configuration Found!', 'apiResponse' => null });
                return 'Failure';
            }
            
            String tokenUrl = 'https://graph.facebook.com/v22.0/oauth/access_token?grant_type=fb_exchange_token&client_id=' + embeddedConfig[0].Client_Id__c + '&client_secret=' + embeddedConfig[0].Client_Secret__c + '&fb_exchange_token='+sAccessToken;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(tokenUrl);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseBody1 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String accessToken = (String) responseBody1.get('access_token');
                Boolean isSuccess = saveMetaData(accessToken, phoneId, wabaId, appId, true);
                if(isSuccess){
                    return wabaId;
                }
            }
        }catch(Exception e){
            System.debug('saveFBLoginDetails');
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsappConfigController', 'methodName' => 'saveFBLoginDetails', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => 'Could not save the embedded sign up details!', 'apiResponse' => null });
        }
        return null;
        
    }

    @RemoteAction
    global static Boolean unlinkAccount(){
        try{
            Boolean isSuccess = saveMetaData('', '', '', '', false);
            if(isSuccess){
                return true;
            }
        }catch(Exception e){
            System.debug('unlinkAccount');
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsappConfigController', 'methodName' => 'unlinkAccount', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => 'Could not clear the configuration values!', 'apiResponse' => null });
        }
        return false;
    }
    
    
    public static Boolean saveMetaData(String accessToken, String phoneId, String wabaId, String appId, Boolean configStatus){

        System.debug('SaveMetaData method');
        try {
            List<WBConnect_Meta_Configuration__c  > configList = [SELECT Application_Id__c, Business_Account_Id__c, Access_Token__c, Phone_Number_Id__c FROM WBConnect_Meta_Configuration__c];
            if(configList.size() > 0){
                whatsappBusinessAppId = configList[0].Business_Account_Id__c;
            }else {
                whatsappBusinessAppId = '';
            }

            WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c();
            config.Application_Id__c = appId;
            config.Business_Account_Id__c = wabaId;
            config.Access_Token__c = accessToken;
            config.Phone_Number_Id__c = phoneId;
            config.Is_WBA_Configured__c = configStatus;

            insert config;

            return true;
            
        } catch (Exception e) {
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsappConfigController', 'methodName' => 'saveMetaData', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => 'Could not save the embedded sign up details in the metadata!', 'apiResponse' => null });
            return null;
        }

    }
    
}