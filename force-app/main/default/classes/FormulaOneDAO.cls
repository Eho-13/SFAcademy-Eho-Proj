public class FormulaOneDAO {
    // test driverid = a027Q0000061zcxQAA for Hadgehoc, Sonic
    public static Driver__c getDriver(Id driverId){
        return Database.query('SELECT Age__c, CreatedById, Name, First_Name__c, Full_Name__c, Hat_Tricks__c, Is_Qualified__c, LastModifiedById, Last_Name__c, OwnerId FROM Driver__c WHERE Id = \'' + driverId + '\'');
    }
    
    public static List<Race_Result__c> getRaceResults(Id driverId){
         return Database.query('SELECT CreatedById, Grand_Prix__c, Grid__c, Is_Fastest_Lap__c, LastModifiedById, Position__c, Name, Racer__c FROM Race_Result__c where Racer__c = \'' + driverId + '\'');
    }
    
    public static set<String> getDriverCircuits(Id driverId){
        List<sObject> qrez = new List<sObject>{
            Database.query('SELECT Grand_Prix__r.Name FROM Race_Result__c WHERE Racer__c = \'' + driverId + '\'')
                };   
        set<String> rezSet = new set<String>();
        for(sObject tempObj: qrez){
            rezSet.add(String.valueOf(tempOBj.get('Grand_Prix__r.Name')));
        }
        return rezSet;
    }
    public static Driver__c getYoungestDriverOnRace(Id raceId){
        //SELECT Name, Age__C FROM Driver__c WHERE 
		//Id IN (SELECT winer__c FROM Race__c WHERE id = 'a007Q00000BTRTbQAP') OR
		//Id IN (SELECT Podium_Second__c FROM Race__c WHERE id = 'a007Q00000BTRTbQAP') OR
		//Id IN (SELECT Podium_Third__c FROM Race__c WHERE id = 'a007Q00000BTRTbQAP')
		//ORDER BY Age__c
        //list<sObject> driversOnRace = new list<Object>{};
      
        //SELECT  Winer__r.Age__c, Podium_Second__r.Age__c, Podium_Third__r.Age__c FROM Race__c WHERE id = 'a007Q00000BTRTbQAP'
      
        return [SELECT Name, Age__C FROM Driver__c 
                WHERE Id IN (SELECT Racer__c FROM Race_Result__c WHERE Grand_Prix__c = :raceId) 
                ORDER BY Age__c 
                LIMIT 1];
    }
    
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
    }
}