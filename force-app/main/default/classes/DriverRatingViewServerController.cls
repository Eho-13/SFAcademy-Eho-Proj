public class DriverRatingViewServerController {
  @AuraEnabled
  public static List<Driver__c> getDriversRatingServerMethod() {
    return [
      SELECT Id, Full_Name__c, Hat_Tricks__c, Age__c, Is_Qualified__c
      FROM Driver__c
      ORDER BY Hat_Tricks__c DESC
      LIMIT 5
    ];
  }
}
