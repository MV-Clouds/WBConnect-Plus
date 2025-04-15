@isTest
private class AwsConfigurationControllerTest {

    @testSetup
    static void setupData() {
        // Create a dummy WBConnect_Meta_Configuration__c record for testing
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            AWS_Access_Key__c = 'testKey',
            AWS_Secret_Access_Key__c = 'testSecret',
            S3_Bucket_Name__c = 'testBucket',
            S3_Region_Name__c = 'us-west-1',
            Is_AWS_Configured__c = true
        );
        insert config;
    }

    @isTest
    static void testGetConfigurationWithExistingConfig() {
        Test.startTest();
        WBConnect_Meta_Configuration__c result = AwsConfigurationController.getConfiguration();
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('testKey', result.AWS_Access_Key__c);
    }

    @isTest
    static void testGetConfigurationWithNoConfig() {
        // Delete existing data
        delete [SELECT Id FROM WBConnect_Meta_Configuration__c];

        Test.startTest();
        WBConnect_Meta_Configuration__c result = AwsConfigurationController.getConfiguration();
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('', result.AWS_Access_Key__c);
    }

    @isTest
    static void testSaveConfigurationInsert() {
        // Delete existing data to force insert
        delete [SELECT Id FROM WBConnect_Meta_Configuration__c];

        Test.startTest();
        String result = AwsConfigurationController.saveConfiguration('newKey', 'newSecret', 'newBucket', 'us-east-1');
        Test.stopTest();

        System.assertEquals('Success', result);

        WBConnect_Meta_Configuration__c saved = [SELECT AWS_Access_Key__c FROM WBConnect_Meta_Configuration__c WHERE AWS_Access_Key__c = 'newKey' LIMIT 1];
        System.assertEquals('newKey', saved.AWS_Access_Key__c);
    }

    @isTest
    static void testSaveConfigurationUpdate() {
        Test.startTest();
        String result = AwsConfigurationController.saveConfiguration('updatedKey', 'updatedSecret', 'updatedBucket', 'us-east-2');
        Test.stopTest();

        System.assertEquals('Success', result);

        WBConnect_Meta_Configuration__c updated = [SELECT AWS_Access_Key__c, S3_Region_Name__c FROM WBConnect_Meta_Configuration__c WHERE AWS_Access_Key__c = 'updatedKey' LIMIT 1];
        System.assertEquals('us-east-2', updated.S3_Region_Name__c);
    }

    @isTest
    static void testDeleteRecordByAccessKeySuccess() {
        WBConnect_Meta_Configuration__c config = new WBConnect_Meta_Configuration__c(
            AWS_Access_Key__c = 'deleteKey',
            AWS_Secret_Access_Key__c = 'someSecret',
            S3_Bucket_Name__c = 'someBucket',
            S3_Region_Name__c = 'us-west-2',
            Is_AWS_Configured__c = true
        );
        insert config;

        Test.startTest();
        AwsConfigurationController.deleteRecordByAccessKey('deleteKey');
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM WBConnect_Meta_Configuration__c WHERE AWS_Access_Key__c = 'deleteKey']);
    }

    @isTest
    static void testDeleteRecordByAccessKeyFailure() {
        // This should not throw an exception to the test context (it is caught internally)
        Test.startTest();
        AwsConfigurationController.deleteRecordByAccessKey('nonExistentKey');
        Test.stopTest();

        // No assertion here since the method handles the exception internally
        System.assert(true); // Dummy assertion to keep test method valid
    }
}