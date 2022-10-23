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

    //Треба зробити метод для перевірки вхідних значень для DriverDTO
    
    Public static void createDriver(String firstName, String lastName, Integer age){
        DriverDTO curDriver = new DriverDTO(firstName, lastName, age);
        
        if(DriverDTO.isDriverFieldsNotEmpty(curDriver)){
            Driver__c drv = new Driver__c();
        
            drv = new Driver__c(First_Name__c = firstName, Last_Name__c = lastName, Age__c = age);

            try {
                insert drv;
            } catch(DmlException e) {
                System.debug('FormulaOneServices.createDriver metod err: ' + e.getMessage());
            }
        }
    }

    Public static void createDrivers(List<DriverDTO> drivers){
        list<Driver__c> drvList = new List<Driver__c>();

        for(DriverDTO d: drivers){
            /* //Видалити після тестування
            Driver__c drv = new Driver__c();
            drv.First_Name__c = d.firstName;
            drv.Last_Name__c = d.lastName;
            drv.Age__c = d.age;
            drvList.add(drv);
            */
            if(DriverDTO.isDriverFieldsNotEmpty(d)){
                drvList.add(new Driver__c(First_Name__c = d.firstName, Last_Name__c = d.lastName, Age__c = d.age));
            }
           
        }
        try {
            insert drvList;
        } catch(DmlException e) {
            System.debug('FormulaOneServices.createDrivers metod err: ' + e.getMessage());
        }
    }

    Public static Driver__c updateDriverName(id driverId, String newFirstName, String newLastName){
        Driver__c drv = new Driver__c();
        //Зайвий запит
        /*Driver__c drv = [SELECT Id, First_Name__c, Last_Name__c FROM Driver__c WHERE Id = :driverId LIMIT 1];
        drv.First_Name__c = newFirstName;
        drv.Last_Name__c = newLastName;*/
        // Додав перевірку на НЕпорожні параметри
        if(driverId != NULL && newFirstName != NULL && newLastName != NULL){
            drv = new Driver__c(id = driverId, First_Name__c = newFirstName, Last_Name__c = newLastName);
        
            try {
                update drv;
            } catch(DmlException e) {
                System.debug('FormulaOneServices.updateDriverName update metod err: ' + e.getMessage());
            }

        } else{
            System.debug('FormulaOneServices.updateDriverName one or more parametrs is blank');
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

        try {
            update racesCorrection;
        } catch(DmlException e) {
            System.debug('FormulaOneServices.updateGrandPrixWinners metod err: ' + e.getMessage());
        }

        return racesCorrection;
    }

}