@RestResource(urlMapping='/drivers/*')
global with sharing class RaceWebServiceREST {

    @HttpGet
    global static List<Driver__c> getOldestDrivers() {
        return [
            SELECT Id, 
            Full_Name__c, 
            Age__c
            FROM Driver__c
            ORDER BY Age__c DESC
            LIMIT 5
        ];
    }
}

