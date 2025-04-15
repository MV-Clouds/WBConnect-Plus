@isTest
private class WhatsAppConfigurationControllerTest {

    @isTest
    static void testGetConfigurationWithExistingConfig() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create a dummy configuration record
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'test_token',
            Phone_Number_Id__c = '123456789',
            Application_Id__c = 'app_id',
            Business_Account_Id__c = 'biz_id',
            Is_WBA_Configured__c = true,
            Account__c = acc.Id // Fake Account ID
        );
        insert config;

        Test.startTest();
        WBConnect_Meta_Configuration__c result = WhatsAppConfigurationController.getConfiguration();
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('test_token', result.Access_Token__c);
    }

    @isTest
    static void testGetConfigurationWithoutExistingConfig() {
        // No config inserted

        Test.startTest();
        WBConnect_Meta_Configuration__c result = WhatsAppConfigurationController.getConfiguration();
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('', result.Access_Token__c);
        System.assertEquals(false, result.Is_WBA_Configured__c);
    }

    @isTest
    static void testSaveConfigurationInsert() {
        // No existing configuration - should insert

        Test.startTest();
        String result = WhatsAppConfigurationController.saveConfiguration('biz_acc_1', 'app_1', 'token_1', 'phone_1');
        Test.stopTest();

        System.assertEquals('Success', result);

        List<WBConnect_Meta_Configuration__c> configs = [SELECT Id, Access_Token__c, Phone_Number_Id__c FROM WBConnect_Meta_Configuration__c];
        System.assertEquals(1, configs.size());
        System.assertEquals('token_1', configs[0].Access_Token__c);
    }

    @isTest
    static void testSaveConfigurationUpdate() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Insert an existing config to be updated
        WBConnect_Meta_Configuration__c existing = new WBConnect_Meta_Configuration__c(
            Access_Token__c = 'old_token',
            Phone_Number_Id__c = 'old_phone',
            Application_Id__c = 'old_app',
            Business_Account_Id__c = 'old_biz',
            Is_WBA_Configured__c = true,
            Account__c = acc.Id
        );
        insert existing;

        Test.startTest();
        String result = WhatsAppConfigurationController.saveConfiguration('new_biz', 'new_app', 'new_token', 'new_phone');
        Test.stopTest();

        System.assertEquals('Success', result);

        WBConnect_Meta_Configuration__c updated = [SELECT Access_Token__c, Phone_Number_Id__c, Application_Id__c, Business_Account_Id__c FROM WBConnect_Meta_Configuration__c WHERE Id = :existing.Id];
        System.assertEquals('new_token', updated.Access_Token__c);
        System.assertEquals('new_phone', updated.Phone_Number_Id__c);
        System.assertEquals('new_app', updated.Application_Id__c);
        System.assertEquals('new_biz', updated.Business_Account_Id__c);
    }
}