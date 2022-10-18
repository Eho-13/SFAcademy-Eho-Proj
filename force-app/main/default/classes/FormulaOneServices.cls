public class FormulaOneServices {
    public String generateKey (SObject record, List<SObjectField> fields, String separator){

        List<String> stringFields = new List<String>();
        for(SObjectField tempfield: fields){
           stringFields.add(
            (string) record.get(tempfield)
        );
        }
		
        string key;
        for(String s: stringFields){
            Key = Key + separator + s;
        }
        
        return Key; 
    }
    
    public static Boolean isHatTrick(Race_Result__c raceResult){
    	return (raceResult.Position__c == 1 && raceResult.Grid__c == 1 && raceResult.Is_Fastest_Lap__c);
    }

    Public static void createDriver(String firstName, String lastName, Integer age){
        Driver__c drv = new Driver__c();
        
        drv.First_Name__c = firstName;
        drv.Last_Name__c = lastName;
        drv.Age__C = age;

        try {
            insert drv;
        } catch(DmlException e) {
            System.debug('FormulaOneServices.createDriver metod err: ' + e.getMessage());
        }
    }

    Public static void createDrivers(List<DriverDTO> drivers){
        list<Driver__c> drvList = new List<Driver__c>();

        for(DriverDTO d: drivers){
            
            Driver__c drv = new Driver__c();
            drv.First_Name__c = d.firstName;
            drv.Last_Name__c = d.lastName;
            drv.Age__c = d.age;
            
            //Driver__c drv = new Driver__c(d.firstName, d.lastName, d.age); //Запитати чи це корректна форма передачі?
            drvList.add(drv);
            //drvList.add(new Driver__c(d.firstName, d.lastName, d.age)); // теж варіант
        }
        try {
            insert drvList;
        } catch(DmlException e) {
            System.debug('FormulaOneServices.createDrivers metod err: ' + e.getMessage());
        }
    }

    Public static Driver__c updateDriverName(id driverId, String newFirstName, String newLastName){
        Driver__c drv = [SELECT Id, First_Name__c, Last_Name__c FROM Driver__c WHERE Id = :driverId LIMIT 1];
        drv.First_Name__c = newFirstName;
        drv.Last_Name__c = newLastName;

        try {
            update drv;
        } catch(DmlException e) {
            System.debug('FormulaOneServices.updateDriverName metod err: ' + e.getMessage());
        }
        
        return drv;
    } 

    Public static List<Race__c> updateGrandPrixWinners(Set<Id> raceIds){
        list<Race__c> racesCorrection = new List<Race__c>();
        list<Race__c> races = [SELECT winer__c, Podium_Second__c, Podium_Third__c FROM Race__c where id IN :raceIds];
        list<Race_Result__c> drivers = [SELECT Grand_Prix__c, Position__c, Racer__c FROM Race_Result__c WHERE Grand_Prix__c IN :raceIds AND Position__c <= 3];    
/*
Можна спробувати через один запит як варіант
[SELECT Racer__c, Position__c, Grand_Prix__r.Winner__c, Grand_Prix__r.Podium_Second__c, Grand_Prix__r.Podium_Third__c
FROM Race_Result__c WHERE Grand_Prix__r.Id IN :raceIds AND Position__c <= 3]
*/
        For(Race_Result__c drv: drivers){
            For(Race__c race: races){
                if(race.id == drv.Grand_Prix__c){
                    switch on drv.Position__c.intValue(){
                        when 1 {
                            race.winer__c = drv.Racer__c;
                        }
                        when 2 {
                            race.Podium_Second__c = drv.Racer__c;
                        }
                        when 3 {
                            race.Podium_Third__c = drv.Racer__c;
                        }
                        when else {
                            System.debug('FormulaOneServices.updateGrandPrixWinners SOME Racer__C.Position__c ERROR');
                        }
                    }
                    racesCorrection.add(race);
                }
            }
        }
        if(!racesCorrection.isEmpty()){
            try {
                update racesCorrection;
            } catch(DmlException e) {
                System.debug('FormulaOneServices.updateGrandPrixWinners metod err: ' + e.getMessage());
            }
        }
        return racesCorrection;
    }

}