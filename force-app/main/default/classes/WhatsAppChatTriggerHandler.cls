/**
* Class Name: WhatsAppChatTriggerHandler
* Test Class: BroadcastMessageControllerTest
* Description: This class is used to handle the WhatsApp chat records and update broadcast records for total count.
* Created Date: 06 April 2025
* Created By: Rachit Shah
*--------------------------------------------------------------------------------
**/

public without sharing class WhatsAppChatTriggerHandler {
    private List<WBConnect_Chat__c> recordNewList = new List<WBConnect_Chat__c>();
    private List<WBConnect_Chat__c> recordOldList = new List<WBConnect_Chat__c>();
    private Map<Id, WBConnect_Chat__c> recordNewMap = new Map<Id, WBConnect_Chat__c>();
    private Map<Id, WBConnect_Chat__c> recordOldMap = new Map<Id, WBConnect_Chat__c>();
    private Boolean isInsert;
    private Boolean isUpdate;
    private Boolean isDelete = false;
    private Boolean isUndelete = false;
    private static final String CLASS_NAME = 'WhatsAppChatTriggerHandler';

    public WhatsAppChatTriggerHandler( List<WBConnect_Chat__c> newList,  List<WBConnect_Chat__c> oldList, Map<Id, WBConnect_Chat__c> newMap, Map<Id, WBConnect_Chat__c> oldMap, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }

    
    /*
    *********************************************************
    @description     : This method is used to update the broadcast records for total counts.
    @param           :  None
    @return          : void
    ********************************************************
    */
    public void handleAfterUpdateOrInsert() {
        updateBroadcastCounts();
    }

    /*
    *********************************************************
    @description     : This method is used to update the broadcast records for total counts.
    @param           :  None
    @return          : void
    ********************************************************
    */

    private void updateBroadcastCounts() {

        try{
            Set<Id> broadcastIds = new Set<Id>();

            // Collect all WBConnect_Broadcast__c	 IDs
            for (WBConnect_Chat__c chat : recordNewList) {
                if (chat.WBConnect_Broadcast__c	 != null && chat.Message_Status__c != null) {
                    broadcastIds.add(chat.WBConnect_Broadcast__c);
                }
            }
    
            // Query existing WBConnect_Broadcast__c records
            Map<Id, WBConnect_Broadcast__c> broadcastsToUpdate = new Map<Id, WBConnect_Broadcast__c>();
            if (!broadcastIds.isEmpty()) {
                for (WBConnect_Broadcast__c broadcast : [SELECT Id, Total_Sent__c, Total_Delivered__c, Total_Read__c, Total_Failed__c 
                                               FROM WBConnect_Broadcast__c 
                                               WHERE Id IN :broadcastIds]) {
                    broadcast.Total_Sent__c = broadcast.Total_Sent__c == null ? 0 : broadcast.Total_Sent__c;
                    broadcast.Total_Delivered__c = broadcast.Total_Delivered__c == null ? 0 : broadcast.Total_Delivered__c;
                    broadcast.Total_Read__c = broadcast.Total_Read__c == null ? 0 : broadcast.Total_Read__c;
                    broadcast.Total_Failed__c = broadcast.Total_Failed__c == null ? 0 : broadcast.Total_Failed__c;
                                
                    broadcastsToUpdate.put(broadcast.Id, broadcast);
                }
            }
    
            // Update counts based on message status
            for (WBConnect_Chat__c chat : recordNewList) {
                if (chat.WBConnect_Broadcast__c == null || chat.Message_Status__c == null) {
                    continue;
                }

                WBConnect_Chat__c oldChat = recordOldMap.get(chat.Id);
                if (oldChat != null && oldChat.Message_Status__c == chat.Message_Status__c) {
                    continue;
                }
    
                if (!broadcastsToUpdate.containsKey(chat.WBConnect_Broadcast__c)) {
                    broadcastsToUpdate.put(chat.WBConnect_Broadcast__c, new WBConnect_Broadcast__c(
                        Id = chat.WBConnect_Broadcast__c, Total_Sent__c = 0, Total_Delivered__c = 0, Total_Read__c = 0,Total_Failed__c = 0
                    ));
                }
                
                WBConnect_Broadcast__c	 broadcast = broadcastsToUpdate.get(chat.WBConnect_Broadcast__c);

                Decimal recipientLimit = broadcast.Recipient_Count__c;
                if (chat.Message_Status__c == 'Sent' && broadcast.Total_Sent__c < recipientLimit) {
                    broadcast.Total_Sent__c += 1;
                }
                if (chat.Message_Status__c == 'Delivered' && broadcast.Total_Delivered__c < recipientLimit) {
                    broadcast.Total_Delivered__c += 1;
                }
                if (chat.Message_Status__c == 'Seen' && broadcast.Total_Read__c < recipientLimit) {
                    broadcast.Total_Read__c += 1;
                }
                if (chat.Message_Status__c == 'Failed' && broadcast.Total_Failed__c < recipientLimit) {
                    broadcast.Total_Failed__c += 1;
                }
            }
    
            // Perform bulk update
            if (!broadcastsToUpdate.isEmpty()) {
                List<WBConnect_Broadcast__c	> broadcastList = new List<WBConnect_Broadcast__c>(broadcastsToUpdate.values()); // Convert map values to list
                Database.update(broadcastList, false); // Use the list in Database.update()
            }
        }
        catch(Exception e){
            ExceptionHandler.logException(new Map<String, Object>{'className' => CLASS_NAME,'methodName' => 'updateBroadcastCounts','exceptionObj' => e,'isApiException' => false,'statusCode' => null,'chatId' => null,'moreDetails' => e.getMessage(),'apiResponse' => null});
        }
    }
        
}