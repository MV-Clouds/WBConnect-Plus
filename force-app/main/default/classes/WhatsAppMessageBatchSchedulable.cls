/**
* Class Name: WhatsAppMessageBatchSchedulable
* Test Class: BroadcastMessageControllerTest
* Description: This class is used to schedule the batch process.
* Created Date: 06 April 2025
* Created By: Rachit
*--------------------------------------------------------------------------------
**/

global with sharing class WhatsAppMessageBatchSchedulable implements Schedulable {

    global String templateId;
    global List<WBConnect_Chat__c> chatRecs;
    global String broadcastId;
    
    global WhatsAppMessageBatchSchedulable(String tempId, List<WBConnect_Chat__c> chats, String broadcastRecId) {
        this.templateId = tempId;
        this.chatRecs = chats;
        this.broadcastId = broadcastRecId;
    }
    
    /*
    *********************************************************
    @description     : This method is used to execute the batch process.
    @param           : bc - Batchable context
    @param           : scope - Scope of the batch process
    ********************************************************
    */
    global void execute(SchedulableContext context){
        WhatsAppMessageBatch batchJob = new WhatsAppMessageBatch(this.templateId, this.chatRecs, this.broadcastId);
        Database.executeBatch(batchJob, 1);
    }
}