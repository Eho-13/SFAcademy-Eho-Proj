public class raceResultMultiConditionTriggerHandler {
  //NB! Race Results можуть бути(і БУДУТЬ) списком!!!

  //Hat Tricks field should be up to date on the Driver.
  //Hat Trick means that driver got Race Result with the fastest lap and the 1st position.
  public static void driverHatTricksUpd(
    List<Race_Result__c> triggeredRaceResults
  ) {
    Set<String> allTriggeredDriversId = new Set<String>();
    list<sObject> driversHadHatTrick = new List<sObject>();
    list<Driver__C> drivers2UpDate = new List<Driver__C>();

    for (Race_Result__c r : triggeredRaceResults) {
      allTriggeredDriversId.add(r.Racer__c);
    }

    /*driversHadHatTrick = [SELECT Racer__r.id, Racer__r.Hat_tricks__c 
                              FROM Race_Result__C 
                              WHERE Is_Fastest_Lap__c = True AND Position__c = 1 AND Grand_Prix__c 
                              IN :allTriggeredDriversId];*/

    driversHadHatTrick = [
      SELECT Racer__r.id, Count(name) hatTricksCounter
      FROM Race_Result__C
      WHERE
        Is_Fastest_Lap__c = TRUE
        AND Position__c = 1
        AND Racer__r.id IN :allTriggeredDriversId
      GROUP BY Racer__r.id
    ];

    for (sObject d : driversHadHatTrick) {
      Driver__C tempDriver = new Driver__C();
      tempDriver.id = String.valueOf(d.get('id'));
      tempDriver.Hat_Tricks__c = Integer.valueOf(d.get('hatTricksCounter'));
      drivers2UpDate.add(tempDriver);
    }

    if (!drivers2UpDate.isEmpty()) {
      try {
        update drivers2UpDate;
      } catch (DmlException e) {
        System.debug(
          'raceResultMultiConditionTriggerHandler.driverHatTricksUpd trigger err: ' +
          e.getMessage()
        );
      }
    }
  }

  //For the given Race there can't be more than one Race Result with the same Racer or Position.
  public static void driverPositionCheck(
    List<Race_Result__c> triggeredRaceResults
  ) {
    Set<String> allTriggeredDriversId = new Set<String>();
    list<Race_Result__c> allTriggeredRaces = new List<Race_Result__c>();
    Map<String, List<Race_Result__c>> raceAndResultsMap = new Map<String, List<Race_Result__c>>();

    System.debug(
      '---driverPositionCheck.triggeredRaceResults' + triggeredRaceResults
    );
    for (Race_Result__c r : triggeredRaceResults) {
      allTriggeredDriversId.add(r.Grand_Prix__c);
    }
    System.debug(
      '---driverPositionCheck.allTriggeredDriversId' + allTriggeredDriversId
    );
    allTriggeredRaces = [
      SELECT Grand_Prix__r.Name, Racer__r.Name, Position__c
      FROM Race_Result__c
      WHERE Grand_Prix__c IN :allTriggeredDriversId
    ];
    // i spend 4 hours to add this check!
    if (allTriggeredRaces.isEmpty()) {
      allTriggeredRaces = triggeredRaceResults;
    }

    for (Race_Result__c r : allTriggeredRaces) {
      if (raceAndResultsMap.containsKey(r.Grand_Prix__c)) {
        raceAndResultsMap.get(r.Grand_Prix__c).add(r);
      } else {
        raceAndResultsMap.put(r.Grand_Prix__c, new List<Race_Result__c>{ r });
      }
    }

    for (Race_Result__c inRR : triggeredRaceResults) {
      for (Race_Result__c curRR : raceAndResultsMap.get(inRR.Grand_Prix__c)) {
        if (inRR.Position__c == curRR.Position__c && inRR.Id != curRR.Id) {
          inRR.addError(
            'Where two or more drivers at this one position in the current race!'
          );
        }

        if (inRR.Racer__c == curRR.Racer__c && inRR.Id != curRR.Id) {
          inRR.addError(
            'This driver already participated in this race but it has a different position!'
          );
        }
      }
    }
  }
}
