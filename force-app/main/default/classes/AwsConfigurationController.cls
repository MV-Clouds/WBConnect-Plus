/** 
* Class Name: getConfiguration 
* Test Class:
* @description: Used in awsConfiguration LWC components
* Date: 19/03/2025
* Created By: Kavya Trivedi
*/
public without sharing class AwsConfigurationController {

    public static String userAccountId = WhatsAppWebhook.getUserAccount();

    /** 
    * Method Name : getConfiguration 
    * @description : get AWS Configuration
    * @return AWS_Config__c record
    */
    @AuraEnabled
    public static WBConnect_Meta_Configuration__c getConfiguration() {
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c();
        try {
            List<WBConnect_Meta_Configuration__c> configList = [SELECT Id, AWS_Access_Key__c, AWS_Secret_Access_Key__c, S3_Bucket_Name__c, S3_Region_Name__c FROM WBConnect_Meta_Configuration__c WHERE Is_AWS_Configured__c = true LIMIT 1]; 
            if (!configList.isEmpty()) {
                config = configList[0];
            } else {
                config.AWS_Access_Key__c = '';
                config.AWS_Secret_Access_Key__c = '';
                config.S3_Bucket_Name__c = '';
                config.S3_Region_Name__c = '';
            }
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AwsConfigurationController','methodName' => 'getConfiguration','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
        }
        return config;
    }

    /** 
    * Method Name : saveConfiguration 
    * @description : save AWS Configuration
    * @return success/error
    */
    @AuraEnabled
    public static String saveConfiguration(String accessKey, String secretAccessKey, String bucketName, String regionName) {
        try {
            List<WBConnect_Meta_Configuration__c> configList = [SELECT Id, AWS_Access_Key__c, AWS_Secret_Access_Key__c, S3_Bucket_Name__c, S3_Region_Name__c FROM WBConnect_Meta_Configuration__c WHERE Is_AWS_Configured__c = true LIMIT 1];
            
            WBConnect_Meta_Configuration__c config;
            if (!configList.isEmpty()) {
                config = configList[0];
            } else {
                config = new WBConnect_Meta_Configuration__c();
            }

            config.AWS_Access_Key__c = accessKey;
            config.AWS_Secret_Access_Key__c = secretAccessKey;
            config.S3_Bucket_Name__c = bucketName;
            config.S3_Region_Name__c = regionName;
            config.Account__c = userAccountId;

            upsert config;

            return 'Success';
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AwsConfigurationController','methodName' => 'saveConfiguration','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return 'Error';
        }
    }

    /** 
    * Method Name : deleteRecordByAccessKey 
    * @description : delete AWS Configuration
    * @throws IllegalArgumentException If record is not found
    */
    @AuraEnabled
    public static void deleteRecordByAccessKey(String accessKey) {
        try {
            List<WBConnect_Meta_Configuration__c> records = [SELECT Id FROM WBConnect_Meta_Configuration__c WHERE AWS_Access_Key__c = :accessKey LIMIT 1];

            if (!records.isEmpty()) {
                delete records[0];
            } else {
                throw new IllegalArgumentException('Record not found');
            }
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AwsConfigurationController','methodName' => 'deleteRecordByAccessKey','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
        }
    }    
}