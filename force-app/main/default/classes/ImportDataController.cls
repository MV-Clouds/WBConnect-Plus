public with sharing class ImportDataController {
    @AuraEnabled
    public static void insertLeads(List<Map<String, String>> leadDataList) {
        List<Lead> leadsToInsert = new List<Lead>();

        for (Map<String, String> leadData : leadDataList) {
            String name = leadData.get('Name');
            String phone = leadData.get('Phone');

            if (String.isBlank(name) || String.isBlank(phone)) continue;

            Lead ld = new Lead();
            ld.LastName = name;
            ld.Company = name;
            ld.Phone = phone;
            ld.Status = 'Open';
            ld.User__c = UserInfo.getUserId();
            leadsToInsert.add(ld);
        }

        if (!leadsToInsert.isEmpty()) {
            insert leadsToInsert;
        }
    }
}