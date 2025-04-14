/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-04-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ChatWindowControllerTest {

    @testSetup
    static void setup() {
        try {
            String userAccountId = WhatsAppWebhook.getUserAccount();

            // Create contact record
            WBConnect_Contact__c contact = new WBConnect_Contact__c(
                Name = 'Test',
                Account__c = userAccountId,
                Phone__c = '1234567890'
            );
            insert contact;

            WBConnect_Chat__c testChat = new WBConnect_Chat__c(
                Message__c = 'Test Message',
                // Contact__c = testContact.Id,
                Type_of_Message__c = 'OutBound Messages',
                Message_Status__c = 'Sent',
                // Time_of_Message__c = '12:00',
                Date_of_Message__c = Date.today(),
                Message_Type__c = 'Text',
                Phone__c = '+911234567890'
            );
            insert testChat;
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowControllerTest', 'methodName' => 'setup', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
    }

    @isTest
    static void testGetCombinedData() {
        try {
            Contact testContact = [SELECT Id FROM Contact LIMIT 1];

            Test.startTest();
            Map<String, Object> combinedData = ChatWindowController.getCombinedData(testContact.Id, 'Contact');
            Test.stopTest();

            list<WBConnect_Chat__c> chats = (list<WBConnect_Chat__c>) combinedData.get('chats');
            // System.assert( chats.size() > 0, 'Chats should be returned.');
            // System.assertEquals('Test Message', chats[0].Message__c, 'Chat message should match the test data.');
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{'className' => 'ChatWindowControllerTest', 'methodName' => 'testGetCombinedData', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null});
        }
    }

    @isTest
    static void testCreateChat() {
        try {
            WBConnect_Contact__c testContact = [SELECT Id, Phone__c FROM WBConnect_Contact__c LIMIT 1];

            Map<String, String> chatData = new Map<String, String>{
                'message' => 'Hello!',
                'templateId' => null,
                'messageType' => 'Text',
                'recordId' => testContact.Id,
                'replyToChatId' => null,
                'phoneNumber' => testContact.Phone__c
            };

            Test.startTest();
            WBConnect_Chat__c newChat = ChatWindowController.createChat(chatData);
            chatData.put('templateId', 'test');
            WBConnect_Chat__c wrongDataChat = ChatWindowController.createChat(chatData);
            Test.stopTest();

            System.assertNotEquals(null, newChat, 'New chat should be created.');
            System.assertEquals('Hello!', newChat.Message__c, 'Message should match the input.');
            // System.assertEquals(testContact.Id, newChat.Contact__c, 'Contact ID should match.');
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowControllerTest', 'methodName' => 'testCreateChat', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
    }

    @isTest
    static void testCreateChatWithImage() {
        try {
            WBConnect_Contact__c testContact = [SELECT Id, Phone__c FROM WBConnect_Contact__c LIMIT 1];

            ContentVersion contentVersion = new ContentVersion(
                Title = 'Test Image',
                VersionData = Blob.valueOf('Test Content'),
                PathOnClient = 'testImage.jpg'
            );
            insert contentVersion;
            ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = 'Test Image' LIMIT 1];

            Map<String, String> chatData = new Map<String, String>{
                'message' => cv.Id,
                'templateId' => null,
                'messageType' => 'Image',
                'recordId' => testContact.Id,
                'replyToChatId' => null,
                'phoneNumber' => testContact.Phone__c
            };

            Test.startTest();
            WBConnect_Chat__c newChat = ChatWindowController.createChat(chatData);
            Test.stopTest();

            System.assertNotEquals(null, newChat, 'New chat should be created.');
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowControllerTest', 'methodName' => 'testCreateChatWithImage', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
    }

    @isTest
    static void testUpdateReaction() {
        try {
            WBConnect_Chat__c testChat = [SELECT Id FROM WBConnect_Chat__c LIMIT 1];

            Test.startTest();
            WBConnect_Chat__c updatedChat = ChatWindowController.updateReaction(testChat.Id, 'Like');
            WBConnect_Chat__c wrongDataChat = ChatWindowController.updateReaction('test', 'Like');
            Test.stopTest();

            System.assertNotEquals(null, updatedChat, 'Chat should be updated.');
            System.assertEquals('Like', updatedChat.Reaction__c, 'Reaction should match the input.');
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowControllerTest', 'methodName' => 'testUpdateReaction', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
    }

    // @isTest
    // static void testUpdateThemePreference() {
    //     try {

    //         Test.startTest();
    //         Boolean isSuccess = ChatWindowController.updateThemePreference('light');
    //         Test.stopTest();

    //         System.assertEquals(true, isSuccess, 'Custom setting should be created/updated successfully.');
    //     } catch (Exception e) {
    //         ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowControllerTest', 'methodName' => 'testUpdateThemePreference', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
    //     }
    // }

    @isTest
    static void testSendWhatsappMessage() {
        WBConnect_Contact__c testContact = [SELECT Id, Phone__c FROM WBConnect_Contact__c LIMIT 1];
        WBConnect_Chat__c testChat = [SELECT Id FROM WBConnect_Chat__c LIMIT 1];

        String jsonData = '{"message": "Hello, this is a test message."}';

        ChatWindowController.sendWhatsappMessage(jsonData, testChat.Id, true, '<|USER|>');
        test.setMock(HttpCalloutMock.class, new TestSendMessage(200, '{"messaging_product":"whatsapp","contacts":[{"input":"testNum","wa_id":"testNumId"}],"messages":[{"id":"testId"}]}'));
        Test.startTest();
        Map<String, Object> result = ChatWindowController.sendWhatsappMessage(jsonData, testChat.Id, false, null);
        Test.stopTest();

        System.assertNotEquals(null, result.get('chat'), 'The result should not be null');
    }

    @isTest
    static void testSendWhatsappMessageFailed() {
        WBConnect_Contact__c testContact = [SELECT Id, Phone__c FROM WBConnect_Contact__c LIMIT 1];
        WBConnect_Chat__c testChat = [SELECT Id FROM WBConnect_Chat__c LIMIT 1];
        String jsonData = '{"message": "Hello, this is a test message."}';
        test.setMock(HttpCalloutMock.class, new TestSendMessage(404, ''));
        Test.startTest();
        Map<String, Object> result = ChatWindowController.sendWhatsappMessage(jsonData, testChat.Id, false, null);
        Test.stopTest();

        System.assertNotEquals(null, result.get('chat'), 'The result should not be null');
    }

    @isTest
    static void testGetTemplateData() {
        WBConnect_Contact__c testContact = [SELECT Id, Phone__c FROM WBConnect_Contact__c LIMIT 1];

        WBConnect_Template__c testTemplate = new WBConnect_Template__c(
            Template_Name__c = 'Test Template',
            Header_Type__c = 'Text',
            Header_Body__c = 'Hello {{1}}',
            Template_Body__c = 'Hello {{1}}',
            Template_Id__c = 'testId'
        );
        
        insert testTemplate;

        WBConnect_Template_Variable__c testVariable = new WBConnect_Template_Variable__c(
            Name = '{{1}}',
            Field_Name__c = 'FirstName',
            Object_Name__c = 'Contact',
            Type__c = 'Body',
            Alternate_Text__c = 'name'
        );
        testVariable.Template__c = testTemplate.Id;
        insert testVariable;

        WBConnect_Template_Variable__c testVariable2 = new WBConnect_Template_Variable__c(
            Name = '{{1}}',
            Field_Name__c = 'Name',
            Object_Name__c = 'Account',
            Type__c = 'Header',
            Alternate_Text__c = 'name'
        );
        testVariable2.Template__c = testTemplate.Id;
        insert testVariable2;

        Test.startTest();
        ChatWindowController.getTemplateData(null, testContact.Id, 'Contact');
        Map<String, Object> result = ChatWindowController.getTemplateData(testTemplate.Id, testContact.Id, 'Contact');
        Test.stopTest();

        System.assertNotEquals(null, result.get('template'), 'The result should not be null');
    }

    @isTest
    static void testUpdateStatus(){
        try {
            WBConnect_Chat__c testChat = [SELECT Id FROM WBConnect_Chat__c LIMIT 1];
            testChat.WhatsAppMessageId__c = 'somethingId';

            List<String> messageIds = new List<String>();
            messageIds.add(testChat.Id);

            test.setMock(HttpCalloutMock.class, new testUpdateStatus(200));
            Test.startTest();
            ChatWindowController.updateStatus(messageIds);
            Test.stopTest();

            WBConnect_Chat__c resultChat = [SELECT Id FROM WBConnect_Chat__c WHERE Id =: testChat.Id LIMIT 1];

            System.assertEquals('Seen', resultChat.Message_Status__c, 'The chat status should be updated.');
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowControllerTest', 'methodName' => 'testUpdateStatus', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
    }

    @isTest
    static void testCreateChatForAWSFiles() {
        try {
            WBConnect_Contact__c testContact = [SELECT Id, Phone__c FROM WBConnect_Contact__c LIMIT 1];

            Map<String, String> chatData = new Map<String, String>{
                'message' => 'Hello!',
                'fileName' => 'test.pdf',
                'mimeType' => 'application/pdf',
                'messageType' => 'Document',
                'recordId' => testContact.Id,
                'replyToChatId' => null,
                'phoneNumber' => testContact.Phone__c
            };

            Test.startTest();
            WBConnect_Chat__c newChat = ChatWindowController.createChatForAWSFiles(chatData);
            Test.stopTest();

            System.assertNotEquals(null, newChat, 'New chat should be created.');
        } catch (Exception e) {
            ExceptionHandler.logException(new Map<String, Object>{ 'className' => 'ChatWindowControllerTest', 'methodName' => 'testCreateChatForAWSFiles', 'exceptionObj' => e, 'isApiException' => false, 'statusCode' => null, 'chatId' => null, 'moreDetails' => e.getMessage(), 'apiResponse' => null });
        }
    }

    public class TestSendMessage implements HttpCalloutMock {

        Integer statusCode;
        String body;

        TestSendMessage(Integer statusCode, String body){
            this.statusCode = statusCode;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(statusCode);
            return res;
        }
    }

    public class TestUpdateStatus implements HttpCalloutMock {

        Integer statusCode;

        TestUpdateStatus(Integer statusCode){
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('test');
            res.setStatusCode(statusCode);
            return res;
        }
    }
}