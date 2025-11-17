# Tooling API Metadata

## File : triggerValidation
This file contains three methods: 
- Get the object : This will show all the objects of org
- Get validation Rule on an object : All vlidation rule written on object
- Get Trigger on an object : All triggers written on an object

### Method: Get all the objects
``` apex
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectList() {
        List<String> objects = new List<String>();
        Map<String, Schema.SObjectType> globalDesc = Schema.getGlobalDescribe();

        for (String objName : globalDesc.keySet()) {
            Schema.DescribeSObjectResult describe = globalDesc.get(objName).getDescribe();
            if (!describe.isCustomSetting()) {
                objects.add(describe.getName());
            }
        }

        objects.sort();
        return objects;
    }
```

### Method: To get Validation Rule on an object
``` apex
@AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getTriggers(String objectName) {

        if (String.isBlank(objectName)) {
            return new List<Map<String, String>>();
        }

        String soql = 'SELECT Name, Status FROM ApexTrigger WHERE TableEnumOrId = \'' + objectName + '\'';
        String encoded = EncodingUtil.urlEncode(soql, 'UTF-8');

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String endpoint = baseUrl + '/services/data/v61.0/tooling/query/?q=' + encoded;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + 'YOUR_ACCESS_TOKEN');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> records = (List<Object>) jsonMap.get('records');

        List<Map<String, String>> resultList = new List<Map<String, String>>();

        for (Object rec : records) {
            Map<String, Object> recMap = (Map<String, Object>) rec;

            Map<String, String> row = new Map<String, String>();
            row.put('Name', (String) recMap.get('Name'));
            row.put('Status', (String) recMap.get('Status'));

            resultList.add(row);
        }

        return resultList;
    }
```
### Method: To get Trigger on an object
``` apex
@AuraEnabled(cacheable=false)
    public static List<Map<String, String>> validationMetadata(String objectName) {

        List<Map<String, String>> resultList = new List<Map<String, String>>();

        if (String.isBlank(objectName)) {
            return resultList;
        }

        try {
            String soql = 'SELECT Id, Active, Description, ErrorMessage, ValidationName ' +
                          'FROM ValidationRule ' +
                          'WHERE EntityDefinition.QualifiedApiName = \'' + objectName + '\'';

            String encoded = EncodingUtil.urlEncode(soql, 'UTF-8');

            String baseUrl = URL.getOrgDomainUrl().toExternalForm();
            String endpoint = baseUrl + '/services/data/v61.0/tooling/query/?q=' + encoded;

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + 'YOUR_ACCESS_TOKEN');
            req.setHeader('Content-Type', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) jsonMap.get('records');

            for (Object obj : records) {
                Map<String, Object> temp = (Map<String, Object>) obj;

                Map<String, String> row = new Map<String, String>();
                row.put('Name', (String) temp.get('ValidationName'));
                row.put('Status', String.valueOf(temp.get('Active')));
                row.put('Description', (String) temp.get('Description'));
                row.put('ErrorMessage', (String) temp.get('ErrorMessage'));

                resultList.add(row);
            }
        }
        catch (Exception e) {
            System.debug('Validation Exception: ' + e.getMessage());
        }

        return resultList;
    }
```
