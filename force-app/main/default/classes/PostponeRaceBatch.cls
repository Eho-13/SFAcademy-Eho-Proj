public class PostponeRaceBatch implements Database.Batchable<sObject>, Database.Stateful {
  public List<String> racesID = new List<String>();

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [SELECT id, Date__c FROM Race__c WHERE Status__c = 'Active']
    );
  }

  public void execute(Database.BatchableContext cd, List<Race__c> scope) {
    for (Race__c race : scope) {
      race.Date__c = race.Date__c.addMonths(1);
      racesID.add(race.id);
    }

    update scope;
  }

  public void finish(Database.BatchableContext bc) {
    String body =
      'PostponeRaceBatch is Done job. List Race Ids: ' +
      String.join(racesID, ',');

    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    String[] sendingTo = new List<String>{ 'nrg.xiii@gmail.com' };
    semail.setToAddresses(sendingTo);
    semail.setSubject('PostponeRaceBatch');
    semail.setPlainTextBody(body);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ semail });

    System.debug(body);
  }
}
