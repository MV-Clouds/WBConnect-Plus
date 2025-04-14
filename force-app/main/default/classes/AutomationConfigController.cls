/** 
* Class Name: AutomationConfigController 
* Test Class:
* @description: Used in automationConfig LWC components 
* Date: 26/03/2025 
* Created By: Kavya Trivedi 
*/

public without sharing class AutomationConfigController {

    public static String userAccountId = WhatsAppWebhook.getUserAccount();

    /**
    * Method Name : getAllAutomations
    * @description : Get all Automation records
    * @return List of WBConnect_Automation__c records
    */
    @AuraEnabled
    public static List<WBConnect_Automation__c> getAllAutomations() {
        try {
            return [SELECT Id, Name, Description__c, Template__r.Template_Name__c, Template__r.Template_Type__c FROM WBConnect_Automation__c];
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getAllAutomations','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            System.debug('Error in getAllAutomations: ' + e.getMessage());
            return null;
        }
    }

    /**
    * Method Name : getTemplates
    * @description : Get all Template records
    * @return WBConnect_Template__c records
    */
    @AuraEnabled
    public static List<WBConnect_Template__c> getTemplates() {
        try {
            // Step 1: Fetch valid object names from ChatWindowConfigInfo
            Set<String> validObjectNames = new Set<String>();
            
            // Object_Config__mdt config = [
            //     SELECT ChatWindowConfigInfo__c 
            //     FROM Object_Config__mdt 
            //     WHERE DeveloperName = 'objectConfigInfo' 
            //     LIMIT 1
            // ];
    
            // if (String.isNotBlank(config.ChatWindowConfigInfo__c)) {
            //     Map<String, Object> chatConfig = (Map<String, Object>) JSON.deserializeUntyped(config.ChatWindowConfigInfo__c);
            //     validObjectNames.addAll(chatConfig.keySet());
            // }

            validObjectNames.addAll(new List<String>{
                'Inquiry__c', 'WBConnect_Contact__c'
            });
    
            // if (validObjectNames.isEmpty()) return new List<Template__c>();
    
            // Step 2: Gather valid template IDs from Template Variables
            Set<Id> templatesWithValidObjects = new Set<Id>();
            Set<Id> templatesWithAnyVariables = new Set<Id>();
    
            for (WBConnect_Template_Variable__c tv : [
                SELECT Template__c, Object_Name__c 
                FROM WBConnect_Template_Variable__c
            ]) {
                templatesWithAnyVariables.add(tv.Template__c);
                if (validObjectNames.contains(tv.Object_Name__c)) {
                    templatesWithValidObjects.add(tv.Template__c);
                }
            }
    
            // Step 3: Return templates with valid variables or no variables, and matching status
            List<WBConnect_Template__c> finalTemplates = [
                SELECT Id, Template_Name__c, Template_Type__c 
                FROM WBConnect_Template__c 
                WHERE Status__c = 'Active-Quality Pending'
                  AND (Id IN :templatesWithValidObjects OR Id NOT IN :templatesWithAnyVariables)
                WITH USER_MODE
            ];
    
            return finalTemplates;
    
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getTemplates','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }

    /**
    * Method Name : saveAutomations
    * @description : Save Automation records
    * @param automations List of WBConnect_Automation__c records
    * @return List of WBConnect_Automation__c records
    */
    @AuraEnabled
    public static List<WBConnect_Automation__c> saveAutomations(List<WBConnect_Automation__c> automations) {
        try {
            if (automations == null || automations.isEmpty()) {
                return new List<WBConnect_Automation__c>();
            }
            
            for (WBConnect_Automation__c automation : automations) {
                automation.Account__c = userAccountId;
            }
            insert automations;

            return automations;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'saveAutomations','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            System.debug('Error in saveAutomations: ' + e.getMessage());
            return null;
        }
    }

    /**
    * Method Name : updateAutomations
    * @description : Update Automation records
    * @param automations List of WBConnect_Automation__c records
    * @return List of WBConnect_Automation__c records
    */
    @AuraEnabled
    public static List<WBConnect_Automation__c> updateAutomations(List<WBConnect_Automation__c> automations) {
        try {
            if (automations == null || automations.isEmpty()) {
                return new List<WBConnect_Automation__c>();
            }

            Map<Id, WBConnect_Automation__c> existingRecords = new Map<Id, WBConnect_Automation__c>(
                [SELECT Id, Name, Description__c, Template__c 
                FROM WBConnect_Automation__c 
                WHERE Id IN :automations 
               ]
            );

            List<WBConnect_Automation__c> recordsToUpdate = new List<WBConnect_Automation__c>();

            for (WBConnect_Automation__c newRecord : automations) {
                if (existingRecords.containsKey(newRecord.Id)) {
                    WBConnect_Automation__c existingRecord = existingRecords.get(newRecord.Id);

                    existingRecord.Name = newRecord.Name;
                    existingRecord.Description__c = newRecord.Description__c;
                    existingRecord.Template__c = newRecord.Template__c;

                    recordsToUpdate.add(existingRecord);
                }
            }
            update recordsToUpdate;

            return recordsToUpdate;

        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'updateAutomations','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }

    /**
    * Method Name : deleteAutomations
    * @description : Delete Automation records
    * @param recordIds List of Ids
    * @return void
    */
    @AuraEnabled
    public static void deleteAutomations(List<Id> recordIds) {
        try {
            if (recordIds == null || recordIds.isEmpty()) {
                return;
            }

            if (!Schema.sObjectType.WBConnect_Automation__c.isDeletable()) {
                throw new SecurityException('You do not have permission to delete Automation records.');
            }

            List<WBConnect_Automation__c> recordsToDelete = [
                SELECT Id FROM WBConnect_Automation__c 
                WHERE Id IN :recordIds 
               
            ];

            if (!recordsToDelete.isEmpty()) {
                delete recordsToDelete;
            }

        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'deleteAutomations','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
        }
    }

    /**
    * Method Name : getAutomationsById
    * @description : Get Automation records by Id
    * @return WBConnect_Automation__c record
    */
    @AuraEnabled
    public static WBConnect_Automation__c getAutomationById(Id recordId) {
        try {
            return [SELECT Id, Name, Description__c, Template__r.Template_Name__c, Template__r.Template_Type__c, Template__r.Button_Body__c FROM WBConnect_Automation__c WHERE Id = :recordId LIMIT 1];
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getAutomationById','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }

    /**
    * Method Name : getEmailTemplates
    * @description : Get all Email Template records
    * @return List of EmailTemplate records
    */
    @AuraEnabled
    public static List<EmailTemplate> getEmailTemplates() {
        try {
            return [SELECT Id, Name FROM EmailTemplate];
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getTemplates','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }

    /**
    * Method Name : saveAutomationPaths
    * @description : Save Automation Path records
    * @param automationPaths List of WBConnect_Automation_Path__c records
    * @return List of WBConnect_Automation_Path__c records
    */
    @AuraEnabled
    public static List<WBConnect_Automation_Path__c> saveAutomationPaths(List<WBConnect_Automation_Path__c> automationPaths) {
        try {
            if (automationPaths == null || automationPaths.isEmpty()) {
                return new List<WBConnect_Automation_Path__c>();
            }
            
            Set<Id> automationIds = new Set<Id>();
            Set<String> buttonValues = new Set<String>();

            for (WBConnect_Automation_Path__c path : automationPaths) {
                automationIds.add(path.Automation__c);
                buttonValues.add(path.Button_Value__c);
            }

            List<WBConnect_Automation_Path__c> existingRecords = [
                SELECT Id, Automation__c, Button_Value__c, Action_Type__c, Action_Template__c, 
                    Action_Email_Template__c, Object_Name__c, Field_Mapping__c, WB_Flow__c
                FROM WBConnect_Automation_Path__c
                WHERE Automation__c IN :automationIds AND Button_Value__c IN :buttonValues
            ];

            Map<String, WBConnect_Automation_Path__c> existingRecordsMap = new Map<String, WBConnect_Automation_Path__c>();

            for (WBConnect_Automation_Path__c record : existingRecords) {
                String key = record.Automation__c + '-' + record.Button_Value__c;
                existingRecordsMap.put(key, record);
            }

            List<WBConnect_Automation_Path__c> recordsToUpsert = new List<WBConnect_Automation_Path__c>();

            for (WBConnect_Automation_Path__c path : automationPaths) {
                String key = path.Automation__c + '-' + path.Button_Value__c;

                if (existingRecordsMap.containsKey(key)) {
                    WBConnect_Automation_Path__c existingRecord = existingRecordsMap.get(key);
                    existingRecord.Action_Type__c = path.Action_Type__c;
                    existingRecord.Action_Template__c = path.Action_Template__c;
                    existingRecord.Action_Email_Template__c = path.Action_Email_Template__c;
                    existingRecord.Object_Name__c = path.Object_Name__c;
                    existingRecord.Field_Mapping__c = path.Field_Mapping__c;
                    existingRecord.WB_Flow__c = path.WB_Flow__c;
                    existingRecord.Account__c = userAccountId;

                    recordsToUpsert.add(existingRecord);
                } else {
                    recordsToUpsert.add(path);
                }
            }

            upsert recordsToUpsert;
            return automationPaths;
        } catch (Exception e) {
            System.debug('Error in saveAutomationPaths: ' + e.getMessage());
            System.debug(e.getLineNumber());
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'saveAutomationPaths','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }

    /**
    * Method Name : getAutomationPathsByAutomationId
    * @description : Fetch Automation Path records by Automation Id
    * @param automationId Id of the Automation
    * @return List of WBConnect_Automation_Path__c records
    */
    @AuraEnabled
    public static List<WBConnect_Automation_Path__c> getAutomationPathsByAutomationId(Id automationId) {
        try {
            
            if (String.isEmpty(automationId)) {
                return new List<WBConnect_Automation_Path__c>();
            }
            
            List<WBConnect_Automation_Path__c> automationPaths = [
                SELECT Id, Automation__c, Button_Value__c, Action_Type__c, Action_Template__c, 
                    Action_Email_Template__c, Object_Name__c, Field_Mapping__c, WB_Flow__c
                FROM WBConnect_Automation_Path__c
                WHERE Automation__c = :automationId
            ];
            
            // Return an empty list if no records are found
            return automationPaths != null ? automationPaths : new List<WBConnect_Automation_Path__c>();
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getAutomationPathsByAutomationId','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }

    /**
    * Method Name : getAllObjects
    * @description : Fetch all objects from the schema
    * @return List of Map<String, String> containing object label and value
    */
    @AuraEnabled
    public static List<Map<String, String>> getAllObjects() {
        List<Map<String, String>> objectList = new List<Map<String, String>>();
        
        try {
            // Get all objects from Schema
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            
            for (String objectName : schemaMap.keySet()) {
                Schema.DescribeSObjectResult objDescribe = schemaMap.get(objectName).getDescribe();
                
                objectList.add(new Map<String, String>{
                    'label' => objDescribe.getLabel(),
                    'value' => objectName
                });
            }
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getAllObjects','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
        
        return objectList;
    }

    @AuraEnabled
    public static List<String> getUsedObjectNamesByTemplate(Id templateId) {
        Set<String> usedObjectNames = new Set<String>();

        // First get Automation records linked to the given Template ID
        List<WBConnect_Automation__c> automations = [
            SELECT Id
            FROM WBConnect_Automation__c
            WHERE Template__c = :templateId
        ];
        
        Set<Id> automationIds = new Set<Id>();
        for (WBConnect_Automation__c automation : automations) {
            automationIds.add(automation.Id);
        }

        if (!automationIds.isEmpty()) {
            // Get Object Names used in related WBConnect_Automation_Path__c records
            for (WBConnect_Automation_Path__c path : [
                SELECT Object_Name__c
                FROM WBConnect_Automation_Path__c
                WHERE Automation__c IN :automationIds
                AND Object_Name__c != null
            ]) {
                usedObjectNames.add(path.Object_Name__c.trim());
            }
        }

        // Convert Set to List before returning (for AuraEnabled compatibility)
        return new List<String>(usedObjectNames);
    }

    /**
    * Method Name : getRequiredFields
    * @description : Fetch required fields for a given object
    * @param objectName Name of the object
    * @return List of Map<String, Object> containing field details
    */
    @AuraEnabled
    public static List<Map<String, Object>> getRequiredFields(String objectName) {
        try {
            List<Map<String, Object>> requiredFields = new List<Map<String, Object>>();
            
            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            
            for (Schema.SObjectField field : fieldMap.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
    
                Map<String, Object> fieldInfo = new Map<String, Object>();
                fieldInfo.put('name', fieldDescribe.getName());
                fieldInfo.put('label', fieldDescribe.getLabel());
                fieldInfo.put('type', fieldDescribe.getType().name());
    
                // Handle picklist values
                if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                    List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                    List<String> picklistValues = new List<String>();
                    List<Map<String, String>> picklistValuesSet = new List<Map<String, String>>();
    
                    for (Schema.PicklistEntry entry : picklistEntries) {
                        picklistValues.add(entry.getValue());
                        Map<String, String> picklistSet = new Map<String, String>();
                        picklistSet.put('label', entry.getLabel());
                        picklistSet.put('value', entry.getValue());
                        picklistValuesSet.add(picklistSet);
                    }
    
                    fieldInfo.put('picklistValues', picklistValuesSet);
    
                    // Set default picklist value (either default set value or first value)
                    String defaultValue = fieldDescribe.getDefaultValue() != null ? 
                        String.valueOf(fieldDescribe.getDefaultValue()) : 
                        (picklistValues.isEmpty() ? '' : picklistValues[0]);
    
                    fieldInfo.put('value', defaultValue);
                } 
                
                // Handle lookup fields (assign first record ID)
                else if (fieldDescribe.getType() == Schema.DisplayType.Reference) {
                    String relatedObject = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
                    fieldInfo.put('value', '');
                    fieldInfo.put('relatedObject', relatedObject);
                    fieldInfo.put('relatedRecordName', '');
                }
    
                requiredFields.add(fieldInfo);
            }

            // Create the final response structure
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('requiredFields', requiredFields);
            
            // Wrap the response map in a list to match the desired format
            List<Map<String, Object>> finalResponse = new List<Map<String, Object>>();
            finalResponse.add(responseMap);
            
            return finalResponse;

        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getRequiredFields','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }

    /**
    * Method Name : getObjectFields
    * @description : Fetch all fields for a given object
    * @param objectName Name of the object
    * @return List of Map<String, String> containing field details
    */
    @AuraEnabled
    public static List<Map<String, String>> getObjectFields(String objectName) {
        try {

            List<Map<String, String>> objectFields = new List<Map<String, String>>();
            
            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            
            for (Schema.SObjectField field : fieldMap.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                Map<String, String> objectFieldInfo = new Map<String, String>();
                objectFieldInfo.put('label', fieldDescribe.getLabel());
                objectFieldInfo.put('value', fieldDescribe.getName());
                objectFieldInfo.put('type', String.valueOf(fieldDescribe.getType()));
                objectFields.add(objectFieldInfo);
            }
            
            return objectFields;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getObjectFields','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }

    /**
    * Method Name : getFlowIdFromAutomation
    * @description : Fetch flow_id from Automation record
    * @param automationId Id of the Automation
    * @return String flow_id
    */
    @AuraEnabled
    public static String getFlowIdFromAutomation(Id automationId) {
        try {

        // Step 1: Query the template related to the automation
        WBConnect_Automation__c automation = [
            SELECT Template__r.Button_Body__c 
            FROM WBConnect_Automation__c 
            WHERE Id = :automationId 
            LIMIT 1
        ];
    
        String buttonBodyJson = automation.Template__r.Button_Body__c;
        if (String.isBlank(buttonBodyJson)) { return null; }
    
            // Step 2: Parse the JSON string into a list of objects
            List<Object> buttonList = (List<Object>) JSON.deserializeUntyped(buttonBodyJson);
    
            // Step 3: Loop through and find the flow_id
            for (Object itemObj : buttonList) {
                Map<String, Object> item = (Map<String, Object>) itemObj;
                if ((String)item.get('type') == 'FLOW' && item.containsKey('flow_id')) {
                    return (String)item.get('flow_id');
                }
            }

        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getFlowIdFromAutomation','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    
        return null; // if no FLOW type or error
    }

    /**
    * Method Name : getFlowFields
    * @description : Fetch flow fields from WBConnect_Flow__c record
    * @param flowId Id of the flow
    * @return String flow fields JSON
    */
    @AuraEnabled
    public static String getFlowFields(String flowId) {
        try {
            
            WBConnect_Flow__c flow =  [SELECT Id, Flow_JSON__c FROM WBConnect_Flow__c WHERE Flow_Id__c = :flowId];
    
            if (flow == null || String.isBlank(flow.Flow_JSON__c)) {
                return null; // or handle the error as needed
            }
            return flow.Flow_JSON__c;
            
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'AutomationConfigController','methodName' => 'getFlowFields','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            return null;
        }
    }
}