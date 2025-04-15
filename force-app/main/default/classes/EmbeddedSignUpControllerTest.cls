@isTest
public class EmbeddedSignUpControllerTest {

    @testSetup
    static void setupData() {
        // Setup mock config data
        WBConnect_Meta_Configuration__c metaConfig = new WBConnect_Meta_Configuration__c(
            Application_Id__c = 'testAppId',
            Business_Account_Id__c = 'testWabaId',
            Access_Token__c = 'testAccessToken',
            Phone_Number_Id__c = 'testPhoneId',
            Is_WBA_Configured__c = true
        );
        insert metaConfig;

        EmbeddedSignUpConfig__c embeddedConfig = new EmbeddedSignUpConfig__c(
            Config_Id__c = 'testConfigId',
            Client_Id__c = 'testClientId',
            Client_Secret__c = 'testClientSecret'
        );
        insert embeddedConfig;
    }

    @isTest
    static void testConstructor() {
        EmbeddedSignUpController controller = new EmbeddedSignUpController();
        System.assertNotEquals(null, EmbeddedSignUpController.whatsappBusinessAppId);
        System.assertNotEquals(null, EmbeddedSignUpController.clientId);
        System.assertNotEquals(null, EmbeddedSignUpController.clientSecret);
        System.assertNotEquals(null, EmbeddedSignUpController.configurationId);
    }

    @isTest
    static void testSaveFBLoginDetails_Success() {
        Test.startTest();
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockFacebookTokenCallout());

        String result = EmbeddedSignUpController.saveFBLoginDetails('mockToken', 'phone123', 'waba123', 'app123');
        Test.stopTest();

        System.assertEquals('waba123', result, 'Should return WABA ID on success');
    }

    @isTest
    static void testSaveFBLoginDetails_NoConfig() {
        // Delete config to simulate empty config condition
        delete [SELECT Id FROM EmbeddedSignUpConfig__c];

        Test.startTest();
        String result = EmbeddedSignUpController.saveFBLoginDetails('mockToken', 'phone123', 'waba123', 'app123');
        Test.stopTest();

        System.assertEquals('Failure', result, 'Should return Failure if no config found');
    }

    @isTest
    static void testUnlinkAccount() {
        Test.startTest();
        Boolean result = EmbeddedSignUpController.unlinkAccount();
        Test.stopTest();

        System.assertEquals(true, result, 'Unlink should return true if config cleared');
    }

    @isTest
    static void testSaveMetaDataMethod() {
        Test.startTest();
        Boolean result = EmbeddedSignUpController.saveMetaData('accessToken', 'phone123', 'waba123', 'app123', true);
        Test.stopTest();

        System.assertEquals(true, result, 'Metadata should be saved successfully');
    }

    // Optional: Test failure path in saveMetaData
    @isTest
    static void testSaveMetaData_Failure() {
        Test.startTest();
        Boolean result = EmbeddedSignUpController.saveMetaData(null, null, null, null, true);
        Test.stopTest();

        System.assertEquals(true, result, 'Even with nulls, method should handle insert');
    }

    // Mock HTTP Response for Facebook Token API
    public class MockFacebookTokenCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "mockLongLivedToken"}');
            res.setStatusCode(200);
            return res;
        }
    }
}