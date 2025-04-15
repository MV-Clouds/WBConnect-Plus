/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class BroadcastMessageControllerTest {

    private static Id broadcastGroupId;
    private static Id broadcastMemberId;

    @testSetup
    static void setupTestData() {

        String userAccountId = WhatsAppWebhook.getUserAccount();

        // Create contact record
        WBConnect_Contact__c contact = new WBConnect_Contact__c(
            Name = 'Test',
            Account__c = userAccountId,
            Phone__c = '1234567890'
        );
        insert contact;

        // Create a Broadcast Group
        WBConnect_Broadcast_Group__c broadcastGroup = new WBConnect_Broadcast_Group__c(
            Name = 'Test Group',
            Description__c = 'Test Description'
            // Object_Name__c = 'Contact',
            // List_View__c = 'Test List View',
            // Phone_Field__c = 'Phone'
        );
        insert broadcastGroup;
        broadcastGroupId = broadcastGroup.Id;

        // Create a Broadcast Group Member
        WBConnect_Broadcast_Group_Member__c member = new WBConnect_Broadcast_Group_Member__c(
            Broadcast_Group_ID__c = broadcastGroupId,
            Phone_Number__c = '1234567890'
        );
        insert member;
        broadcastMemberId = member.Id;

        // Create a Template record
        WBConnect_Template__c template = new WBConnect_Template__c(
            Template_Name__c = 'Test_Template',
            Status__c = 'Active-Quality Pending',
            Language__c = 'en',
            Template_Body__c = 'Hello, {{1}}!',
            Header_Type__c = 'text',
            Header_Body__c = 'Header Text',
            Template_Id__c	= 'testId',
            Button_Body__c = '[{"type":"COPY_CODE","example":"AADDFCGOP"},{"type":"PHONE_NUMBER","text":"Call Phone Number","phone_number":"+9132134213"},{"type":"FLOW","text":"View flow","flow_id":"1161263512165232"}]'
        );


        WBConnect_Template__c template2 = new WBConnect_Template__c(
            Template_Name__c = 'Test_Template2',
            Status__c = 'Active-Quality Pending',
            Language__c = 'en',
            Template_Body__c = 'Hello, {{1}}!',
            Header_Type__c = 'text',
            Header_Body__c = 'Header Text',
            Template_Id__c	= 'testId2',
            Button_Body__c	= '[{"type":"OTP","text":"Verify Code","otp_type":"COPY_CODE"}]'
        );

        insert new List<WBConnect_Template__c>{template, template2};

        WBConnect_Template_Variable__c templateVariable = new WBConnect_Template_Variable__c(
            Name = 'Test Variable',
            Field_Name__c = 'LastName',
            Object_Name__c = 'Contact',
            Alternate_Text__c = 'Alternate Text',
            Template__c = template.Id,
            Type__c = 'Header'
        );


        WBConnect_Template_Variable__c templateVariable2 = new WBConnect_Template_Variable__c(
            Name = 'Test Variable',
            Field_Name__c = 'LastName',
            Object_Name__c = 'Contact',
            Alternate_Text__c = 'Alternate Text',
            Template__c = template2.Id,
            Type__c = 'Body'
        );

        insert new List<WBConnect_Template_Variable__c>{templateVariable, templateVariable2};

        // Create a Broadcast record with no group IDs
        WBConnect_Broadcast__c broadcast = new WBConnect_Broadcast__c(
            WBConnect_Template__c = template.Id,
            Status__c = 'Pending'
        );
        insert broadcast;

        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
                Access_Token__c = 'TestAccessToken',
                Phone_Number_Id__c = 'TestPhoneNumberId',
                Business_Account_Id__c = 'testbusinessid',
                Application_Id__c = 'testAppId',
                Is_WBA_Configured__c = true
            );         
            insert config;
        
    }

        
    // Mocking the HTTP response for testing
    static HttpResponse createMockResponse(String statusCode, String body) {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(Integer.valueOf(statusCode));
        mockResponse.setBody(body);
        return mockResponse;
    }

    @isTest
    static void testGetBroadcastGroups() {
        Test.startTest();
        List<WBConnect_Broadcast_Group__c> groups = BroadcastMessageController.getBroadcastGroups();
        Test.stopTest();

        System.assert(groups.size() > 0, 'There should be at least one broadcast group');
    }

    @isTest
    static void testDeleteBroadcastGroup() {
        
        WBConnect_Broadcast_Group__c tempGroup = [SELECT Id, Name FROM WBConnect_Broadcast_Group__c LIMIT 1];

        Test.startTest();
        BroadcastMessageController.deleteBroadcastGroup(tempGroup.Id);
        Test.stopTest();

        // count query
        Integer count = [SELECT COUNT() FROM WBConnect_Broadcast_Group__c WHERE Id = :tempGroup.Id];
        System.assertEquals(0, count, 'Broadcast group should be deleted');

    }

    @isTest
    static void testGetBroadcastRecs() {
        Test.startTest();
        List<WBConnect_Broadcast__c> broadcasts = BroadcastMessageController.getBroadcastRecs();
        Test.stopTest();

        System.assertNotEquals(null, broadcasts, 'Broadcast records should not be null');
    }

    @isTest
    static void testGetTemplatesByObject() {
        Test.startTest();
        Map<String, List<WBConnect_Template__c>> templatesMap = BroadcastMessageController.getTemplatesByObject();
        Test.stopTest();

        System.assert(templatesMap.size() > 0, 'There should be at least one template mapped');
    }

    @isTest
    static void testProcessBroadcastMessageWithObject_Insert() {
        Map<String, Object> requestMap = new Map<String, Object>{
            'name' => 'New Broadcast Group',
            'description' => 'Test Description',
            'objectApiName' => 'Account',
            'phoneNumbers' => new List<String>{'9876543210'},
            'listViewName' => 'Test List View',
            'isUpdate' => false,
            'phoneField' => 'Phone'
        };
        
        String requestJson = JSON.serialize(requestMap);
    
        Test.startTest();
        BroadcastMessageController.processBroadcastMessageWithObject(requestJson);
        Test.stopTest();
    
        WBConnect_Broadcast_Group__c createdGroup = [SELECT Id, Name FROM WBConnect_Broadcast_Group__c WHERE Name = 'New Broadcast Group' LIMIT 1];
        System.assertNotEquals(null, createdGroup, 'Broadcast group should be created');
    }
    

    @isTest
    static void testProcessBroadcastMessageWithObject_Update() {
        // First create a broadcast group for update
        WBConnect_Broadcast_Group__c tempGroup = new WBConnect_Broadcast_Group__c(
            Name = 'Old Name',
            Description__c = 'Old Description'
            // Object_Name__c = 'Account',
            // List_View__c = 'Old List View',
            // Phone_Field__c = 'Phone'
        );
        insert tempGroup;
    
        Map<String, Object> requestMap = new Map<String, Object>{
            'name' => 'Updated Group Name',
            'description' => 'Updated Description',
            'objectApiName' => 'Account',
            'phoneNumbers' => new List<String>{'1234567890', '9876543210'},
            'listViewName' => 'Updated List View',
            'isUpdate' => true,
            'broadcastGroupId' => tempGroup.Id,
            'phoneField' => 'Phone'
        };
    
        String requestJson = JSON.serialize(requestMap);
    
        Test.startTest();
        BroadcastMessageController.processBroadcastMessageWithObject(requestJson);
        Test.stopTest();
    
        WBConnect_Broadcast_Group__c updatedGroup = [SELECT Name, Description__c FROM WBConnect_Broadcast_Group__c WHERE Id = :tempGroup.Id];
        System.assertEquals('Updated Group Name', updatedGroup.Name, 'Broadcast group name should be updated');
    }
    
    @isTest
    static void testGetBroadcastGroupDetails() {

        WBConnect_Broadcast_Group__c tempGroup = [SELECT Id, Description__c FROM WBConnect_Broadcast_Group__c LIMIT 1];

        Test.startTest();
        Map<String, Object> groupDetails = BroadcastMessageController.getBroadcastGroupDetails(tempGroup.Id);
        Test.stopTest();

        System.assertNotEquals(null, groupDetails, 'Group details should not be null');
    }

    @isTest
    static void testCreateChatRecods_ImmediateExecution() {

        HttpResponse mockResponse = createMockResponse('200', '{"messages":[{"id":"wamid.HBgLMjM0NTY3ODkwVBIJDQAAAB"}]}');
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        WBConnect_Template__c testTemplate = [SELECT Id, Name, Template_Id__c FROM WBConnect_Template__c WHERE Template_Id__c = 'testId' LIMIT 1];
        WBConnect_Broadcast_Group__c tempGroup = [SELECT Id, Name FROM WBConnect_Broadcast_Group__c LIMIT 1];

        Test.startTest();
        String result = BroadcastMessageController.createChatRecods(testTemplate.Id, new List<String>{tempGroup.Id}, false, '');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Method should return Success');
        List<WBConnect_Broadcast__c> broadcasts = [SELECT Id FROM WBConnect_Broadcast__c];
        System.assert(broadcasts.size() > 0, 'Broadcast record should be created');
        
        List<WBConnect_Chat__c> chats = [SELECT Id FROM WBConnect_Chat__c];
        System.assert(chats.size() > 0, 'Chat records should be created');
    }

    @isTest
    static void testCreateChatRecods_ImmediateExecutionWitBody() {

        HttpResponse mockResponse = createMockResponse('200', '{"messages":[{"id":"wamid.HBgLMjM0NTY3ODkwVBIJDQAAAB"}]}');
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);

        WBConnect_Template__c testTemplate = [SELECT Id, Name, Template_Id__c FROM WBConnect_Template__c WHERE Template_Id__c = 'testId2' LIMIT 1];
        WBConnect_Broadcast_Group__c tempGroup = [SELECT Id, Name FROM WBConnect_Broadcast_Group__c LIMIT 1];

        Test.startTest();
        String result = BroadcastMessageController.createChatRecods(testTemplate.Id, new List<String>{tempGroup.Id}, false, '');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Method should return Success');
        List<WBConnect_Broadcast__c> broadcasts = [SELECT Id FROM WBConnect_Broadcast__c];
        System.assert(broadcasts.size() > 0, 'Broadcast record should be created');
        
        List<WBConnect_Chat__c> chats = [SELECT Id FROM WBConnect_Chat__c];
        System.assert(chats.size() > 0, 'Chat records should be created');
    }

    @isTest
    static void testCreateChatRecods_ScheduledExecution() {

        DateTime futureDateTime = DateTime.now().addDays(1);
        String futureTime = futureDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        
        WBConnect_Template__c testTemplate = [SELECT Id, Name FROM WBConnect_Template__c LIMIT 1];
        WBConnect_Broadcast_Group__c tempGroup = [SELECT Id, Name FROM WBConnect_Broadcast_Group__c LIMIT 1];

        Test.startTest();
        String result = BroadcastMessageController.createChatRecods(testTemplate.Id, new List<String>{tempGroup.Id}, true, futureTime);
        Test.stopTest();

        System.assertEquals('Success', result, 'Method should return Success');
        List<WBConnect_Broadcast__c> broadcasts = [SELECT Id, Schedule_DateTime__c FROM WBConnect_Broadcast__c];
        System.assert(broadcasts.size() > 0, 'Broadcast record should be created');
    }

    @isTest
    static void testGetBroadcastGroupsByBroadcastId_NoGroups() {

        WBConnect_Broadcast__c broadcast = [SELECT Id, WBConnect_Template__c, Status__c FROM WBConnect_Broadcast__c LIMIT 1];

        Test.startTest();
        List<WBConnect_Broadcast_Group__c> groups = BroadcastMessageController.getBroadcastGroupsByBroadcastId(broadcast.Id);
        Test.stopTest();

        System.assertNotEquals(null, groups, 'Returned list should not be null');
        System.assertEquals(0, groups.size(), 'There should be no broadcast groups returned');
    }

    @isTest
    static void testgetAllContacts(){
        Test.startTest();
        List<WBConnect_Contact__c> contacts = BroadcastMessageController.getAllContacts();
        Test.stopTest();
    }

}