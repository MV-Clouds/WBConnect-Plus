public without sharing class FileDownloadController {
    public String fileContentType { get; set; }
    public Blob fileDownload { get; set; }
    List<WBConnect_Meta_Configuration__c> configList = [SELECT Id, AWS_Access_Key__c, AWS_Secret_Access_Key__c, S3_Bucket_Name__c, S3_Region_Name__c FROM WBConnect_Meta_Configuration__c WHERE Is_AWS_Configured__c = true LIMIT 1];

    public FileDownloadController() {
        String fileName = ApexPages.currentPage().getParameters().get('fileName');
        
        if (String.isBlank(fileName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing file name'));
            return;
        }

        try {
            // AWS Config
            List<WBConnect_Meta_Configuration__c> configList = [SELECT Id, AWS_Access_Key__c, AWS_Secret_Access_Key__c, S3_Bucket_Name__c, S3_Region_Name__c FROM WBConnect_Meta_Configuration__c WHERE Is_AWS_Configured__c = true LIMIT 1];
            if (!configList.isEmpty()) {
                WBConnect_Meta_Configuration__c configData = configList[0];
                String bucketName = configData.S3_Bucket_Name__c;
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://' + bucketName + '.s3.amazonaws.com/' + fileName);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
    
                if (response.getStatusCode() == 200) {
                    fileDownload = response.getBodyAsBlob();
                    ApexPages.currentPage().getHeaders().put('Content-Disposition', 'attachment; filename="' + fileName + '"');
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to download file from AWS'));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'AWS Configuration is not found'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e.getMessage()));
        }
    }
}