@isTest
public without sharing class AutomationConfigTriggerHandlerTest {
    @isTest
    static void testFilterAndProcessValidChats() {
        // Create WBConnect_Template__c with Button JSON
        WBConnect_Template__c template = new WBConnect_Template__c(
            Template_Id__c = 'test',
            Button_Body__c = '[{"type":"QUICK_REPLY","text":"Yes"},{"type":"QUICK_REPLY","text":"No"}]'
        );
        insert template;

        // Create original parent chat message (outbound)
        WBConnect_Chat__c parentChat = new WBConnect_Chat__c(
            Type_of_Message__c = 'Outbound Messages',
            WBConnect_Template__c = template.Id,
            WhatsAppMessageId__c = 'msg12345'
        );
        insert parentChat;

        // Create matching automation
        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Test Automation',
            Template__c = template.Id
        );
        insert automation;

        // Create valid inbound reply chat
        WBConnect_Chat__c childChat = new WBConnect_Chat__c(
            Type_of_Message__c = 'Inbound Messages',
            Reply_to__c = parentChat.Id,
            Message__c = 'Yes',
            WhatsAppContextMessageID__c = 'msg12345',
            Message_Type__c = 'interactive',
            Flow_Response_JSON__c = '{"step":"1"}'
        );
        insert childChat;

        // Mock configuration
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'abc123',
            Phone_Number_Id__c = 'phone001',
            Is_WBA_Configured__c = true
        );
        insert config;

        Test.startTest();
        // Prepare data for handler
        List<WBConnect_Chat__c> newList = [SELECT Id, Message__c, Type_of_Message__c, Reply_to__c, WhatsAppContextMessageID__c, Message_Type__c, Flow_Response_JSON__c FROM WBConnect_Chat__c WHERE Id = :childChat.Id];
        List<WBConnect_Chat__c> oldList = new List<WBConnect_Chat__c>();
        Map<Id, WBConnect_Chat__c> newMap = new Map<Id, WBConnect_Chat__c>(newList);
        Map<Id, WBConnect_Chat__c> oldMap = new Map<Id, WBConnect_Chat__c>();

        AutomationConfigTriggerHandler handler = new AutomationConfigTriggerHandler(
            newList,
            oldList,
            newMap,
            oldMap,
            true,  // isInsert
            false, // isUpdate
            false, // isDelete
            false  // isUndelete
        );
        handler.filterAndProcessValidChats();
        Test.stopTest();
    }

    @isTest
    static void testFilterAndProcessValidChatsV1() {
        // Create a Contact (used in the Send Email path)
        Contact testContact = new Contact(FirstName='Test', LastName='User', Phone='9999999999', Email='test@example.com');
        insert testContact;

        WBConnect_Template__c template = new WBConnect_Template__c(
            Template_Id__c = 'test',
            Button_Body__c = '[{"type":"QUICK_REPLY","text":"Yes"},{"type":"QUICK_REPLY","text":"No"}]'
        );
        insert template;

        // Create WBConnect_Automation__c
        WBConnect_Automation__c automation = new WBConnect_Automation__c(Name='Test Automation');
        insert automation;

        // Create WBConnect_Automation_Path__c
        WBConnect_Automation_Path__c path = new WBConnect_Automation_Path__c(
            Name='Test Path',
            Automation__c=automation.Id,
            Button_Value__c='yes',
            Action_Type__c='Send Email',
            Action_Email_Template__c=template.Id
        );
        insert path;
        // Create WBConnect_Automation_Path__c
        WBConnect_Automation_Path__c path2 = new WBConnect_Automation_Path__c(
            Name='Test Path',
            Automation__c=automation.Id,
            Action_Type__c='Create a Record',
            Object_Name__c='Contact',
            Field_Mapping__c='{"LastName":"step"}'
        );
        insert path2;

        // Create WBConnect_Template_Variable__c (only for 'Send Message' path, but not needed for this path)
        // Insert original WBConnect_Chat__c (template message)
        WBConnect_Chat__c originalChat = new WBConnect_Chat__c(
            Phone__c='9999999999',
            Message__c='Original',
            WhatsAppMessageId__c='abc123',
            WBConnect_Template__c=String.valueOf(template.Id)
        );
        insert originalChat;

        // Create reply WBConnect_Chat__c
        WBConnect_Chat__c replyChat = new WBConnect_Chat__c(
            Phone__c='9999999999',
            Message__c='',
            Message_Type__c='interactive',
            WhatsAppContextMessageID__c='abc123',
            Reply_To__c=originalChat.Id
        );
        insert replyChat;

        // String normalizedMessageBody = '';
        // if(replyChat.Message_Type__c == 'interactive'){
        //     normalizedMessageBody = 'interactive';
        // } else{
        //     normalizedMessageBody = replyChat.Message__c.toLowerCase().trim();
        // }

        WBConnect_Chat__c parentChat = new WBConnect_Chat__c(
            Type_of_Message__c = 'Outbound Messages',
            WBConnect_Template__c = template.Id,
            WhatsAppMessageId__c = 'msg12345'
        );
        insert parentChat;

        WBConnect_Chat__c childChat = new WBConnect_Chat__c(
            Type_of_Message__c = 'Inbound Messages',
            Reply_to__c = parentChat.Id,
            Message__c = 'Yes',
            WhatsAppContextMessageID__c = 'msg12345',
            Message_Type__c = 'interactive',
            Flow_Response_JSON__c = '{"step":"1"}'
        );
        insert childChat;

        // Construct inputs
        List<WBConnect_Chat__c> potentialPathReplies = [SELECT Id, Phone__c, Message__c, WhatsAppContextMessageID__c, Message_Type__c FROM WBConnect_Chat__c WHERE Id = :replyChat.Id];

        Map<String, WBConnect_Chat__c> originalChatsMap = new Map<String, WBConnect_Chat__c>{
            'abc123' => originalChat
        };

        Map<String, List<Id>> templateToAutomationIdMap = new Map<String, List<Id>>{
            String.valueOf(template.Id) => new List<Id>{automation.Id}
        };

        Map<Id, Map<String, WBConnect_Automation_Path__c>> automationPathsMap = new Map<Id, Map<String, WBConnect_Automation_Path__c>>{
            automation.Id => new Map<String, WBConnect_Automation_Path__c>{
                'yes' => path
            }
        };
        Map<Id, Map<String, WBConnect_Automation_Path__c>> automationPathsMap2 = new Map<Id, Map<String, WBConnect_Automation_Path__c>>{
            automation.Id => new Map<String, WBConnect_Automation_Path__c>{
                'yes' => path2
            }
        };

        // Call the method to test
        Test.startTest();
        // Prepare data for handler
        List<WBConnect_Chat__c> newList = [SELECT Id, Message__c, Type_of_Message__c, Reply_to__c, WhatsAppContextMessageID__c, Message_Type__c, Flow_Response_JSON__c FROM WBConnect_Chat__c WHERE Id = :childChat.Id];
        List<WBConnect_Chat__c> oldList = new List<WBConnect_Chat__c>();
        Map<Id, WBConnect_Chat__c> newMap = new Map<Id, WBConnect_Chat__c>(newList);
        Map<Id, WBConnect_Chat__c> oldMap = new Map<Id, WBConnect_Chat__c>();

        AutomationConfigTriggerHandler handler = new AutomationConfigTriggerHandler(
            newList,
            oldList,
            newMap,
            oldMap,
            true,  // isInsert
            false, // isUpdate
            false, // isDelete
            false  // isUndelete
        );
        handler.filterAndProcessValidChats();
        Test.stopTest();
    }

    @isTest
    static void testFilterAndProcessValidChatsV2() {
        // Create WBConnect_Template__c with Button JSON
        WBConnect_Template__c template = new WBConnect_Template__c(
            Template_Id__c = 'test',
            Button_Body__c = '[{"type":"QUICK_REPLY","text":"Yes"},{"type":"QUICK_REPLY","text":"No"}]'
        );
        insert template;

        // Create original parent chat message (outbound)
        WBConnect_Chat__c parentChat = new WBConnect_Chat__c(
            Type_of_Message__c = 'Outbound Messages',
            WBConnect_Template__c = template.Id,
            WhatsAppMessageId__c = 'msg12345'
        );
        insert parentChat;

        // Create matching automation
        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Test Automation',
            Template__c = template.Id
        );
        insert automation;

        WBConnect_Automation_Path__c path2 = new WBConnect_Automation_Path__c(
            Name='Test Path',
            Automation__c=automation.Id,
            Action_Type__c='Create a Record',
            Object_Name__c='Contact',
            Field_Mapping__c='{"LastName":"step"}'
        );
        insert path2;

        // Create valid inbound reply chat
        WBConnect_Chat__c childChat = new WBConnect_Chat__c(
            Type_of_Message__c = 'Inbound Messages',
            Reply_to__c = parentChat.Id,
            Message__c = 'abc',
            WhatsAppContextMessageID__c = 'msg12345',
            Message_Type__c = 'interactive',
            Flow_Response_JSON__c = '{"step":"1"}'
        );
        insert childChat;

        // Mock configuration
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'abc123',
            Phone_Number_Id__c = 'phone001',
            Is_WBA_Configured__c = true
        );
        insert config;

        Test.startTest();
        // Prepare data for handler
        List<WBConnect_Chat__c> newList = [SELECT Id, Message__c, Type_of_Message__c, Reply_to__c, WhatsAppContextMessageID__c, Message_Type__c, Flow_Response_JSON__c FROM WBConnect_Chat__c WHERE Id = :childChat.Id];
        List<WBConnect_Chat__c> oldList = new List<WBConnect_Chat__c>();
        Map<Id, WBConnect_Chat__c> newMap = new Map<Id, WBConnect_Chat__c>(newList);
        Map<Id, WBConnect_Chat__c> oldMap = new Map<Id, WBConnect_Chat__c>();

        AutomationConfigTriggerHandler handler = new AutomationConfigTriggerHandler(
            newList,
            oldList,
            newMap,
            oldMap,
            true,  // isInsert
            false, // isUpdate
            false, // isDelete
            false  // isUndelete
        );
        handler.filterAndProcessValidChats();
        Test.stopTest();
    }

    @testSetup
    static void setupTestData() {
        // Insert meta config
        insert new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'test-token',
            Phone_Number_Id__c = '12345',
            Is_WBA_Configured__c = true
        );
        
        // Create a Contact as a sample object to be referenced in the template
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'test@example.com');
        insert testContact;
        
        // Insert template with variables
        WBConnect_Template__c templateWithVar = new WBConnect_Template__c(
            Template_Id__c = 'test-template-with-var',
            Template_Name__c = 'WelcomeTemplate',
            Header_Body__c = 'Welcome {{1}}',
            Header_Type__c = 'TEXT',
            Language__c = 'en_US',
            Template_Body__c = 'Hello {{1}}, welcome to the platform.',
            Template_Category__c = 'Marketing',
            Button_Body__c = '[{"type":"url","text":"Click Here","url":"https://example.com"}]'
        );
        insert templateWithVar;

        insert new WBConnect_Template_Variable__c(
            Name = '{{1}}',
            Field_Name__c = 'FirstName',
            Object_Name__c = 'Contact',
            Template__c = templateWithVar.Id,
            Type__c = 'Body',
            Alternate_Text__c = 'Customer'
        );

        // Template without variables
        WBConnect_Template__c templateWithoutVar = new WBConnect_Template__c(
            Template_Id__c = 'test-template-without-var',
            Template_Name__c = 'StaticTemplate',
            Header_Body__c = 'Static Header',
            Header_Type__c = 'TEXT',
            Language__c = 'en_US',
            Template_Body__c = 'Static Body Content',
            Template_Category__c = 'Marketing'
        );
        insert templateWithoutVar;
    }

    @isTest
    static void testGetTemplateData_WithVariables() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        WBConnect_Template__c template = [SELECT Id FROM WBConnect_Template__c LIMIT 1];

        Test.startTest();
        Map<String, Object> result = AutomationConfigTriggerHandler.getTemplateData(
            template.Id,
            c.Id,
            'Contact'
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Template data should not be null');
        System.assert(result.containsKey('template'), 'Template key missing');
        System.assert(result.containsKey('bodyParams'), 'Body parameters missing');
    }

    @isTest
    static void testGetTemplateData_WithoutVariables() {
        WBConnect_Template__c template = [SELECT Id FROM WBConnect_Template__c WHERE Template_Variable__c = 0 LIMIT 1];

        Test.startTest();
        Map<String, Object> result = AutomationConfigTriggerHandler.getTemplateData(
            template.Id,
            null,
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Template data should not be null for static template');
        System.assert(result.containsKey('template'), 'Template key missing');
    }

    @isTest
    static void testGeneratePayloadFromTemplateData() {
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        WBConnect_Template__c template = [SELECT Id FROM WBConnect_Template__c WHERE Template_Variable__c > 0 LIMIT 1];

        Map<String, Object> templateData = AutomationConfigTriggerHandler.getTemplateData(
            template.Id,
            c.Id,
            'Contact'
        );

        Test.startTest();
        String payload = AutomationConfigTriggerHandler.generatePayloadFromTemplateData(templateData, '919999999999');
        Test.stopTest();

        System.assertNotEquals(null, payload, 'Payload should not be null');
        System.debug('Generated Payload: ' + payload);
    }

    @isTest
    static void testGeneratePayloadFromTemplateData_Static() {
        WBConnect_Template__c template = [SELECT Id FROM WBConnect_Template__c WHERE Template_Variable__c = 0 LIMIT 1];

        Map<String, Object> templateData = AutomationConfigTriggerHandler.getTemplateData(
            template.Id,
            null,
            null
        );

        Test.startTest();
        String payload = AutomationConfigTriggerHandler.generatePayloadFromTemplateData(templateData, '919999999999');
        Test.stopTest();

        System.assertNotEquals(null, payload, 'Payload should not be null for static template');
    }

    @isTest
    static void testCreateJSONBody() {
        // Set test data for header, body, and buttons
        List<Object> headerParams = new List<Object>{ 'WelcomeHeader' };
        List<Object> bodyParams = new List<Object>{ 'John', 'Welcome to our service!' };
        
        List<Map<String, Object>> buttonList = new List<Map<String, Object>>{
            new Map<String, Object>{
                'type' => 'PHONE_NUMBER',
                'phone_number' => '+1234567890'
            },
            new Map<String, Object>{
                'type' => 'COPY_CODE',
                'example' => 'COUPON2025'
            },
            new Map<String, Object>{
                'type' => 'OTP'
            },
            new Map<String, Object>{
                'type' => 'FLOW'
            }
        };

        Map<String, Object> data = new Map<String, Object>{
            'templateName' => 'welcome_template',
            'languageCode' => 'en_US',
            'headerParameters' => headerParams,
            'headerType' => 'image',
            'headerImageURL' => 'https://example.com/sample.jpg',
            'bodyParameters' => bodyParams,
            'templateType' => 'Standard',
            'buttonValue' => buttonList
        };

        Test.startTest();
        String jsonBody = AutomationConfigTriggerHandler.createJSONBody('+918888888888', 'template', data);
        Test.stopTest();
    }

    @isTest
    static void testCreateChat() {
        // Insert WBConnect_Meta_Configuration__c configuration
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'test-token',
            Phone_Number_Id__c = '1234567890',
            Is_WBA_Configured__c = true
        );
        insert config;

        // Mock method to simulate WhatsAppWebhook.getUserAccount()
        Test.startTest();
        String userAccountId = UserInfo.getUserId(); // or hardcoded ID if overridden in test

        Map<String, String> chatData = new Map<String, String>{
            'message' => 'Test message',
            'templateId' => null,
            'messageType' => 'text',
            'replyToChatId' => null,
            'phoneNumber' => '+919999999999'
        };
        WBConnect_Chat__c chat = AutomationConfigTriggerHandler.createChat(chatData);
        Test.stopTest();
    }

    @isTest
    static void testSendWhatsappMessage_success() {
        // Insert WBConnect_Meta_Configuration__c configuration
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'test-token',
            Phone_Number_Id__c = '1234567890',
            Is_WBA_Configured__c = true
        );
        insert config;

        String userAccountId = WhatsAppWebhook.getUserAccount();
        // Create a test chat record
        WBConnect_Chat__c chat = new WBConnect_Chat__c(
            Message__c = 'Hello!',
            Phone__c = '+919999999999',
            Type_of_Message__c = 'OutBound Messages',
            Message_Status__c = 'Delivered',
            Message_Type__c = 'text',
            Account__c = userAccountId
        );
        insert chat;

        // Prepare the mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"messages":[{"id":"wamid.fake-id-12345"}]}');
        mockResponse.setStatusCode(200);

        // Use the pre-existing mock class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Prepare JSON payload
        String jsonData = '{"messaging_product":"whatsapp","to":"+919999999999","type":"text","text":{"body":"Hello!"}}';

        Test.startTest();
        AutomationConfigTriggerHandler.sendWhatsappMessage(jsonData, chat.Id);
        Test.stopTest();
    }

    @isTest
    static void testSendWhatsappMessage_failure() {
        // Insert WBConnect_Meta_Configuration__c configuration
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'test-token',
            Phone_Number_Id__c = '1234567890',
            Is_WBA_Configured__c = true
        );
        insert config;
        String userAccountId = WhatsAppWebhook.getUserAccount();

        // Insert a chat without phone number
        WBConnect_Chat__c chat = new WBConnect_Chat__c(
            Message__c = 'Failure Test',
            Type_of_Message__c = 'OutBound Messages',
            Message_Status__c = 'Sent',
            Message_Type__c = 'text',
            Account__c = userAccountId
        );
        insert chat;

        // Prepare the mock HTTP response for failure
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"error":"Invalid request"}');
        mockResponse.setStatusCode(400);

        // Use the pre-existing mock class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        AutomationConfigTriggerHandler.sendWhatsappMessage('{}', chat.Id);
        Test.stopTest();
    }
}