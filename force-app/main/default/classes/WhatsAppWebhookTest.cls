/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
private class WhatsAppWebhookTest {

    @testSetup static void setup() {
        WBConnect_Template__c temp = new WBConnect_Template__c(
            Template_Name__c = 'hello_world',
            Status__c = 'In-Review',
            Template_Id__c = '138470518808412'
        );
        insert temp;

        WBConnect_Chat__c dummyChatReact = new WBConnect_Chat__c(
            WhatsAppMessageId__c = 'wamid.HBgMOTE5NjY0NTk5NjQxFQIAERgSNjMxRUI5Mzg0RTlBRTUwNEM5AA=='
        );
        insert dummyChatReact;

        Account acc = new Account(Name='Test Account');
        insert acc;

        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'TestAccessToken',
            Phone_Number_Id__c = 'TestPhoneNumberId',
            Business_Account_Id__c = 'testbusinessid',
            Application_Id__c = 'testAppId',
            Account__c = acc.Id,
            Is_WBA_Configured__c = true
        );         
        insert config;
    }
    
    @IsTest
    static void testDoGetWithValidToken() {
        // Setup mock HTTP request for GET
        RestRequest req = new RestRequest();
        req.requestURI = '/WBI/webhooks/v1/';
        req.httpMethod = 'GET';
        req.addParameter('hub.verify_token', 'WHATSAPPTOKEN');
        req.addParameter('hub.challenge', '319254377948692');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Execute the GET method
        WhatsAppWebhook.doGet();

        // Assert the response contains the expected challenge
        System.assertEquals('319254377948692', RestContext.response.responseBody.toString(), 'Expected the challenge to be returned.');
    }

    @IsTest
    static void testDoPostWithValidToken() {
        // Setup mock HTTP request for POST
        RestRequest req = new RestRequest();
        req.requestURI = '/WBI/webhooks/v1/';
        req.httpMethod = 'POST';
        req.addHeader('hub.verify_token', '7fa1634d4f849b8ced3a249ec4ce8bb7db4d8046');
        req.requestBody = Blob.valueOf('{"object":"whatsapp_business_account","entry":[{"id":"319254377948692","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"919558019600","phone_number_id":"397858113402150"},"contacts":[{"profile":{"name":"Kevin Suvagiya"},"wa_id":"919428234735"}],"messages":[{"context":{"from":"919558019600","id":"wamid.HBgMOTE5NDI4MjM0NzM1FQIAERgSRjAwQzUxODZDQTcwQTIxREQwAA=="},"from":"919428234735","id":"wamid.HBgMOTE5NDI4MjM0NzM1FQIAEhggQkYwODA3RkY0RDJGMDg1REFENzU0OEM5MUEzMUFDMTUA","timestamp":"1734343632","type":"button","button":{"payload":"OPT-OUT","text":"OPT-OUT"}}]},"field":"messages"}]}]}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Execute the POST method
        WhatsAppWebhook.doPost();

    }

    @IsTest
    static void testDoPostWithInvalidToken() {
        // Setup mock HTTP request for POST with invalid token
        RestRequest req = new RestRequest();
        req.requestURI = '/WBI/webhooks/v1/';
        req.httpMethod = 'POST';
        req.addHeader('hub.verify_token', 'INVALIDTOKEN');
        req.requestBody = Blob.valueOf('{"object":"whatsapp_business_account","entry":[{"id":"319254377948692","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"919558019600","phone_number_id":"397858113402150"},"contacts":[{"profile":{"name":"Kevin Suvagiya"},"wa_id":"919428234735"}],"messages":[{"from":"919428234735","id":"wamid.HBgMOTE5NDI4MjM0NzM1FQIAEhggRDNCQzM4RjNDMkEwNzJDMUVBQkFGREZGOUFDRkZGN0EA","timestamp":"1734009524","text":{"body":"Reply to first one"},"type":"text"}]},"field":"messages"}]}]}');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Execute the POST method
        WhatsAppWebhook.doPost();

        // Assert the response status code is 403
        System.assertEquals(403, RestContext.response.statusCode, 'Expected status code 403 for invalid token.');
    }

    @IsTest
    static void testProcessWhatsAppPayloadText() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setStatusCode(200);
        mockResponse.setBodyAsBlob(Blob.valueOf('mock-binary-data'));

        String jsonPayload = '{"object":"whatsapp_business_account","entry":[{"id":"319254377948692","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"919558019600","phone_number_id":"397858113402150"},"contacts":[{"profile":{"name":"Kevin Suvagiya"},"wa_id":"919428234735"}],"messages":[{"from":"919428234735","id":"wamid.HBgMOTE5NDI4MjM0NzM1FQIAEhggRDNCQzM4RjNDMkEwNzJDMUVBQkFGREZGOUFDRkZGN0EA","timestamp":"1734009524","text":{"body":"Reply to first one"},"type":"text"}]},"field":"messages"}]}]}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        WhatsAppWebhook.processWhatsAppPayload(jsonPayload);
        Test.stopTest();
        System.assertEquals('397858113402150', WhatsAppWebhook.phoneNumberId, 'Expected phone number ID to be set.');
    }

    @IsTest
    static void testProcessWhatsAppPayloadVideo() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setStatusCode(200);
        mockResponse.setBodyAsBlob(Blob.valueOf('mock-binary-data'));

        String videojsonPayload = '{"object":"whatsapp_business_account","entry":[{"id":"319254377948692","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"919558019600","phone_number_id":"397858113402150"},"contacts":[{"profile":{"name":"Kevin Suvagiya"},"wa_id":"919428234735"}],"messages":[{"from":"919428234735","id":"wamid.HBgMOTE5NDI4MjM0NzM1FQIAEhggNDE0MjFDQjJDOUZGNEIzMjI5RDc1NDlEODU5RUE5QzEA","timestamp":"1734343457","type":"video","video":{"mime_type":"video/mp4","sha256":"T1dLSnJNE3t4mnzLZWSjBWCe61sptppyhF/K//Brx4U=","id":"3827582537491666"}}]},"field":"messages"}]}]}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        WhatsAppWebhook.processWhatsAppPayload(videojsonPayload);
        Test.stopTest();
        System.assertEquals('397858113402150', WhatsAppWebhook.phoneNumberId, 'Expected phone number ID to be set.');
    }

    @IsTest
    static void testProcessWhatsAppPayloadAudio() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setStatusCode(200);
        mockResponse.setBodyAsBlob(Blob.valueOf('mock-binary-data'));

        String audiojsonPayload = '{"object":"whatsapp_business_account","entry":[{"id":"319254377948692","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"919558019600","phone_number_id":"397858113402150"},"contacts":[{"profile":{"name":"Kevin Suvagiya"},"wa_id":"919428234735"}],"messages":[{"from":"919428234735","id":"wamid.HBgMOTE5NDI4MjM0NzM1FQIAEhggNDE0MjFDQjJDOUZGNEIzMjI5RDc1NDlEODU5RUE5QzEA","timestamp":"1734343457","type":"audio","audio":{"mime_type":"audio/mp3","sha256":"T1dLSnJNE3t4mnzLZWSjBWCe61sptppyhF/K//Brx4U=","id":"3827582537491666"}}]},"field":"messages"}]}]}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        WhatsAppWebhook.processWhatsAppPayload(audiojsonPayload);
        Test.stopTest();
        System.assertEquals('397858113402150', WhatsAppWebhook.phoneNumberId, 'Expected phone number ID to be set.');
    }

    @IsTest
    static void testProcessWhatsAppPayloadImage() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setStatusCode(200);
        mockResponse.setBodyAsBlob(Blob.valueOf('mock-binary-data'));

        String imagejsonPayload = '{"object":"whatsapp_business_account","entry":[{"id":"499269473267232","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"919328195415","phone_number_id":"544633438726755"},"contacts":[{"profile":{"name":"Harsh Gandhi"},"wa_id":"919664599641"}],"messages":[{"from":"919664599641","id":"wamid.HBgMOTE5NjY0NTk5NjQxFQIAEhggNTA0QTg1REVFMUVFNTNDODc2MDY0Q0Y2NEI5OTE3RTYA","timestamp":"1743488066","type":"image","image":{"mime_type":"image\\/jpeg","sha256":"5S\\/A4mJNraAT\\/AXCeuFFs5UWrLyr+4HIKu3Ub+UsYpw=","id":"1373448587344141"}}]},"field":"messages"}]}]}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        WhatsAppWebhook.processWhatsAppPayload(imagejsonPayload);
        Test.stopTest();
        System.assertEquals('544633438726755', WhatsAppWebhook.phoneNumberId, 'Expected phone number ID to be set.');
    }

    @IsTest
    static void testProcessWhatsAppPayloadDoc() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setStatusCode(200);
        mockResponse.setBodyAsBlob(Blob.valueOf('mock-binary-data'));

        String documentjsonPayload = '{"object":"whatsapp_business_account","entry":[{"id":"319254377948692","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"919558019600","phone_number_id":"397858113402150"},"contacts":[{"profile":{"name":"Kevin Suvagiya"},"wa_id":"919428234735"}],"messages":[{"from":"919428234735","id":"wamid.HBgMOTE5NDI4MjM0NzM1FQIAEhggNDE0MjFDQjJDOUZGNEIzMjI5RDc1NDlEODU5RUE5QzEA","timestamp":"1734343457","type":"document","document":{"mime_type":"document/pdf","sha256":"T1dLSnJNE3t4mnzLZWSjBWCe61sptppyhF/K//Brx4U=","id":"3827582537491666"}}]},"field":"messages"}]}]}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        WhatsAppWebhook.processWhatsAppPayload(documentjsonPayload);
        Test.stopTest();
        System.assertEquals('397858113402150', WhatsAppWebhook.phoneNumberId, 'Expected phone number ID to be set.');
    }

    @IsTest
    static void testProcessWhatsAppPayloadReaction() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setStatusCode(200);
        mockResponse.setBodyAsBlob(Blob.valueOf('mock-binary-data'));

        String documentjsonPayload = '{"object":"whatsapp_business_account","entry":[{"id":"499269473267232","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"919558019600","phone_number_id":"397858113402150"},"contacts":[{"profile":{"name":"Harsh Gandhi"},"wa_id":"919664599641"}],"messages":[{"from":"919664599641","id":"wamid.HBgMOTE5NjY0NTk5NjQxFQIAEhggQjdDNEQ0OTk1ODQyNkEwQjExNDdBRDNEQjFCNkRBN0UA","timestamp":"1743487801","type":"reaction","reaction":{"message_id":"wamid.HBgMOTE5NjY0NTk5NjQxFQIAERgSNjMxRUI5Mzg0RTlBRTUwNEM5AA==","emoji":"\ud83d\udc4d"}}]},"field":"messages"}]}]}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        WhatsAppWebhook.processWhatsAppPayload(documentjsonPayload);
        Test.stopTest();
        System.assertEquals('397858113402150', WhatsAppWebhook.phoneNumberId, 'Expected phone number ID to be set.');
    }

    @IsTest
    static void testHandleMediaAttachment() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"url": "https://media-server.com/path-to-media"}');

        String documentId = '3827582537491666';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        WhatsAppWebhook.handleMediaAttachment(documentId);
        Test.stopTest();
    }

    @isTest
    static void testGetFileExtension() {
        // Expected extensions
        System.assertEquals('.jpeg', WhatsAppWebhook.getFileExtension('image/jpeg'));
        System.assertEquals('.png', WhatsAppWebhook.getFileExtension('image/png'));
        System.assertEquals('.jpg', WhatsAppWebhook.getFileExtension('image/jpg'));
        System.assertEquals('.mp3', WhatsAppWebhook.getFileExtension('audio/mp3'));
        System.assertEquals('.mp3', WhatsAppWebhook.getFileExtension('audio/mpeg'));
        System.assertEquals('.aac', WhatsAppWebhook.getFileExtension('audio/aac'));
        System.assertEquals('.ogg', WhatsAppWebhook.getFileExtension('audio/ogg; codecs=opus'));
        System.assertEquals('.mp4', WhatsAppWebhook.getFileExtension('video/mp4'));
        System.assertEquals('.3gp', WhatsAppWebhook.getFileExtension('video/3gp'));
        System.assertEquals('.pdf', WhatsAppWebhook.getFileExtension('application/pdf'));
        System.assertEquals('.doc', WhatsAppWebhook.getFileExtension('application/msword'));
        System.assertEquals('.docx', WhatsAppWebhook.getFileExtension('application/vnd.openxmlformats-officedocument.wordprocessingml.document'));
        System.assertEquals('.ppt', WhatsAppWebhook.getFileExtension('application/vnd.ms-powerpoint'));
        System.assertEquals('.pptx', WhatsAppWebhook.getFileExtension('application/vnd.openxmlformats-officedocument.presentationml.presentation'));
        System.assertEquals('.xls', WhatsAppWebhook.getFileExtension('application/vnd.ms-excel'));
        System.assertEquals('.xlsx', WhatsAppWebhook.getFileExtension('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'));
        System.assertEquals('.txt', WhatsAppWebhook.getFileExtension('text/plain'));

        // Test invalid mime type
        System.assertEquals('.bin', WhatsAppWebhook.getFileExtension('unknown/mimetype'));
    }

    @isTest
    static void testUpdateWhatsAppTemplateStatus(){
        WBConnect_Template__c testTemp = [SELECT Id, Template_Id__c, Status__c FROM WBConnect_Template__c LIMIT 1];

        Test.startTest();
        WhatsAppWebhook.updateWhatsAppTemplateStatus(testTemp.Template_Id__c, 'APPROVED');

        WhatsAppWebhook.updateWhatsAppTemplateStatus(testTemp.Template_Id__c, 'PENDING');

        WhatsAppWebhook.updateWhatsAppTemplateStatus(testTemp.Template_Id__c, 'REJECTED');
        Test.stopTest();

        WBConnect_Template__c updatedTemplate = [SELECT Id, Template_Id__c, Status__c FROM WBConnect_Template__c WHERE Template_Id__c = :testTemp.Template_Id__c LIMIT 1];
        System.assertEquals('Rejected', updatedTemplate.Status__c);
    }

    @isTest 
    static void testgetPhonenumberIdRelatedAccount(){

        Test.startTest();
        String phoneNumberId = WhatsAppWebhook.getPhonenumberIdRelatedAccount('TestPhoneNumberId');
        Test.stopTest();
    }
}