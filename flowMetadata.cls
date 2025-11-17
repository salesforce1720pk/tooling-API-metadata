public class MetadataController {

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getFlowDefinitions() {
        Map<String, String> flowMap = new Map<String, String>();

        try {
            //make the endpoint
            String toolingUrl = URL.getOrgDomainUrl().toExternalForm()+'/services/data/v65.0/tooling/query/?q=' + EncodingUtil.urlEncode('SELECT Id, DeveloperName, LatestVersionId FROM FlowDefinition','UTF-8');

            HttpRequest req = new HttpRequest();
            req.setEndpoint(toolingUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + 'YOUR_ACCESS_TOKEN');
            req.setHeader('Content-Type', 'application/json');

            // Send Callout
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                // Parse JSON
                Map<String, Object> outerJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> records = (List<Object>) outerJson.get('records');

                // Loop through FlowDefinition records
                for (Object recObj : records) {
                    Map<String, Object> rec = (Map<String, Object>) recObj;

                    String devName = (String) rec.get('DeveloperName');
                    String latestVid = (String) rec.get('LatestVersionId');

                    flowMap.put(devName, latestVid);
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        return flowMap; 
    }

    /*----------------------Flow------------------------------*/
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getFlowDetails(String flowVersionId) {
        Map<String, String> detailsMap = new Map<String, String>();

        try {
            // Build endpoint
            String url = URL.getOrgDomainUrl().toExternalForm()+'/services/data/v65.0/tooling/sobjects/Flow/'+flowVersionId;

            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + 'YOUR_ACCESS_TOKEN');
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                Map<String, Object> jsonBody = 
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                // Extract only the required fields
                detailsMap.put('MasterLabel', (String) jsonBody.get('MasterLabel'));
                detailsMap.put('Status', (String) jsonBody.get('Status'));
                detailsMap.put('Description', (String) jsonBody.get('Description'));
                detailsMap.put('ProcessType', (String) jsonBody.get('ProcessType'));
            }
        } catch (Exception e) {
            System.debug('Error fetching flow details: ' + e.getMessage());
        }
        System.debug(detailsMap);
        return detailsMap;
    }
}
