public with sharing class FormulaOneDAO {
    // test driverid = a027Q0000061zcxQAA for Hadgehoc, Sonic
    public static Driver__c getDriver(Id driverId){
        return [SELECT Age__c, CreatedById, Name, First_Name__c, Full_Name__c, Hat_Tricks__c, Is_Qualified__c, LastModifiedById, Last_Name__c, OwnerId FROM Driver__c WHERE Id = :driverId];
    }
    

    public static List<Race_Result__c> getRaceResults(Id driverId){
         return [SELECT CreatedById, Grand_Prix__c, Grid__c, Is_Fastest_Lap__c, LastModifiedById, Position__c, Name, Racer__c FROM Race_Result__c where Racer__c = :driverId];
    }

    
    public static set<String> getDriverCircuits(Id driverId){
 		List<Race_Result__c> qResults = [SELECT Grand_Prix__r.Name FROM Race_Result__c WHERE Racer__c = :driverId];
        Set<String> resultNamesSet = new Set<String>();
        
        for (Race_Result__c r: qResults) {
            resultNamesSet.add(r.Grand_Prix__r.Name);
        }

        return resultNamesSet;

    }
     
    public static Driver__c getYoungestDriverOnRace(Id raceId){
        return [SELECT Name, Age__C FROM Driver__c  
                WHERE Id IN 
               (SELECT Racer__c FROM Race_Result__c 
                WHERE Grand_Prix__c = :raceId) 
                ORDER BY Age__c LIMIT 1];
    }
    
   
    public static Map<String, List<String>> getAllDriversByCircuit(){
        Map<String, list<String>> AllDriversByCircuit = new Map<String, list<String>>();
        List<Race_Result__c> raceRezList =[SELECT Grand_Prix__r.Name, Racer__r.Name FROM Race_Result__c];
        
        For(Race_Result__c tempRaceRez: raceRezList){
            if(AllDriversByCircuit.containsKey(tempRaceRez.Grand_Prix__r.Name)){
                AllDriversByCircuit.get(tempRaceRez.Grand_Prix__r.Name).add(tempRaceRez.Racer__r.Name);
            } else {
                AllDriversByCircuit.put(tempRaceRez.Grand_Prix__r.Name, new List<String>{tempRaceRez.Racer__r.Name});
            }
        }
       
        return AllDriversByCircuit;
    }
    /* Old version
   public Map<String, List<String>> getAllDriversByCircuit(){
        Map<String, list<String>> AllDriversByCircuit = new Map<String, list<String>>();
        List<sObject> raceRezList = new List<sObject>{
            Database.query('SELECT Grand_Prix__r.Name, Racer__r.Name FROM Race_Result__c ORDER BY Grand_Prix__r.Name')
                };
        
        String oldRaceName = String.valueOf(raceRezList[0].get('Grand_Prix__r.Name'));
		String newRaceName = oldRaceName;
		List<String> curRaceDrivers = new List<String>();
        For(sObject tempRaceRez: raceRezList){

			
            if(oldRaceName == newRaceName){
                curRaceDrivers.add(String.valueOf(tempRaceRez.get('Racer__r.Name')));
            } else {
                AllDriversByCircuit.put(oldRaceName, curRaceDrivers);
				oldRaceName = newRaceName;
				curRaceDrivers.clear();
                curRaceDrivers.add(String.valueOf(tempRaceRez.get('Racer__r.Name')));
            }
            newRaceName = String.valueOf(tempRaceRez.get('Grand_Prix__r.Name'));
        }
        
        AllDriversByCircuit.put(oldRaceName, curRaceDrivers);
        return AllDriversByCircuit;
    }*/

}