/**
* Class Name: BroadcastMessageController
* Test Class: BroadcastMessageControllerTest
* Description: This class is responsible for handling broadcast messages and managing broadcast groups.
* Created Date: 03 April 2025
* Created By: Rachit Shah
*--------------------------------------------------------------------------------
**/


public without sharing class BroadcastMessageController {

    /*
    *********************************************************
    @description     : get all broadcast groups
    @param           : None
    @return          : List of WBConnect_Broadcast_Group__c records
    ********************************************************
    */

    @AuraEnabled
    public static List<WBConnect_Broadcast_Group__c> getBroadcastGroups(){
        List<WBConnect_Broadcast_Group__c> broadcastGroups = new List<WBConnect_Broadcast_Group__c>();
        try {
            broadcastGroups = [SELECT Id, Name, Count_of_Members__c, Description__c FROM WBConnect_Broadcast_Group__c ORDER BY LastModifiedDate DESC];
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'BroadcastMessageController','methodName' => 'getBroadcastGroups', 'exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
        }
        return broadcastGroups;
    }

    /*
    *********************************************************
    @description     : delete a broadcast group
    @param           : groupId - Id of the WBConnect_Broadcast_Group__c record
    @return          : void
    ********************************************************
    */
    @AuraEnabled
    public static void deleteBroadcastGroup(Id groupId) {
        try {
            
            WBConnect_Broadcast_Group__c groupToDelete = [
                SELECT Id FROM WBConnect_Broadcast_Group__c 
                WHERE Id = :groupId 
                LIMIT 1
            ];
            
            if (groupToDelete == null) {
                throw new AuraHandledException('There was a problem deleting the record. ' + groupId);
            }
            
            delete groupToDelete;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'BroadcastMessageController','methodName' => 'deleteBroadcastGroup', 'exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
        }
    }

    /*
    *********************************************************
    @description     : get all broadcast records
    @param           : None
    @return          : List of WBConnect_Broadcast__c records
    ********************************************************
    */
    @AuraEnabled
    public static List<WBConnect_Broadcast__c> getBroadcastRecs(){
        List<WBConnect_Broadcast__c> broadcastRecs = new List<WBConnect_Broadcast__c>();
        try {
            broadcastRecs =  [SELECT Id, Name, Recipient_Count__c, Status__c, Total_Sent__c, Total_Delivered__c, Total_Read__c, Total_Failed__c FROM WBConnect_Broadcast__c ORDER BY LastModifiedDate DESC];        
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'BroadcastMessageController','methodName' => 'getBroadcastRecs', 'exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
        }

        return broadcastRecs;
    }

    /*
    *********************************************************
    @description     : get all templates by object
    @param           : None
    @return          : Map of object names to lists of WBConnect_Template__c records
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, List<WBConnect_Template__c>> getTemplatesByObject() {
        Map<String, List<WBConnect_Template__c>> objectTemplateMap = new Map<String, List<WBConnect_Template__c>>();
    
        try {
            // Fetch all templates with their related object names from Template_Variable__c
            List<WBConnect_Template__c> templates = [SELECT Id, Template_Name__c, 
                                                  (SELECT Object_Name__c FROM WBConnect_Template_Variables__r) 
                                           FROM WBConnect_Template__c 
                                           WHERE Status__c = 'Active-Quality Pending'
                                           ORDER BY LastModifiedDate DESC];
    
            // Categorize templates by object name
            for (WBConnect_Template__c template : templates) {
                String objectName;
    
                // If the template has associated object names, use the first one; otherwise, categorize it as 'Generic'
                if (!template.WBConnect_Template_Variables__r.isEmpty()) {
                    objectName = template.WBConnect_Template_Variables__r[0].Object_Name__c;
                } else {
                    objectName = 'Generic'; // Templates without variables are categorized as 'Generic'
                }
    
                // Initialize list if objectName is not yet added
                if (!objectTemplateMap.containsKey(objectName)) {
                    objectTemplateMap.put(objectName, new List<WBConnect_Template__c>());
                }
    
                // Add template to the appropriate object name
                objectTemplateMap.get(objectName).add(template);
            }
    
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'BroadcastMessageController','methodName' => 'getTemplatesByObject', 'exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
        }
    
        return objectTemplateMap;
    }    

    /*
    *********************************************************
    @description     : Insert or Update the broadcast group and its members
    @param           : requestJson - JSON string containing the broadcast group details
    @return          : void
    ********************************************************
    */

    @AuraEnabled
    public static void processBroadcastMessageWithObject(String requestJson) {
        try {
            // Deserialize JSON to a generic map
            Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(requestJson);
    
            // Extract fields
            List<Object> phoneNumbersRaw = (List<Object>) request.get('phoneNumbers');
            List<String> phoneNumbers = new List<String>();
            for (Object phoneNumber : phoneNumbersRaw) {
                phoneNumbers.add((String) phoneNumber);
            }
            String description = (String) request.get('description');
            String name = (String) request.get('name');
            Boolean isUpdate = request.containsKey('isUpdate') ? (Boolean) request.get('isUpdate') : false;
            String broadcastGroupId = (String) request.get('broadcastGroupId');
    
            // Basic validation
            if (String.isBlank(description) || 
                String.isBlank(name) || 
                phoneNumbers.isEmpty()) {
                throw new AuraHandledException('All fields in the request are required, including the broadcast group name');
            }
    
            WBConnect_Broadcast_Group__c broadcastGroup;
    
            if (isUpdate && String.isNotBlank(broadcastGroupId)) {
                // Fetch existing Broadcast Group
                broadcastGroup = [
                    SELECT Id, Name, Description__c
                    FROM WBConnect_Broadcast_Group__c
                    WHERE Id = :broadcastGroupId
                    LIMIT 1
                ];
    
                broadcastGroup.Name = name;
                broadcastGroup.Description__c = description;
    
                Database.SaveResult updateResult = Database.update(broadcastGroup, false);
                if (!updateResult.isSuccess()) {
                    throw new AuraHandledException('Failed to update broadcast group.');
                }
            } else {
                broadcastGroup = new WBConnect_Broadcast_Group__c();
                broadcastGroup.Name = name;
                broadcastGroup.Description__c = description;
    
                Database.SaveResult insertResult = Database.insert(broadcastGroup, false);
                if (!insertResult.isSuccess()) {
                    throw new AuraHandledException('Failed to create broadcast group.');
                }
            }
    
            // Handle group members
            Map<String, WBConnect_Broadcast_Group_Member__c> existingMembersMap = new Map<String, WBConnect_Broadcast_Group_Member__c>();
            if (isUpdate) {
                for (WBConnect_Broadcast_Group_Member__c member : [
                    SELECT Id, Phone_Number__c 
                    FROM WBConnect_Broadcast_Group_Member__c 
                    WHERE Broadcast_Group_ID__c = :broadcastGroup.Id
                ]) {
                    existingMembersMap.put(member.Phone_Number__c, member);
                }
            }
    
            List<WBConnect_Broadcast_Group_Member__c> newMembersToInsert = new List<WBConnect_Broadcast_Group_Member__c>();
            Set<String> receivedPhoneNumbers = new Set<String>(phoneNumbers);
            Set<String> existingPhoneNumbers = existingMembersMap.keySet();
    
            for (String phone : receivedPhoneNumbers) {
                if (String.isNotBlank(phone) && !existingPhoneNumbers.contains(phone)) {
                    newMembersToInsert.add(new WBConnect_Broadcast_Group_Member__c(
                        Broadcast_Group_ID__c = broadcastGroup.Id,
                        Phone_Number__c = phone
                    ));
                }
            }
    
            List<WBConnect_Broadcast_Group_Member__c> membersToDelete = new List<WBConnect_Broadcast_Group_Member__c>();
            for (String existingPhone : existingPhoneNumbers) {
                if (!receivedPhoneNumbers.contains(existingPhone)) {
                    membersToDelete.add(existingMembersMap.get(existingPhone));
                }
            }
    
            if (!newMembersToInsert.isEmpty()) {
                Database.SaveResult[] insertResults = Database.insert(newMembersToInsert, false);
                for (Database.SaveResult res : insertResults) {
                    if (!res.isSuccess()) {
                        throw new AuraHandledException('Error inserting some broadcast group members.');
                    }
                }
            }
    
            if (!membersToDelete.isEmpty()) {
                Database.DeleteResult[] deleteResults = Database.delete(membersToDelete, false);
                for (Database.DeleteResult res : deleteResults) {
                    if (!res.isSuccess()) {
                        throw new AuraHandledException('Error deleting some broadcast group members.');
                    }
                }
            }
    
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'BroadcastMessageController','methodName' => 'processBroadcastMessageWithObject','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            throw new AuraHandledException('Error processing broadcast message: ' + e.getMessage());
        }
    }
    

    /*
    *********************************************************
    @description     : get the details of a broadcast group
    @param           : groupId - Id of the WBConnect_Broadcast_Group__c record
    @return          : Map containing the group record and its members
    ********************************************************
    */

    @AuraEnabled
    public static Map<String, Object> getBroadcastGroupDetails(String groupId) {
        try {
            // Validate input
            if (String.isBlank(groupId)) {
                throw new AuraHandledException('Group ID is required');
            }

            // Fetch Broadcast Group
            WBConnect_Broadcast_Group__c groupRecord = [
                SELECT Id, Name, Description__c
                FROM WBConnect_Broadcast_Group__c	
                WHERE Id = :groupId
                
                LIMIT 1
            ];

            // Fetch Group Members
            List<WBConnect_Broadcast_Group_Member__c> groupMembers = [
                SELECT Id, Phone_Number__c, Name
                FROM WBConnect_Broadcast_Group_Member__c
                WHERE Broadcast_Group_ID__c = :groupId
                
            ];

            // Construct response
            Map<String, Object> response = new Map<String, Object>();
            response.put('group', groupRecord);
            response.put('members', groupMembers);

            return response;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'BroadcastMessageController','methodName' => 'getBroadcastGroupDetails', 'exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            throw new AuraHandledException('Error retrieving broadcast group details: ' + e.getMessage());
        }
    } 


    @AuraEnabled
    public static List<WBConnect_Contact__c> getAllContacts() {
        try {
            return [SELECT Id, Name, Phone__c FROM WBConnect_Contact__c LIMIT 50000]; // Adjust fields and limits as needed
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching contacts: ' + e.getMessage());
        }
    }

    /*
    *********************************************************
    @description     : Create chat records and run batch class to send it at that time or schedule batch job if needed
    @param           : groupId - Id of the WBConnect_Broadcast_Group__c record
    @return          : String indicating success or failure
    ********************************************************
    */
    @AuraEnabled
    public static String createChatRecods(String templateId, List<String> groupIds, Boolean isScheduled, String timeOfMessage) {
        try {
            WBConnect_Broadcast__c broadcast = new WBConnect_Broadcast__c();
            broadcast.WBConnect_Template__c = templateId;
            broadcast.Status__c = 'Pending';
            broadcast.Broadcast_Group_IDs__c = String.join(groupIds, ','); // Save all group IDs as a comma-separated string

            List<WBConnect_Chat__c> chatRecs = new List<WBConnect_Chat__c>();

            if (groupIds.size() > 0) {
                List<WBConnect_Broadcast_Group__c> brGroupRecs = [SELECT Id, Name FROM WBConnect_Broadcast_Group__c WHERE Id IN :groupIds];

                List<WBConnect_Broadcast_Group_Member__c> groupMembers = new List<WBConnect_Broadcast_Group_Member__c>();
                groupMembers = [SELECT Id, Name, Phone_Number__c, Broadcast_Group_ID__c FROM WBConnect_Broadcast_Group_Member__c WHERE Broadcast_Group_ID__c IN :groupIds];
                broadcast.Recipient_Count__c = groupMembers.size();
                Database.insert(broadcast, false);

                System.debug(groupMembers.size());
                List<String> phoneList = new List<String>();
                if (groupMembers.size() > 0) {
                    for (WBConnect_Broadcast_Group_Member__c member : groupMembers) {
                        if (member.Phone_Number__c != null || member.Phone_Number__c != '') {
                            phoneList.add(member.Phone_Number__c);
                            WBConnect_Chat__c newChat = new WBConnect_Chat__c();
                            newChat.WBConnect_Template__c = templateId;
                            newChat.Phone__c = member.Phone_Number__c;
                            newChat.Type_of_Message__c = 'OutBound Messages';
                            newChat.Message_Status__c = null;
                            newChat.Message_Type__c = 'Template';
                            newChat.WBConnect_Broadcast__c = broadcast.Id;
                            chatRecs.add(newChat);
                        }
                    }
                }

                if (chatRecs.size() > 0) {
                    Database.insert(chatRecs, false);
                }
            }

            if (isScheduled == false) {
                WhatsAppMessageBatch batchJob = new WhatsAppMessageBatch(templateId, chatRecs, broadcast.Id);
                Database.executeBatch(batchJob, 1);
            } else {
                timeOfMessage = timeOfMessage.replace('T', ' ').replace('Z', '');

                DateTime utcDateTime = DateTime.valueOf(timeOfMessage);

                // Convert UTC to user's timezone
                TimeZone userTimeZone = UserInfo.getTimeZone();
                DateTime userDateTime = utcDateTime.addSeconds(userTimeZone.getOffset(utcDateTime) / 1000);

                // Validate that the scheduled time is in the future
                if (userDateTime < DateTime.now()) {
                    throw new AuraHandledException('Scheduled time must be in the future.');
                }

                String formattedTime = userDateTime.format('hh:mm a');

                String cronExpression = getCronExpression(userDateTime);

                WhatsAppMessageBatchSchedulable batchSchedular = new WhatsAppMessageBatchSchedulable(templateId, chatRecs, broadcast.Id);

                WBConnect_Broadcast__c br = new WBConnect_Broadcast__c(Id = broadcast.Id);
                br.Schedule_DateTime__c = userDateTime;
                Database.SaveResult updateResult = Database.update(br, false);

                String jobName = 'BroadcastSchedule_' + System.currentTimeMillis();
                System.schedule(jobName, cronExpression, batchSchedular);
            }
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException('Error in sendTemplateMessage: ' + e.getMessage());
        }
    }  

    /*
    *********************************************************
    @description     : Generate a cron expression based on the provided DateTime
    @param           : dt - DateTime object
    @return          : String representing the cron expression
    ********************************************************
    */
    public static String getCronExpression(DateTime dt) {
        String cronExpression = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ' + '?' + ' ' +  dt.year();
        return cronExpression;
    }

    /*
    *********************************************************
    @description     : Get broadcast groups by broadcast ID
    @param           : broadcastId - ID of the broadcast
    @return          : List of WBConnect_Broadcast_Group__c records associated with the broadcast
    ********************************************************
    */

    @AuraEnabled
    public static List<WBConnect_Broadcast_Group__c> getBroadcastGroupsByBroadcastId(String broadcastId) {
        try {
            if (String.isBlank(broadcastId)) {
                throw new AuraHandledException('Broadcast ID is required');
            }

            // Fetch the Broadcast record
            WBConnect_Broadcast__c broadcast = [
                SELECT Broadcast_Group_IDs__c 
                FROM WBConnect_Broadcast__c 
                WHERE Id = :broadcastId 
                LIMIT 1
            ];

            if (broadcast.Broadcast_Group_IDs__c == null) {
                return new List<WBConnect_Broadcast_Group__c>();
            }

            // Split the comma-separated group IDs and fetch related groups
            List<String> groupIds = broadcast.Broadcast_Group_IDs__c.split(',');
            return [
                SELECT Id, Name, Count_of_Members__c, Description__c
                FROM WBConnect_Broadcast_Group__c 
                WHERE Id IN :groupIds 
            ];
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'BroadcastMessageController','methodName' => 'getBroadcastGroupsByBroadcastId', 'exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
            throw new AuraHandledException('Error fetching broadcast groups: ' + e.getMessage());
        }
    }

}