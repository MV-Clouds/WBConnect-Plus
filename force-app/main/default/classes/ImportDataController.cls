public with sharing class ImportDataController {

    public static String userAccountId = WhatsAppWebhook.getUserAccount();

    @AuraEnabled
    public static void insertContacts(List<Map<String, String>> conDataList) {
        List<WBConnect_Contact__c> contactsToInsert = new List<WBConnect_Contact__c>();

        for (Map<String, String> conData : conDataList) {
            String name = conData.get('Name');
            String phone = conData.get('Phone');

            if (String.isBlank(name) || String.isBlank(phone)) continue;

            WBConnect_Contact__c con = new WBConnect_Contact__c();
            con.Name = name;
            con.Phone__c = phone;
            con.Account__c = userAccountId;
            contactsToInsert.add(con);
        }

        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
}