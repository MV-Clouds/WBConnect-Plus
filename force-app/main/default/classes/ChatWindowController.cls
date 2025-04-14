/**
* Class Name: ChatWindowController
* Test Class: ChatWindowControllerTest
* @description: Used for handling various actions for the chat
* Created Date: 2, April 2025
* Created By: Harsh Gandhi
*--------------------------------------------------------------------------------
* Last Modified By: 
* Last Modified Date: 
* Last Modification Description: 
*--------------------------------------------------------------------------------
* Modification History:
* Date Modified - Developer Name - Description
* 
**/
public without sharing class ChatWindowController {

    public static List<WBConnect_Meta_Configuration__c> wbConfig = [SELECT Id, Access_Token__c, Phone_Number_Id__c FROM WBConnect_Meta_Configuration__c WHERE Is_WBA_Configured__c = true LIMIT 1]; 
    public static String userAccountId = WhatsAppWebhook.getUserAccount();

    @AuraEnabled
    public static Map<String, Map<String, Object>> getContactsForChat() {
        try {
            // Step 1: Get contacts with valid phone numbers
            List<WBConnect_Contact__c> contacts = [SELECT Id, Name, Phone__c, User__c FROM WBConnect_Contact__c WHERE Phone__c != null AND Phone__c != ''];
    
            // Step 2: Build phone set from contacts
            Set<String> phoneSet = new Set<String>();
            for (WBConnect_Contact__c con : contacts) {
                phoneSet.add(con.Phone__c);
            }
    
            // Step 3: Get last chat time per phone from WBConnect_Chat__c
            Map<String, DateTime> phoneToLastChat = new Map<String, DateTime>();
            List<AggregateResult> chatAgg = [SELECT Phone__c, MAX(CreatedDate) maxDate FROM WBConnect_Chat__c WHERE Phone__c IN :phoneSet GROUP BY Phone__c];
    
            for (AggregateResult ar : chatAgg) {
                phoneToLastChat.put((String)ar.get('Phone__c'), (DateTime)ar.get('maxDate'));
            }
    
            // Step 4: Get count of unread outbound messages per phone
            Map<String, Integer> phoneToUnreadOutboundCount = new Map<String, Integer>();
            List<AggregateResult> unreadOutboundAgg = [ SELECT Phone__c, COUNT(Id) countId FROM WBConnect_Chat__c WHERE Phone__c IN :phoneSet AND Message_Status__c != 'Seen' AND Type_of_Message__c = 'Inbound Messages' GROUP BY Phone__c];
    
            for (AggregateResult ar : unreadOutboundAgg) {
                phoneToUnreadOutboundCount.put((String)ar.get('Phone__c'), (Integer)ar.get('countId'));
            }
    
            // Step 4: Sort the contacts by latest chat date descending
            contacts.sort(new ContactChatComparator(phoneToLastChat));
    
            Map<String, Map<String, Object>> contactData = new Map<String, Map<String, Object>>();
            for (WBConnect_Contact__c con : contacts) {
                Map<String, Object> contactDetails = new Map<String, Object>();
                contactDetails.put('Id', con.Id);
                contactDetails.put('Name', con.Name);
                contactDetails.put('Phone', con.Phone__c);
                contactDetails.put('unreadOutboundCount', phoneToUnreadOutboundCount.containsKey(con.Phone__c) ? phoneToUnreadOutboundCount.get(con.Phone__c) : 0);
                contactData.put(con.Id, contactDetails);
            }
    
            return contactData;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'getContactsForChat', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
            return null;
        }
    }

    // Inner comparator class
    public class ContactChatComparator implements Comparator<WBConnect_Contact__c> {
        Map<String, DateTime> phoneToChatMap;

        public ContactChatComparator(Map<String, DateTime> phoneChatMap) {
            this.phoneToChatMap = phoneChatMap;
        }

        public Integer compare(WBConnect_Contact__c a, WBConnect_Contact__c b) {
            DateTime aDate = phoneToChatMap.containsKey(a.Phone__c) ? phoneToChatMap.get(a.Phone__c) : DateTime.newInstance(1900, 1, 1);
            DateTime bDate = phoneToChatMap.containsKey(b.Phone__c) ? phoneToChatMap.get(b.Phone__c) : DateTime.newInstance(1900, 1, 1);

            if (aDate > bDate) return -1; // Descending order
            if (aDate < bDate) return 1;
            return 0;
        }
    }

    @AuraEnabled
    public static String createContact(String name, String phone) {
        try {
            WBConnect_Contact__c con = new WBConnect_Contact__c();
            con.Name = name;
            con.Phone__c = phone;
            con.Account__c = userAccountId;
            insert con;
            return con.Id;
        } catch (Exception e) {
            System.debug('Error creating contact: ' + e.getMessage());
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'createContact', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
            return 'Error - ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static String deleteContact(String conId) {
        try {
            List<WBConnect_Contact__c> con = [SELECT Id FROM WBConnect_Contact__c WHERE Id =:conId];
            
            if (con.size() > 0) {
                delete con;
                return 'Contact deleted successfully';
            } else {
                return 'Contact not found';
            }
        } catch (Exception e) {
            System.debug('Error deleting contact: ' + e.getMessage());
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'deleteContact', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
            return 'Error - ' + e.getMessage();
        }
    }

    /*
    *********************************************************
    @description     : Method is used to fetch all the chats 
    @param           : contactId - {String} - Id of the contact to fetch related chats only
    @return          : combinedData - {Map<String, Object>} - Map containing all the chats and theme preference
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> getCombinedData(String contactId, String objectApiName){
        Map<String, Object> combinedData = new Map<String, Object>();
        try {
            List<WBConnect_Chat__c> chats = new List<WBConnect_Chat__c>();
            List<WBConnect_Template__c> templates = new List<WBConnect_Template__c>();
            WBConnect_Contact__c recordData = [SELECT Id, Name, Phone__c FROM WBConnect_Contact__c WHERE Id =:contactId LIMIT 1];
            String phoneNumber = recordData.Phone__c;
            String recordName = recordData.Name;

            chats = [SELECT Id, Type_of_Message__c, WhatsAppMessageId__c, Message__c, Message_Status__c, Message_Type__c, Reply_To__c, Reaction__c, WBConnect_Template__c, WBConnect_Template__r.Template_Name__c, CreatedDate, Last_Interaction_Date__c, Phone__c, File_Data__c FROM WBConnect_Chat__c WHERE Phone__c =:phoneNumber ORDER BY CreatedDate asc];
            // Step 1: Get template IDs with matching child variables
            Set<Id> matchingTemplateIds = new Set<Id>();
            for (WBConnect_Template_Variable__c tv : [SELECT Template__c FROM WBConnect_Template_Variable__c WHERE Object_Name__c = :objectApiName]) {
                matchingTemplateIds.add(tv.Template__c);
            }

            // Step 2: Fetch templates with matching child variables
            if (!matchingTemplateIds.isEmpty()) {
                templates.addAll(
                    [SELECT Id, Template_Name__c FROM WBConnect_Template__c WHERE Status__c = 'Active-Quality Pending' AND Id IN :matchingTemplateIds ORDER BY LastModifiedDate DESC
                ]);
            }

            // Step 3: Fetch templates that have **no** child variables
            List<WBConnect_Template__c> templatesWithoutVariables = [SELECT Id, Template_Name__c FROM WBConnect_Template__c WHERE Status__c = 'Active-Quality Pending' AND Id NOT IN (SELECT Template__c FROM WBConnect_Template_Variable__c) ORDER BY LastModifiedDate DESC];

            // Step 4: Combine results
            templates.addAll(templatesWithoutVariables);

            combinedData.put('chats', chats);
            combinedData.put('templates', templates);
            combinedData.put('record', recordData);
            combinedData.put('phoneNumber', phoneNumber);
            combinedData.put('recordName', recordName);
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'fetchAllChats', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
        }
        return combinedData;
    }

    /*
    *********************************************************
    @description     : Method is used to create a new chat message
    @param           : chatData - {Map<String, String>} - Map containing all the data to create a new chat
    @return          : chat - {WBConnect_Chat__c} - the newly created chat
    ********************************************************
    */
    @AuraEnabled
    public static WBConnect_Chat__c createChat(Map<String, String> chatData ){
        try {

            String message = chatData.get('message');
            String templateId = chatData.get('templateId');
            String messageType = chatData.get('messageType');
            String recordId = chatData.get('recordId');
            String replyToChatId = chatData.get('replyToChatId');
            String phoneNumber = chatData.get('phoneNumber');

            WBConnect_Chat__c chat = new WBConnect_Chat__c();
            chat.Message__c = message;
            chat.Account__c =userAccountId;
            chat.WBConnect_Template__c = templateId;
            chat.Phone__c = phoneNumber;
            chat.Type_of_Message__c	= 'OutBound Messages';
            chat.Message_Status__c = null;
            chat.Message_Type__c = messageType;
            chat.Reply_To__c = replyToChatId;

            insert chat;
            chat = [SELECT Id, Type_of_Message__c, WhatsAppMessageId__c, Message__c, Message_Status__c, Message_Type__c, Reply_To__c, Reaction__c, WBConnect_Template__c, WBConnect_Template__r.Template_Name__c, CreatedDate, Last_Interaction_Date__c, File_Data__c FROM WBConnect_Chat__c WHERE Id =:chat.Id ];
            return chat;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'createChat', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' =>  e.getMessage(), 'apiResponse' => null});
            return null;
        }
    }


    /*
    *********************************************************
    @description     : Method is used to update the reaction of any chat message
    @param           : chatId - {String} - Id of the chat to update
    @param           : reaction - {String} - reaction to be updated
    @return          : chat - {WBConnect_Chat__c} - the updated chat
    ********************************************************
    */
    @AuraEnabled
    public static WBConnect_Chat__c updateReaction(String chatId, String reaction){
        try{
            WBConnect_Chat__c chat = new WBConnect_Chat__c();
            chat.Id = chatId;
            chat.Reaction__c = reaction;
            update chat;
            return chat;
        }catch(Exception e){
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'updateReaction', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => chatId, 'moreDetails' =>  e.getMessage(), 'apiResponse' => null});
            return null;
        }
    }

    /*
    *********************************************************
    @description     : Method to send the messages from the chat window
    @param           : jsonData - {String} - The JSON Data to send as a request body
    @param           : chatId - {String} - Id of the related Chat
    @param           : isReaction - {String} - to specify if the action is for a reaction
    @param           : reaction - {String} - reaction string if the action is for a reaction
    @return          : resultMap - {Map<String, Object>} - containing errorMessage and a chat record
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, Object> sendWhatsappMessage(String jsonData, String chatId, Boolean isReaction, String reaction) {
        Map<String, Object> resultMap = new Map<String, Object>{};
        WBConnect_Chat__c chat = new WBConnect_Chat__c(Id = chatId);
        try {
            HttpRequest httpReq = new HttpRequest();
            resultMap.put('errorMessage', null);
            if(wbConfig==null || wbConfig.isEmpty()){
                if(!isReaction){
                    chat.Message_Status__c = 'Failed';
                }else{
                    chat.Reaction__c = '<|USER|>' + reaction.substringAfter('<|USER|>');
                }
                update chat;
                resultMap.put('errorMessage', 'METADATA_ERROR');
                resultMap.put('chat', chat);
                return resultMap;
            }
            String accessToken = wbConfig[0].Access_Token__c;
            String endpoint = 'https://graph.facebook.com/v21.0/' + wbConfig[0].Phone_Number_Id__c + '/messages';
            httpReq.setEndpoint(endpoint);
            httpReq.setMethod('POST');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
            httpReq.setBody(jsonData);
            Http http = new Http();
            HttpResponse response = http.send(httpReq);
            Integer statusCode = response.getStatusCode();
            if(response != null && statusCode == 200){
                String responseBody = response.getBody();
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                List<Object> messages = (List<Object>)jsonMap.get('messages');
                Map<String, Object> firstMessage = (Map<String, Object>)messages[0];
                String whatsAppMessageID = (String) firstMessage.get('id');
                System.debug('WhatsApp Message ID: ' + whatsAppMessageID);
                // Update the chat record
                if(!isReaction){
                    chat.WhatsAppMessageId__c = whatsAppMessageID;
                    chat.Message_Status__c = 'Sent';
                }
            }else{
                System.debug('Error sending WhatsApp Message: '+response.getBody());
                if(!isReaction){
                    chat.Message_Status__c = 'Failed';
                }
                ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'sendWhatsappMessage', 'exceptionObj' => null, 'isApiException' => true, 'statusCode' => statusCode, 'chatId' => chatId, 'moreDetails' => 'API Exception while sending a message', 'apiResponse' => JSON.serialize(response.getBody()) });
            }

            update chat;
            chat = [SELECT Id, Type_of_Message__c, WhatsAppMessageId__c, Message__c, Message_Status__c, Message_Type__c, Reply_To__c, Reaction__c, WBConnect_Template__c, WBConnect_Template__r.Template_Name__c, CreatedDate, Last_Interaction_Date__c FROM WBConnect_Chat__c WHERE Id =:chat.Id ];
            resultMap.put('chat', chat);
            return resultMap;

        } catch (Exception e) {
            if(!isReaction){
                chat.Message_Status__c = 'Failed';
                update chat;
            }
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'sendWhatsappMessage', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => chatId, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
        resultMap.put('chat', chat);
        return resultMap;
    }

    /*
    *********************************************************
    @description     : Method to get the data for a specific template
    @param           : templateId - {String} - Id of the template to fetch
    @param           : contactId - {String} - Id of the contact to fetch related data for variables
    @return          : template - {WBConnect_Template__c} - Template object with full data of it
    ********************************************************
    */
    @AuraEnabled
    public static Map<String, object> getTemplateData(String templateId, String contactId, String objectApiName){
        try {
            Map<String, Object> templateData = new Map<String, Object>();
            List<WBConnect_Template__c> templates = new List<WBConnect_Template__c>();
            
            // Fetch templates with matching child variables
            // Set<Id> matchingTemplateIds = new Set<Id>();
            // for (WBConnect_Template_Variable__c tv : [SELECT Template__c FROM WBConnect_Template_Variable__c WHERE Object_Name__c = :objectApiName]) {
            //     matchingTemplateIds.add(tv.Template__c);
            // }

            // // Fetch template details
            // if (!matchingTemplateIds.isEmpty()) {
            //     templates.addAll([
            //         SELECT Id, Template_Name__c, Button_Body__c, Button_Label__c, Button_Type__c, Footer_Body__c, Header_Body__c, Header_Type__c, Language__c, Template_Body__c, Template_Category__c, Template_SubCatagory__c, Template_Type__c, Template_Variable__c,
            //             (SELECT Id, Name, Field_Name__c, Object_Name__c, Type__c, Alternate_Text__c FROM WBConnect_Template_Variables__r) FROM WBConnect_Template__c WHERE Id = :templateId AND Id IN :matchingTemplateIds 
            //     ]);
            // }

            // Fetch templates without child variables
            // List<WBConnect_Template__c> templatesWithoutVariables = [
            //     SELECT Id, Template_Name__c, Button_Body__c, Button_Label__c, Button_Type__c, Footer_Body__c, Header_Body__c, Header_Type__c, Language__c, Template_Body__c, Template_Category__c, Template_SubCatagory__c, Template_Type__c, Template_Variable__c,
            //         (SELECT Id, Name, Field_Name__c, Object_Name__c, Type__c, Alternate_Text__c FROM WBConnect_Template_Variables__r) FROM WBConnect_Template__c WHERE Id = :templateId AND User__c = :UserInfo.getUserId()
            // ];
            List<WBConnect_Template__c> templatesWithoutVariables = [
                SELECT Id, Template_Name__c, Button_Body__c, Button_Label__c, Button_Type__c, Footer_Body__c, Header_Body__c, Header_Type__c, Language__c, Template_Body__c, Template_Category__c, Template_SubCatagory__c, Template_Type__c, Template_Variable__c
                    FROM WBConnect_Template__c WHERE Id = :templateId 
            ];
            templates.addAll(templatesWithoutVariables);

            // if(templates.size() > 0 && templates[0].Template_Variable__c>0){
                // WBConnect_Template__c template= templates[0];
                // Set<String> fieldSelectionCause = new Set<String>();
                // for (WBConnect_Template_Variable__c tv : template.WBConnect_Template_Variables__r) {
                //     if (tv.Object_Name__c == objectApiName) {
                //         // If the object matches the queried object, add only the field name
                //         fieldSelectionCause.add(tv.Field_Name__c);
                //     } else {
                //         try {
                //             // Check if the object supports relationships before adding related fields
                //             fieldSelectionCause.add(tv.Object_Name__c + '.' + tv.Field_Name__c);
                //         } catch (Exception ex) {
                //             System.debug('Invalid relationship: ' + tv.Object_Name__c + ' for ' + objectApiName);
                //         }
                //     }
                // }
                
                // if(fieldSelectionCause.size() < 1){
                //     templateData.put('template', templates[0]);
                //     return templateData;
                // }

                // String query = 'SELECT ' + String.join(fieldSelectionCause, ', ') + ' FROM ' + objectApiName + ' WHERE Id =:contactId';
                // List<sObject> records = Database.query(String.escapeSingleQuotes(query));
                // List<Object> headerVariables = new List<Object>();
                // List<Object> bodyVariables = new List<Object>();
                // if(records.size() > 0){
                //     sObject record = records[0];
                //     for (WBConnect_Template_Variable__c tv: template.WBConnect_Template_Variables__r) {
                //         Object valueToReplace = '';
                //         if (tv.Object_Name__c == objectApiName) {  
                //             // If the object matches the queried object (Lead, Contact, etc.), get the field directly  
                //             valueToReplace = record.get(tv.Field_Name__c);  
                //         } else {  
                //             // Check if the object supports relationships before querying related fields  
                //             try {  
                //                 SObject relatedRecord = record.getSObject(tv.Object_Name__c);  
                //                 valueToReplace = (relatedRecord != null) ? relatedRecord.get(tv.Field_Name__c) : null;  
                //             } catch (Exception ex) {  
                //                 System.debug('Invalid relationship: ' + tv.Object_Name__c + ' for ' + objectApiName);  
                //                 valueToReplace = null;  
                //             }  
                //         }
                //         if (tv.Type__c == 'Header') {
                //             headerVariables.add(valueToReplace != null ? valueToReplace.toString() : (tv.Alternate_Text__c!= null ? tv.Alternate_Text__c : ' '));
                //             template.Header_Body__c = template.Header_Body__c.replace(tv.Name , valueToReplace != null ? valueToReplace.toString() : (tv.Alternate_Text__c!= null ? tv.Alternate_Text__c : ' ') );
                //         }else if(tv.Type__c == 'Body'){
                //             bodyVariables.add(valueToReplace != null ? valueToReplace.toString() : (tv.Alternate_Text__c!= null ? tv.Alternate_Text__c : ' '));
                //             template.Template_Body__c = template.Template_Body__c.replace(tv.Name , valueToReplace != null ? valueToReplace.toString() : (tv.Alternate_Text__c!= null ? tv.Alternate_Text__c : ' ') );
                //         }
                //     }
                // }
                // templateData.put('template', template);
                // templateData.put('headerParams', headerVariables);
                // templateData.put('bodyParams', bodyVariables);
                // return templateData;
            // } else if (templates.size() > 0 && templates[0].Template_Variable__c < 1){
            //     templateData.put('template', templates[0]);
            //     return templateData;
            // } else {
            //     return null;
            // }
            if(templates.size() > 0){
                templateData.put('template', templates[0]);
                return templateData;
            }
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'getTemplateData', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' =>  e.getMessage(), 'apiResponse' => null});
        }
        return null;
    }

    /*
    *********************************************************
    @description     : Method to mark all unread message IDs as "read"
    @param           : messageIds - {List<String>} - List of chat IDs to be marked as read
    @return          : none
    *********************************************************
    */
    @AuraEnabled
    public static List<String> updateStatus(List<String> messageIds) {
        List<WBConnect_Chat__c> chats = new List<WBConnect_Chat__c>();
        List<String> updatedMessageIds = new List<String>();
        chats = [SELECT Id, WhatsAppMessageId__c, Message_Status__c FROM WBConnect_Chat__c WHERE Id IN :messageIds ];
        String accessToken = wbConfig[0].Access_Token__c;
        String endpoint = 'https://graph.facebook.com/v21.0/' + wbConfig[0].Phone_Number_Id__c + '/messages';

        try {
            for (WBConnect_Chat__c chat : chats) {
                String payload = JSON.serialize(new Map<String, Object>{
                    'messaging_product' => 'whatsapp',
                    'status' => 'read',
                    'message_id' => chat.WhatsAppMessageId__c
                });
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setHeader('Authorization', 'Bearer ' + accessToken);
                request.setHeader('Content-Type', 'application/json');
                request.setBody(payload);

                HttpResponse response = http.send(request);

                Integer statusCode = response.getStatusCode();
                if (statusCode != 200) {
                    ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowController', 'methodName' => 'updateStatus', 'exceptionObj' => null, 'isApiException' => true, 'statusCode' => statusCode,'chatId' => null,  'moreDetails' => 'Error occurred for status update', 'apiResponse' => response.getBody() });
                }else{
                    chat.Message_Status__c = 'Seen';
                    updatedMessageIds.add(chat.Id);
                }
            }
            update chats;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowController', 'methodName' => 'updateStatus', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null,'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
        return updatedMessageIds;

    }
    /*
    *********************************************************
    @description     : Method is used to create a new chat message for the Files which are stored in AWS
    @param           : chatData - {Map<String, String>} - Map containing all the data to create a new chat
    @return          : chat - {WBConnect_Chat__c} - the newly created chat
    ********************************************************
    */
    @AuraEnabled
    public static WBConnect_Chat__c createChatForAWSFiles(Map<String, String> chatData ){
        try {

            String message = chatData.get('message');
            String fileName = chatData.get('fileName');
            String mimeType = chatData.get('mimeType');
            String messageType = chatData.get('messageType');
            String recordId = chatData.get('recordId');
            String replyToChatId = chatData.get('replyToChatId');
            String phoneNumber = chatData.get('phoneNumber');

            WBConnect_Chat__c chat = new WBConnect_Chat__c();
            chat.Message__c = message;
            chat.Account__c = userAccountId;
            chat.Phone__c = phoneNumber;
            chat.Type_of_Message__c	= 'OutBound Messages';
            chat.Message_Status__c = null;
            chat.Message_Type__c = messageType;
            chat.Reply_To__c = replyToChatId;
            Map<String, Object> fileData = new Map<String, Object>{ 'fileName' => fileName, 'mimeType' => mimeType };
            chat.File_Data__c = JSON.serialize(fileData);

            insert chat;
            chat = [SELECT Id, Type_of_Message__c, WhatsAppMessageId__c, Message__c, Message_Status__c, Message_Type__c, Reply_To__c, Reaction__c, WBConnect_Template__c, WBConnect_Template__r.Template_Name__c, CreatedDate, Last_Interaction_Date__c, File_Data__c FROM WBConnect_Chat__c WHERE Id =:chat.Id ];

            return chat;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowController', 'methodName' => 'createChat', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' =>  e.getMessage(), 'apiResponse' => null});
            return null;
        }
    }
}