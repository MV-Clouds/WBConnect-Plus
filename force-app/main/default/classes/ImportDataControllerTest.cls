@isTest
public class ImportDataControllerTest {

    @testSetup
    static void setup() {
        // If WhatsAppWebhook.getUserAccount() depends on something, set that up here
        // Otherwise, assume it returns a valid account Id like '001...'
    }

    @isTest
    static void testInsertContacts_ValidData() {
        List<Map<String, String>> conDataList = new List<Map<String, String>>{
            new Map<String, String>{'Name' => 'Test User 1', 'Phone' => '1234567890'},
            new Map<String, String>{'Name' => 'Test User 2', 'Phone' => '0987654321'}
        };

        Test.startTest();
        ImportDataController.insertContacts(conDataList);
        Test.stopTest();

        List<WBConnect_Contact__c> inserted = [
            SELECT Id, Name, Phone__c FROM WBConnect_Contact__c WHERE Name IN ('Test User 1', 'Test User 2')
        ];
        System.assertEquals(2, inserted.size(), 'Two contacts should be inserted');
    }

    @isTest
    static void testInsertContacts_BlankValues() {
        List<Map<String, String>> conDataList = new List<Map<String, String>>{
            new Map<String, String>{'Name' => '', 'Phone' => '123'},
            new Map<String, String>{'Name' => 'John', 'Phone' => ''},
            new Map<String, String>{'Name' => '', 'Phone' => ''}
        };

        Test.startTest();
        ImportDataController.insertContacts(conDataList);
        Test.stopTest();

        // Should not insert any records
        List<WBConnect_Contact__c> inserted = [SELECT Id FROM WBConnect_Contact__c];
        System.assertEquals(0, inserted.size(), 'No contacts should be inserted due to blank fields');
    }

    @isTest
    static void testInsertContacts_EmptyList() {
        List<Map<String, String>> emptyList = new List<Map<String, String>>();

        Test.startTest();
        ImportDataController.insertContacts(emptyList);
        Test.stopTest();

        // Should not insert any records
        List<WBConnect_Contact__c> inserted = [SELECT Id FROM WBConnect_Contact__c];
        System.assertEquals(0, inserted.size(), 'No contacts should be inserted from empty list');
    }
}