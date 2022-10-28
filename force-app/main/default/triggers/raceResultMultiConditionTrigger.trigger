trigger raceResultMultiConditionTrigger on Race_Result__c(
  before insert,
  before update,
  after insert,
  after update
) {
  switch on Trigger.operationType {
    when BEFORE_INSERT, BEFORE_UPDATE {
      raceResultMultiConditionTriggerHandler.driverPositionCheck(Trigger.new);
    }
    when AFTER_INSERT, AFTER_UPDATE {
      raceResultMultiConditionTriggerHandler.driverHatTricksUpd(Trigger.new);
    }
    when AFTER_DELETE {
      raceResultMultiConditionTriggerHandler.driverHatTricksUpd(Trigger.old);
    }
    when else {
      System.debug('raceResultMultiConditionTrigger ERROR');
    }
  }
}