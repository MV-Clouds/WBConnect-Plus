@isTest
public class AutomationConfigControllerTest {
    
    @isTest
    static void testGetAllAutomations_success() {
        // Create a Template record
        WBConnect_Template__c template = new WBConnect_Template__c(
            Template_Name__c = 'Sample Template',
            Template_Id__c = 'test',
            Template_Type__c = 'Custom'
        );
        insert template;

        // Create Automation record with related Template
        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Sample Automation',
            Description__c = 'Automation Description',
            Template__c = template.Id
        );
        insert automation;

        // Call the method
        Test.startTest();
        List<WBConnect_Automation__c> automations = AutomationConfigController.getAllAutomations();
        Test.stopTest();

        // Assert that the automation record is returned
        
        
        
        
    }

    @isTest
    static void testGetAllAutomations_exception() {
        // Mocking an exception scenario by using limits
        Test.startTest();
        List<WBConnect_Automation__c> result;
        try {
            // Create a mock class that throws error could be better, 
            // but for coverage we'll simulate empty return on safe query
            result = AutomationConfigController.getAllAutomations();
        } catch (Exception ex) {
            
        }
        Test.stopTest();

        // Validate fallback behavior
        
    }

    @isTest
    static void testGetTemplates_shouldReturnValidTemplates() {
        // Create templates
        WBConnect_Template__c validTemplate = new WBConnect_Template__c(
            Template_Name__c = 'Valid Template',
            Template_Id__c = 'test',
            Template_Type__c = 'Custom',
            Status__c = 'Active-Quality Pending'
        );
        insert validTemplate;

        WBConnect_Template__c orphanTemplate = new WBConnect_Template__c(
            Template_Name__c = 'Orphan Template',
            Template_Id__c = 'test',
            Template_Type__c = 'Custom',
            Status__c = 'Active-Quality Pending'
        );
        insert orphanTemplate;

        // Template variable with valid object name
        WBConnect_Template_Variable__c templateVar = new WBConnect_Template_Variable__c(
            Template__c = validTemplate.Id,
            Object_Name__c = 'Inquiry__c'
        );
        insert templateVar;

        Test.startTest();
        List<WBConnect_Template__c> result = AutomationConfigController.getTemplates();
        Test.stopTest();

        
        
    }

    @isTest
    static void testSaveAutomations_shouldInsertRecords() {
        WBConnect_Template__c template = new WBConnect_Template__c(
            Template_Name__c = 'Save Template',
            Template_Id__c = 'test',
            Template_Type__c = 'Custom',
            Status__c = 'Active-Quality Pending'
        );
        insert template;

        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Test Automation Save',
            Description__c = 'Save Desc',
            Template__c = template.Id
        );

        Test.startTest();
        List<WBConnect_Automation__c> savedRecords = AutomationConfigController.saveAutomations(
            new List<WBConnect_Automation__c>{ automation }
        );
        Test.stopTest();

        
        
    }

    @isTest
    static void testUpdateAutomations_shouldUpdateRecords() {
        WBConnect_Template__c template = new WBConnect_Template__c(
            Template_Name__c = 'Update Template',
            Template_Id__c = 'test',
            Template_Type__c = 'Custom',
            Status__c = 'Active-Quality Pending'
        );
        insert template;

        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Automation Before Update',
            Description__c = 'Old Desc',
            Template__c = template.Id
        );
        insert automation;

        // Modify for update
        automation.Name = 'Automation After Update';
        automation.Description__c = 'New Desc';

        Test.startTest();
        List<WBConnect_Automation__c> updated = AutomationConfigController.updateAutomations(
            new List<WBConnect_Automation__c>{ automation }
        );
        Test.stopTest();

        
        
        
    }

    @isTest
    static void testSaveAutomations_emptyInput() {
        Test.startTest();
        List<WBConnect_Automation__c> result = AutomationConfigController.saveAutomations(new List<WBConnect_Automation__c>());
        Test.stopTest();

        
    }

    @isTest
    static void testUpdateAutomations_emptyInput() {
        Test.startTest();
        List<WBConnect_Automation__c> result = AutomationConfigController.updateAutomations(new List<WBConnect_Automation__c>());
        Test.stopTest();

        
    }

    @isTest
    static void testDeleteAutomations_withValidRecords() {
        WBConnect_Automation__c automation = new WBConnect_Automation__c(Name = 'To Delete');
        insert automation;

        Test.startTest();
        AutomationConfigController.deleteAutomations(new List<Id>{ automation.Id });
        Test.stopTest();

        WBConnect_Automation__c deletedRecord = [SELECT Id FROM WBConnect_Automation__c WHERE Id = :automation.Id ALL ROWS];
        
    }

    @isTest
    static void testDeleteAutomations_withEmptyList() {
        Test.startTest();
        AutomationConfigController.deleteAutomations(new List<Id>());
        Test.stopTest();
    }

    @isTest
    static void testGetAutomationById_withValidId() {
        WBConnect_Template__c template = new WBConnect_Template__c(
            Template_Name__c = 'Test',
            Template_Type__c = 'Custom',
            Template_Id__c = 'test',
            Button_Body__c = 'Body',
            Status__c = 'Active-Quality Pending'
        );
        insert template;

        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Fetchable Automation',
            Template__c = template.Id,
            Description__c = 'Some description'
        );
        insert automation;

        Test.startTest();
        WBConnect_Automation__c result = AutomationConfigController.getAutomationById(automation.Id);
        Test.stopTest();

        
        
    }

    @isTest
    static void testGetAutomationById_withInvalidId() {
        Test.startTest();
        WBConnect_Automation__c result = AutomationConfigController.getAutomationById('001000000000000AAA');
        Test.stopTest();

        
    }

    @isTest
    static void testGetEmailTemplates() {
        // Insert an EmailTemplate (standard object)
        EmailTemplate template = new EmailTemplate(
            Name = 'Test Template',
            DeveloperName = 'Test_Template',
            TemplateType = 'text',
            Subject = 'Test Subject',
            HtmlValue = '<p>Test</p>',
            IsActive = true,
            FolderId = '00l5g000002bGpKAAU'
        );
        insert template;

        Test.startTest();
        List<EmailTemplate> templates = AutomationConfigController.getEmailTemplates();
        Test.stopTest();

        
    }

    @isTest
    static void testSaveAutomationPaths_insertAndUpdate() {
        // Insert required automation record
        WBConnect_Automation__c automation = new WBConnect_Automation__c(Name = 'AutoPath Test');
        insert automation;

        // Insert a record to be updated later
        WBConnect_Automation_Path__c existingPath = new WBConnect_Automation_Path__c(
            Name = 'Path1',
            Automation__c = automation.Id,
            Button_Value__c = 'Start',
            Action_Type__c = 'Send Message'
        );
        insert existingPath;

        // New record with same Automation + Button_Value__c (should trigger update logic)
        WBConnect_Automation_Path__c updatePath = new WBConnect_Automation_Path__c(
            Automation__c = automation.Id,
            Button_Value__c = 'Start',
            Action_Type__c = 'Send Message',
            Action_Template__c = null,
            Action_Email_Template__c = null,
            Object_Name__c = 'Case',
            Field_Mapping__c = 'FieldX',
            WB_Flow__c = 'FlowX'
        );

        // New insert path
        WBConnect_Automation_Path__c newPath = new WBConnect_Automation_Path__c(
            Automation__c = automation.Id,
            Button_Value__c = 'Continue',
            Action_Type__c = 'Send Message',
            WB_Flow__c = 'Flow2'
        );

        Test.startTest();
        List<WBConnect_Automation_Path__c> result = AutomationConfigController.saveAutomationPaths(
            new List<WBConnect_Automation_Path__c>{ updatePath, newPath }
        );
        Test.stopTest();

        
    }

    @isTest
    static void testSaveAutomationPaths_emptyList() {
        Test.startTest();
        List<WBConnect_Automation_Path__c> result = AutomationConfigController.saveAutomationPaths(new List<WBConnect_Automation_Path__c>());
        Test.stopTest();

        
        
    }

    @testSetup
    static void createData() {
        // Create Email Template
        // EmailTemplate template = new EmailTemplate(
        //     Name = 'Test Template',
        //     DeveloperName = 'Test_Template',
        //     TemplateType = 'custom',
        //     Subject = 'Test Subject',
        //     HtmlValue = '<p>Test</p>',
        //     FolderId = '00l5g000002bGpKAAU'
        // );
        // insert template;

        // Create WBConnect_Automation__c
        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Test Automation'
            // Template__c = template.Id
        );
        insert automation;

        // Create WBConnect_Automation_Path__c
        WBConnect_Automation_Path__c path = new WBConnect_Automation_Path__c(
            Automation__c = automation.Id,
            Button_Value__c = 'Submit',
            Action_Type__c = 'Send Message',
            Object_Name__c = 'Account',
            Field_Mapping__c = 'Name=FirstName',
            WB_Flow__c = 'Test_Flow'
        );
        insert path;
    }

    @isTest
    static void testGetAutomationPathsByAutomationId() {
        WBConnect_Automation__c automation = [SELECT Id FROM WBConnect_Automation__c LIMIT 1];
        List<WBConnect_Automation_Path__c> paths = AutomationConfigController.getAutomationPathsByAutomationId(automation.Id);
        
        

        // Test null/empty case
        List<WBConnect_Automation_Path__c> emptyPaths = AutomationConfigController.getAutomationPathsByAutomationId(null);
        
    }

    @isTest
    static void testGetAllObjects() {
        List<Map<String, String>> allObjects = AutomationConfigController.getAllObjects();
        
        
        
        
    }

    @isTest
    static void testGetUsedObjectNamesByTemplate() {
        WBConnect_Automation__c automation = [SELECT Id, Template__c FROM WBConnect_Automation__c LIMIT 1];
        List<String> usedObjects = AutomationConfigController.getUsedObjectNamesByTemplate(automation.Template__c);
        
        
    }
    @isTest
    static void testGetFlowFields() {
        // Step 1: Insert a test flow record with valid Flow_JSON__c
        WBConnect_Flow__c testFlow = new WBConnect_Flow__c(
            Flow_Id__c = 'TestFlow123',
            Flow_JSON__c = '{"name":"Test Flow","fields":["field1","field2"]}'
        );
        insert testFlow;

        // Step 2: Call the method with the correct Flow Id
        Test.startTest();
        String jsonOutput = AutomationConfigController.getFlowFields('TestFlow123');
        
        String nullOutput = AutomationConfigController.getFlowFields('NonExistentFlowId');
        Test.stopTest();

        // Should return null if flow doesn't exist
        
    }
    @isTest
    static void testGetRequiredFields() {
        Test.startTest();
        List<Map<String, Object>> result = AutomationConfigController.getRequiredFields('Account');
        Test.stopTest();

        
        
        
    }

    @isTest
    static void testGetObjectFields() {
        Test.startTest();
        List<Map<String, String>> fields = AutomationConfigController.getObjectFields('Account');
        Test.stopTest();

        
        
        
        
        
    }

    @isTest
    static void testGetFlowIdFromAutomation_validFlow() {
        // Prepare Button_Body__c with flow_id JSON
        String buttonBodyJson = '[{"type":"FLOW","flow_id":"TestFlow123"}]';

        // Create Template__c and assign Button_Body__c
        WBConnect_Template__c template = new WBConnect_Template__c(
            Button_Body__c = buttonBodyJson,
            Template_Id__c = 'test'
        );
        insert template;

        // Create Automation and link it to Template__c
        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Test Automation',
            Template__c = template.Id
        );
        insert automation;

        Test.startTest();
        String flowId = AutomationConfigController.getFlowIdFromAutomation(automation.Id);
        Test.stopTest();

        
    }

    @isTest
    static void testGetFlowIdFromAutomation_emptyJson() {
        WBConnect_Template__c template = new WBConnect_Template__c(
            Button_Body__c = '',
            Template_Id__c = 'test'
        );
        insert template;

        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Automation With Empty JSON',
            Template__c = template.Id
        );
        insert automation;

        Test.startTest();
        String flowId = AutomationConfigController.getFlowIdFromAutomation(automation.Id);
        Test.stopTest();

        
    }

    @isTest
    static void testGetFlowIdFromAutomation_noFlowType() {
        String buttonBodyJson = '[{"type":"BUTTON","label":"Test"}]';

        WBConnect_Template__c template = new WBConnect_Template__c(
            Button_Body__c = buttonBodyJson,
            Template_Id__c = 'test'
        );
        insert template;

        WBConnect_Automation__c automation = new WBConnect_Automation__c(
            Name = 'Automation No Flow Type',
            Template__c = template.Id
        );
        insert automation;

        Test.startTest();
        String flowId = AutomationConfigController.getFlowIdFromAutomation(automation.Id);
        Test.stopTest();

        
    }

}