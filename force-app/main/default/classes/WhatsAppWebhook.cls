/**
 * @File Name : WhatsAppWebhook.cls
 * @Description :
 * @Author :
 * @Last Modified By :
 * @Last Modified On : 
 * @Modification Log :
 *==============================================================================
 * Date Modified - Developer Name - Description
 * 
 **/
@RestResource(urlMapping = '/WBConnectPlus/webhooks/v1/*')
global without sharing class WhatsAppWebhook{
    public static String currentTime = System.now().format('yyyy-MM-dd HH:mm:ss');
    public static String phoneNumberId = '';
    public static List<Object> messages = new List<Object>();
    public static List<AWS_Config__c> configList = [SELECT Id, AWS_Access_Key__c, AWS_Secret_Access_Key__c, S3_Bucket_Name__c, S3_Region_Name__c, CreatedDate, LastModifiedDate FROM AWS_Config__c LIMIT 1];
    public static AWS_Config__c configData = !configList.isEmpty() ? configList[0] : null;

    @HttpGet // GET
    global static void doGet(){
        RestResponse response = RestContext.response;
        System.debug('Response ==>' + response);
        RestRequest request = RestContext.request;
        System.debug('request ==>' + request);
        if (request.params.get('hub.verify_token') == 'WHATSAPPTOKEN'){
            response.responseBody = Blob.valueOf(request.params.get('hub.challenge'));
        }
    }

    @HttpPost
    global static void doPost(){
        System.debug('InDoPost Method' + RestContext.request.headers.get('hub.verify_token'));
        System.debug('InDoPost Method2 ' + RestContext.request.params.get('hub.verify_token'));
        // Verify Token (Replace with your Verify Token)
        String verifyToken = '7fa1634d4f849b8ced3a249ec4ce8bb7db4d8046';
        if (RestContext.request.headers.get('hub.verify_token') != verifyToken){
            System.debug('InDoPost Method If condition');
            RestContext.response.statusCode = 403;
        }
        // Get WhatsApp's raw JSON data
        System.debug('InDoPost Method before Payload');
        String jsonString = RestContext.request.requestBody.toString();
        System.debug('InDoPost Method after payload:- ' + jsonString);
        try{
            processWhatsAppPayload(jsonString);
        } catch (Exception e){
            System.debug('Error processing WhatsApp payload: ' + e.getMessage());
        }
    }

    public static void processWhatsAppPayload(String jsonString){
        try{
            System.debug('jsonString: ' + jsonString);
            List<WhatsAppMessage> parsedMessages = parseMessages(jsonString);

            Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            System.debug('payload: ' + payload);

            List<Object> listofmessages = (List<Object>)payload.get('entry');
            Object messageobj = listofmessages[0];

            Map<String, Object> sender = new Map<String,Object>();
            if (messageobj != null){
                Map<String, Object> messageMap = (Map<String, Object>)messageobj;
                if (messageMap.get('changes') != null){
                    List<Object> changes = (List<Object>)messageMap.get('changes');
                    if (changes != null && !changes.isEmpty()){
                        Object changeObj = changes[0];
                        Map<String, Object> changeMap = (Map<String, Object>)changeObj;
                        Map<String, Object> value = (Map<String, Object>)changeMap.get('value');
                        Map<String, Object> metadata = (Map<String, Object>)value.get('metadata');
                        System.debug('value--->' + value);
                        // Extract the phone_number_id
                        phoneNumberId = (String) metadata.get('phone_number_id');
                        System.debug('phonenumberid -- ' + phoneNumberId);
                        messages = (List<Object>)value.get('messages');
                        List<Object> senders = new List<Object>();
                        senders = (List<Object>)value.get('contacts');
                        if(senders !=null && senders.size() > 0){
                            sender =  (Map<String, Object>) senders[0];
                        }
                        System.debug('messages ==> ' + messages);
                    }
                }
            }
            if (messages != null){
                Map<String, Object> message = (Map<String, Object>)messages[0];
                processSingleMessage(message, sender);
            }
        } catch (Exception e){
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsAppWebhook', 'methodName' => 'processWhatsAppPayload', 'exceptionObj' => e, 'isApiException' => False, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
            System.debug('Error in processWhatsAppPayload: ' + e.getMessage() + '\n' + e + '\n Exception line no: ' + e.getLineNumber());
        }
    }

    private static void processSingleMessage(Map<String, Object> message, Map<String, Object> sender){

        try{
            String senderId = (String) message.get('from');
            String messageType = (String) message.get('type');
            String whatsAppMessageID = (String) message.get('id');
            Map<String, Object> context = (Map<String, Object>)message.get('context');
            String contextId = '';
            if (context != null){
                contextId = (String) context.get('id');
                System.debug('Context ID ==> ' + contextId);
            }
            Map<String, Object> reactionMessage = (Map<String, Object>)message.get('reaction');
            String reactToMessageId = '';
            String reactedEmoji= '';
            if (reactionMessage != null){
                reactToMessageId = (String) reactionMessage.get('message_id');
                reactedEmoji= (String) reactionMessage.get('emoji');
                System.debug('Context ID ==> ' + reactToMessageId);
            }
            Integer timestampValue = Integer.valueOf(message.get('timestamp'));
            DateTime currentUTCDateTime = System.now();
            Timezone tzIST = Timezone.getTimeZone('Asia/Kolkata');
            Integer offsetMillis = tzIST.getOffset(currentUTCDateTime);
            Integer offsetHours = offsetMillis / (1000 * 60 * 60);
            Integer offsetMinutes = Math.abs(offsetMillis / (1000 * 60) - offsetHours * 60);
            DateTime currentISTDateTime = currentUTCDateTime.addHours(offsetHours).addMinutes(offsetMinutes);
            String formattedTime2 = currentISTDateTime.format('h:mm a');
            System.debug(formattedTime2);
            System.debug('whatsAppMessageID ==> ' + whatsAppMessageID);
            System.debug('senderId ==> ' + senderId);
            System.debug('messageType ==> ' + messageType);

            // Query to check if the message has already been processed
            List<WBConnect_Chat__c> existingChatRecords = [SELECT Id FROM WBConnect_Chat__c WHERE WhatsAppMessageId__c = :whatsAppMessageID AND User__c = :UserInfo.getUserId() LIMIT 1];
            if (!existingChatRecords.isEmpty()){
                System.debug('Message already processed: ' + whatsAppMessageID);
                return;
            }

            if (!senderId.contains('+')){
                senderId = '+' + senderId;
            }
            String formattedNumber = senderId.substring(0, 3) + senderId.substring(3);

            List<Lead> leads = new List<Lead>();
            System.debug('Sender Id => ' + senderId);
            
            leads = [SELECT Id, Name, Phone FROM Lead WHERE Phone = :formattedNumber LIMIT 1];
            System.debug('formattedNumber Id => ' + formattedNumber);
            Lead lead;
            if (!leads.isEmpty()){
                lead = leads[0];
            } else{
                Lead ld = new Lead();
                Map<String, Object> profile = (Map<String,Object>) sender.get('profile');
                ld.LastName = (String) profile.get('name');
                ld.Company = (String) profile.get('name');
                ld.Phone = (String) senderId;
                ld.Status = 'Open';
                ld.User__c = UserInfo.getUserId();
                insert ld;
                lead = ld;
            }

            DateTime myDateTime = DateTime.now();
            Date formattedDate = myDateTime.date();

            WBConnect_Chat__c whatsappChat = new WBConnect_Chat__c();

            if (existingChatRecords.isEmpty()){

                if(messageType.equalsIgnoreCase('reaction')){
                    List<WBConnect_Chat__c> reactToChat = [SELECT Id, Reaction__c, Phone__c FROM WBConnect_Chat__c WHERE WhatsAppMessageId__c =:reactToMessageId AND User__c = :UserInfo.getUserId()];
                    if(reactToChat.size() > 0){
                        reactToChat[0].Reaction__c = reactToChat[0].Reaction__c!=null ? reactToChat[0].Reaction__c : '<|USER|>';
                        reactToChat[0].Reaction__c = reactToChat[0].Reaction__c.split('<|USER|>')[0] + '<|USER|>' + (reactedEmoji!=null ? reactedEmoji : '');
                        reactToChat[0].Last_Interaction_Date__c = System.now();
                        whatsappChat = reactToChat[0];
                        update whatsappChat;
                    }
                    return;
                }

                whatsappChat.Phone__c = lead.Phone;
                whatsappChat.User__c = UserInfo.getUserId();
                whatsappChat.Type_of_Message__c = 'Inbound Messages';
                whatsappChat.Message_Type__c = messageType;
                whatsappChat.WhatsAppMessageId__c = whatsAppMessageID;
                whatsappChat.Date_of_Message__c = formattedDate;
                List<WBConnect_Chat__c> replyToChat = [SELECT Id FROM WBConnect_Chat__c WHERE WhatsAppMessageId__c != null AND WhatsAppMessageId__c =:contextId AND User__c = :UserInfo.getUserId()];
                whatsappChat.Reply_To__c = replyToChat.size() > 0 ? replyToChat[0].Id : null;

                if (messageType.equalsIgnoreCase('text')){
                    Map<String, Object> text = (Map<String, Object>) message.get('text');
                    String messageBody = '';
                    if(text != null && text.values() != null){
                        messageBody = (String) text.get('body');
                    }
                    whatsappChat.Message__c = messageBody;
                }
                if (messageType.equalsIgnoreCase('image')){
                    Map<String, Object> image = (Map<String, Object>) message.get('image');
                    String imageId = (String) image.get('id');
                    String mimeType = (String) image.get('mime_type');
                    String fileExtension = getFileExtension(mimeType);
                    String fileDateFormat = myDateTime.format('ddMMyyyy_HHmmss');
                    String filename = 'IMG-' + fileDateFormat + fileExtension;

                    Blob documentBody = handleMediaAttachment(imageId);
                    Map<String, Object> filedata = new Map<String, Object>();
                    if (documentBody != null){
                        if(configData != null) {
                            String fileUrl = AWSFilesController.uploadFileToS3(fileName, documentBody, mimeType);
                            whatsappChat.Message__c = fileUrl;
                            fileData = new Map<String, Object>{ 'fileName' => filename, 'mimeType' => mimeType };
                            whatsappChat.File_Data__c = JSON.serialize(filedata);
                        }
                    }
                }
                if (messageType.equalsIgnoreCase('document')){
                    Map<String, Object> document = (Map<String, Object>)message.get('document');
                    String mediaId = (String) document.get('id');
                    String mimeType = (String) document.get('mime_type');
                    // String filename = whatsAppMessageID + '-' + mimeType;
                    String name = (String) document.get('filename');
                    String fileExtension = getFileExtension(mimeType);
                    String filename = name + fileExtension;

                    Blob documentBody = handleMediaAttachment(mediaId);

                    Map<String, Object> filedata = new Map<String, Object>();
                    if (documentBody != null){
                        if(configData != null) {
                            String fileUrl = AWSFilesController.uploadFileToS3(fileName, documentBody, mimeType);
                            whatsappChat.Message__c = fileUrl;
                            fileData = new Map<String, Object>{ 'fileName' => filename, 'mimeType' => mimeType };
                            whatsappChat.File_Data__c = JSON.serialize(filedata);
                        }
                    }
                }
                if (messageType.equalsIgnoreCase('video')){
                    Map<String, Object> video = (Map<String, Object>) message.get('video');
                    String videoId = (String) video.get('id');
                    String mimeType = (String) video.get('mime_type');
                    // String filename = whatsAppMessageID + '-' + mimeType;
                    String fileExtension = getFileExtension(mimeType);
                    String fileDateFormat = myDateTime.format('ddMMyyyy_HHmmss');
                    String filename = 'VID-' + fileDateFormat + fileExtension;

                    Blob documentBody = handleMediaAttachment(videoId);
                    Map<String, Object> filedata = new Map<String, Object>();
                    if (documentBody != null){
                        if(configData != null) {
                            String fileUrl = AWSFilesController.uploadFileToS3(fileName, documentBody, mimeType);
                            whatsappChat.Message__c = fileUrl;
                            fileData = new Map<String, Object>{ 'fileName' => filename, 'mimeType' => mimeType };
                            whatsappChat.File_Data__c = JSON.serialize(filedata);
                        }
                    }
                }
                if (messageType.equalsIgnoreCase('audio')){
                    Map<String, Object> video = (Map<String, Object>) message.get('audio');
                    String audioId = (String) video.get('id');
                    String mimeType = (String) video.get('mime_type');
                    // String filename = whatsAppMessageID + '-' + mimeType;
                    String fileExtension = getFileExtension(mimeType);
                    String fileDateFormat = myDateTime.format('ddMMyyyy_HHmmss');
                    String filename = 'AUD-' + fileDateFormat + fileExtension;

                    Blob documentBody = handleMediaAttachment(audioId);
                    Map<String, Object> filedata = new Map<String, Object>();
                    if (documentBody != null){
                        if(configData != null) {
                            String fileUrl = AWSFilesController.uploadFileToS3(fileName, documentBody, mimeType);
                            whatsappChat.Message__c = fileUrl;
                            fileData = new Map<String, Object>{ 'fileName' => filename, 'mimeType' => mimeType };
                            whatsappChat.File_Data__c = JSON.serialize(filedata);
                        }
                    }
                }
                if (messageType.equalsIgnoreCase('button')){
                    Map<String, Object> button = (Map<String, Object>)message.get('button');
                    String payload = (String) button.get('payload');
                    String text = (String) button.get('text');
                    whatsappChat.Message__c = text;
                    if (contextId != null && contextId != ''){
                        whatsappChat.WhatsAppContextMessageID__c = contextId;
                    }
                    whatsappChat.Message_Type__c = 'text';
                }
                if (messageType.equalsIgnoreCase('interactive')) {
                    Map<String, Object> interactive = (Map<String, Object>)message.get('interactive');
                    System.debug('interactive: ' + interactive);
                    if (interactive != null) { 
                        String interactiveType = (String)interactive.get('type');
                        if (interactiveType == 'nfm_reply') {
                            Map<String, Object> nfmReply = (Map<String, Object>)interactive.get('nfm_reply');
                            System.debug('nfmReply : ' + nfmReply);
                            if (nfmReply != null) { 
                                String responseJson = (String)nfmReply.get('response_json');
                                System.debug('responseJson: ' + responseJson);
                                if(responseJson != null){
                                    whatsappChat.Flow_Response_JSON__c = responseJson;
                                }
                            }
                        }
                        whatsappChat.Message_Type__c = 'interactive';
                    }
                }
            }
            whatsappChat.Last_Interaction_Date__c = System.now();
            insert whatsappChat;
        } catch (Exception e){
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsAppWebhook', 'methodName' => 'processSingleMessage', 'exceptionObj' => e, 'isApiException' => False, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
            System.debug('Error in processSingleMessage: ' + e.getMessage() + '\n' + e + '\n Exception line no: ' + e.getLineNumber());
        }
    }

    public static String getFileExtension(String mimeType){
        if (mimeType.equals('image/jpeg')){
            return '.jpeg';
        } else if (mimeType.equals('image/png')){
            return '.png';
        } else if (mimeType.equals('image/jpg')){
            return '.jpg';
        } else if (mimeType.equals('audio/mp3') || mimeType.equals('audio/mpeg')){
            return '.mp3';
        } else if (mimeType.equals('audio/aac')){
            return '.aac';
        } else if (mimeType.equals('audio/ogg; codecs=opus')){
            return '.ogg';
        } else if (mimeType.equals('video/mp4')){
            return '.mp4';
        } else if (mimeType.equals('video/3gp')){
            return '.3gp';
        } else if (mimeType.equals('application/pdf')){
            return '.pdf';
        } else if (mimeType.equals('application/msword')){
            return '.doc';
        } else if (mimeType.equals('application/vnd.openxmlformats-officedocument.wordprocessingml.document')){
            return '.docx';
        } else if (mimeType.equals('application/vnd.ms-powerpoint')){
            return '.ppt';
        } else if (mimeType.equals('application/vnd.openxmlformats-officedocument.presentationml.presentation')){
            return '.pptx';
        } else if (mimeType.equals('application/vnd.ms-excel')){
            return '.xls';
        } else if (mimeType.equals('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')){
            return '.xlsx';
        } else if (mimeType.equals('text/plain')){
            return '.txt';
        } else{
            return '.bin';
        }
    }

    // @future(callout=true)
    public static Blob handleMediaAttachment(String documentId){
        try{
            String mediaUrl = 'https://graph.facebook.com/v20.0/' + documentId;
            String accessToken = '';
            List<WBConnect_Configuration__mdt> config = WBConnect_Configuration__mdt.getAll().values();
            accessToken = config[0].Access_Token__c;
            
            if (accessToken != ''){
                HttpRequest req = new HttpRequest();
                req.setEndpoint(mediaUrl);
                req.setMethod('GET');
                req.setHeader('Authorization', 'Bearer ' + accessToken);
                HttpResponse res;

                try{
                    Http http = new Http();
                    res = http.send(req);
                    System.debug('res:- '+res);

                    if (res.getStatusCode() == 200){
                        // Parse the metadata response
                        Map<String, Object> mediaMetadata = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        String downloadUrl = (String) mediaMetadata.get('url'); // Retrieve download URL from metadata
                        system.debug('mediaid url===> ' + downloadUrl);

                        // Download the media content
                        return downloadMediaContent(downloadUrl, accessToken);
                    } else{
                        System.debug('Failed to retrieve media metadata. Status: ' + res.getStatus() + ', Response: ' + res.getBody());
                        return null;
                    }
                } catch (Exception e){
                    System.debug('Error in handleMediaAttachment: ' + e.getMessage() + '\n' + e + '\n Exception line no: ' + e.getLineNumber());
                    return null;
                }
            } else{
                System.debug('Failed fetched access token and endpoint from custom labels');
                return null;
            }
        } catch (Exception e){
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsAppWebhook', 'methodName' => 'processSingleMessage', 'exceptionObj' => e, 'isApiException' => False, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
            System.debug('Error in handleMediaAttachment: ' + e.getMessage() + '\n' + e + '\n Exception line no: ' + e.getLineNumber());
            return null;
        }
    }

    public static Blob downloadMediaContent(String mediaUrl, String accessToken){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(mediaUrl);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        HttpResponse res;

        try{
            Http http = new Http();
            res = http.send(req);

            if (res.getStatusCode() == 200){
                // Return the binary data
                return res.getBodyAsBlob();
            } else{
                System.debug('Failed to download media. Status: ' + res.getStatus() + ', Response: ' + res.getBody());
                return null;
            }
        } catch (Exception e){
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsAppWebhook', 'methodName' => 'downloadMediaContent', 'exceptionObj' => e, 'isApiException' => False, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
            System.debug('Error in downloadMediaContent: ' + e.getMessage() + '\n' + e + '\n Exception line no: ' + e.getLineNumber());
            return null;
        }
    }

    public static List<WhatsAppMessage> parseMessages(String jsonString){
        try{
            List<WhatsAppMessage> messages = new List<WhatsAppMessage>();
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            List<Object> entries = (List<Object>)jsonMap.get('entry');

            if (entries != null && !entries.isEmpty()){
                for (Object entryObj : entries){
                    Map<String, Object> entry = (Map<String, Object>)entryObj;
                    List<Object> changes = (List<Object>)entry.get('changes');

                    if (changes != null && !changes.isEmpty()){
                        for (Object changeObj : changes){
                            Map<String, Object> change = (Map<String, Object>)changeObj;
                            Map<String, Object> value = (Map<String, Object>)change.get('value');
                            List<Object> contacts = (List<Object>)value.get('contacts');
                            List<Object> statuses = (List<Object>)value.get('statuses');

                            if (contacts != null && !contacts.isEmpty()){
                                for (Object contactObj : contacts){
                                    Map<String, Object> contact = (Map<String, Object>)contactObj;
                                    Map<String, Object> profile = (Map<String, Object>)contact.get('profile');
                                    String profileName = (String) profile.get('name');

                                    List<Object> messagesList = (List<Object>)value.get('messages');
                                    if (messagesList != null && !messagesList.isEmpty()){
                                        for (Object messageObj : messagesList){
                                            Map<String, Object> message = (Map<String, Object>)messageObj;
                                            WhatsAppMessage msg = new WhatsAppMessage();
                                            msg.profileName = profileName;
                                            msg.timestamp = (String) message.get('timestamp');
                                            msg.WAMId = (String) message.get('id');

                                            String messageType = (String) message.get('type');

                                            switch  on messageType{
                                                when 'text'{
                                                    Map<String, Object> text = (Map<String, Object>)message.get('text');
                                                    msg.textBody = (String) text.get('body');
                                                    msg.textType = messageType;
                                                }
                                                when 'document'{
                                                    Map<String, Object> document = (Map<String, Object>)message.get('document');
                                                    msg.textBody = (String) document.get('filename');
                                                    msg.textType = messageType;
                                                    msg.mimeType = (String) document.get('mime_type');
                                                    msg.documentId = (String) document.get('id');
                                                }
                                                when 'image'{
                                                    Map<String, Object> image = (Map<String, Object>)message.get('image');
                                                    msg.imageBody = (String) image.get('caption');
                                                    msg.imageType = messageType;
                                                    msg.mimeType = (String) image.get('mime_type');
                                                    msg.imageId = (String) image.get('id');
                                                    msg.imageUrl = (String) image.get('link');
                                                }
                                                when 'video'{
                                                    Map<String, Object> image = (Map<String, Object>)message.get('video');
                                                    msg.videoBody = (String) image.get('caption');
                                                    msg.videoType = messageType;
                                                    msg.mimeType = (String) image.get('mime_type');
                                                    msg.videoId = (String) image.get('id');
                                                    msg.videoUrl = (String) image.get('link');
                                                }
                                                when 'audio'{
                                                    Map<String, Object> image = (Map<String, Object>)message.get('audio');
                                                    msg.audioBody = (String) image.get('caption');
                                                    msg.audioType = messageType;
                                                    msg.mimeType = (String) image.get('mime_type');
                                                    msg.audioId = (String) image.get('id');
                                                    msg.audioUrl = (String) image.get('link');
                                                }
                                                when 'button'{
                                                    Map<String, Object> button = (Map<String, Object>)message.get('button');
                                                    msg.textBody = (String) button.get('text');
                                                    msg.textType = messageType;
                                                }
                                                when else{
                                                    // Handle unsupported message types if necessary
                                                    msg.textBody = 'Unsupported message type: ' + messageType;
                                                    msg.textType = messageType;
                                                }
                                            }
                                            messages.add(msg);
                                        }
                                    }
                                }
                            }

                            if (statuses != null && !statuses.isEmpty()){
                                for (Object statusObj : statuses){
                                    Map<String, Object> statusMap = (Map<String, Object>)statusObj;
                                    String status = (String) statusMap.get('status');
                                    String waid = statusMap!= null ? (String) statusMap.get('id') : null;

                                    List<WBConnect_Chat__c> waChats = [SELECT Id, Message_Status__c, WhatsAppMessageId__c, Phone__c FROM WBConnect_Chat__c WHERE WhatsAppMessageId__c = :waid AND User__c = :UserInfo.getUserId() LIMIT 1];
                                    if(waChats.size() > 0){
                                        WBConnect_Chat__c waChat = waChats[0];
                                        if (status == 'sent' && waChat.Message_Status__c != 'Delivered' && waChat.Message_Status__c != 'Seen'){
                                            waChat.Message_Status__c = 'Sent';
                                        } else if (status == 'delivered' && waChat.Message_Status__c != 'Seen'){
                                            waChat.Message_Status__c = 'Delivered';
                                        } else if (status == 'read'){
                                            waChat.Message_Status__c = 'Seen';
                                        }
                                        update waChat;
                                    }
                                }
                            }

                            if (value.containsKey('event')){
                                String event = (String) value.get('event');
                                String templateId = String.valueOf(value.get('message_template_id'));
                                updateWhatsAppTemplateStatus(templateId, event);
                            }
                        }
                    }
                }
            }
            return messages;
        } catch (Exception e){
            // ExceptionHandler.logException(new Map<String, Object>{'className' => 'WhatsAppWebhook', 'methodName' => 'parseMessages', 'exceptionObj' => e, 'isApiException' => False, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
            System.debug('Error in parseMessages: ' + e.getMessage() + '\n' + e + '\n Exception line no: ' + e.getLineNumber());
            return null;
        }
    }

    // @future(callout = true)
    public static void updateWhatsAppTemplateStatus(String templateId, String event){
        try{
            List<WBConnect_Template__c> templates = [SELECT Id, Status__c FROM WBConnect_Template__c WHERE Template_Id__c = :templateId LIMIT 1];

            if (!templates.isEmpty()){
                WBConnect_Template__c waTemplate = templates[0];

                if (event == 'APPROVED'){
                    waTemplate.Status__c = 'Active-Quality Pending';
                } else if (event == 'PENDING'){
                    waTemplate.Status__c = 'In-Review';
                } else if (event == 'REJECTED'){
                    waTemplate.Status__c = 'Rejected';
                }
                update waTemplate;
            } else{
                System.debug('No WhatsApp Template found for Template Id: ' + templateId);
            }
        } catch (Exception e){
            System.debug('Error in updateWhatsAppTemplateStatus: ' + e.getMessage() + '\n' + e + '\n Exception line no: ' + e.getLineNumber());
        }
    }

    public class WhatsAppMessage{
        public String profileName{ get; set; }
        public String timestamp{ get; set; }
        public String WAMId{ get; set; }
        public String textBody{ get; set; }
        public String textType{ get; set; }
        public String mimeType{ get; set; }
        public String documentId{ get; set; }
        public String imageId{ get; set; }
        public String imageUrl{ get; set; }
        public String imageBody{ get; set; }
        public String imageType{ get; set; }
        public String videoBody{ get; set; }
        public String videoId{ get; set; }
        public String videoUrl{ get; set; }
        public String videoType{ get; set; }
        public String audioBody{ get; set; }
        public String audioType{ get; set; }
        public String audioId{ get; set; }
        public String audioUrl{ get; set; }
    }
}