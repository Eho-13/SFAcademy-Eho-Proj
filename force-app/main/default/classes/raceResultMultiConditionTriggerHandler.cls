public class raceResultMultiConditionTriggerHandler {
    //NB! Race Results можуть бути(і БУДУТЬ) списком!!! 

    //Hat Tricks field should be up to date on the Driver. 
    //Hat Trick means that driver got Race Result with the fastest lap and the 1st position.
	public static void driverHatTricksUpd(List<Race_Result__c> triggeredRaceResults) {
        Set<String> allTriggeredRacesId = new Set<String>();
        list<sObject> driversHadHatTrick = new list<sObject>();

        for(Race_Result__c r: triggeredRaceResults){
            allTriggeredRacesId.add(r.Grand_Prix__c);
        }

        //ПИТАННЯ 1
        /*  SELECT Racer__r.id, Racer__r.Hat_tricks__c , Racer__r.Hat_tricks__c+1 incrementedHatTricks
            FROM Race_Result__C 
            WHERE Is_Fastest_Lap__c = True AND Position__c = 1 AND Grand_Prix__c 
            IN :allTriggeredRacesId];*/
        //ПИТАННЯ 2
        //list<Driver__c> driversHadHatTrick

        driversHadHatTrick = [SELECT Racer__r.id, Racer__r.Hat_tricks__c 
                              FROM Race_Result__C 
                              WHERE Is_Fastest_Lap__c = True AND Position__c = 1 AND Grand_Prix__c 
                              IN :allTriggeredRacesId];

        list<Driver__C> drivers2UpDate = new list<Driver__C>();

        for(sObject d: driversHadHatTrick){
            Driver__C tempDriver = new Driver__C();
            tempDriver.id = d.Id;
            tempDriver.Hat_Tricks__c = Integer.valueOf(d.get('Hat_tricks__c'))  + 1 ;
            drivers2UpDate.add(tempDriver);
        }

        if(!drivers2UpDate.isEmpty()){
            try {
                update drivers2UpDate;
            } catch(DmlException e) {
                System.debug('raceResultMultiConditionTriggerHandler.driverHatTricksUpd trigger err: ' + e.getMessage());
            }
        }
    }


    //For the given Race there can't be more than one Race Result with the same Racer or Position.
    public static void driverPositionCheck(List<Race_Result__c> triggeredRaceResults) {
        Set<String> allTriggeredRacesId = new Set<String>();
        list<Race_Result__c> allTriggeredRaces = new list<Race_Result__c>();
        Map<String, List<Race_Result__c>> raceAndResultsMap = new Map<String, List<Race_Result__c>>();

        for(Race_Result__c r: triggeredRaceResults){
            allTriggeredRacesId.add(r.Grand_Prix__c);
        }

        allTriggeredRaces = [SELECT Grand_Prix__r.Name, Racer__r.Name, Position__c
                             FROM Race_Result__c 
                             WHERE Grand_Prix__c IN :allTriggeredRacesId];

        for(Race_Result__c r: allTriggeredRaces) {
            if (raceAndResultsMap.containsKey(r.Grand_Prix__c)) {
                raceAndResultsMap.get(r.Grand_Prix__c).add(r);
            } else {
                raceAndResultsMap.put(r.Grand_Prix__c, new List<Race_Result__c>{r});
            }
        }

        for(Race_Result__c tRR: triggeredRaceResults) {
            for (Race_Result__c rMap: raceAndResultsMap.get(tRR.Grand_Prix__c)) {
                
                if(tRR.Position__c == rMap.Position__c && tRR.Id != rMap.Id) {
                    System.debug('raceResultMultiConditionTriggerHandler.driverPositionCheck ERROR:' + 
                    ' There two or more drivers at one position is race' + 
                    String.valueOf(rMap.get('Grand_Prix__r.Name')));
                }

                if(tRR.Racer__c == rMap.Racer__c && tRR.Id != rMap.Id) {
                    System.debug('raceResultMultiConditionTriggerHandler.driverPositionCheck ERROR:' + 
                    ' In this Race driver ' + String.valueOf(rMap.get('Racer__c.Name')) +
                    ' at two diferend positions');            
                }
            }
        }
    }
}