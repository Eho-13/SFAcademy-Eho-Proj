@isTest 
private class FormulaOneServicesTest {

@TestSetup
    static void dataSetup(){     
        
      List<Driver__c> driversList = new List<Driver__c>();
     /* for (Integer i = 0; i>=6; i++) {
          driversList.add(new Driver__c(
              First_Name__c = 'Test_' + i,
              Last_Name__c = 'Driver_' + i,
              Age__c = i + 19
          ));
      }  */
      driversList.add(new Driver__c(
          First_Name__c = 'Test_1',
          Last_Name__c = 'Driver_1',
          Age__c =  20,
          Hat_Tricks__c = 0,
          Is_Qualified__c = True));
     driversList.add(new Driver__c(
          First_Name__c = 'Test_2',
          Last_Name__c = 'Driver_2',
          Age__c =  19,
          Hat_Tricks__c = 0,
          Is_Qualified__c = True));
     driversList.add(new Driver__c(
          First_Name__c = 'Test_3',
          Last_Name__c = 'Driver_3',
          Age__c =  35,
          Hat_Tricks__c = 0,
          Is_Qualified__c = True));
    driversList.add(new Driver__c(
          First_Name__c = 'Test_4',
          Last_Name__c = 'Driver_4',
          Age__c =  33,
          Hat_Tricks__c = 0,
          Is_Qualified__c = True));
/*    driversList.add(new Driver__c(
          First_Name__c = 'Test_5',
          Last_Name__c = 'Driver_5',
          Age__c =  23,
          Hat_Tricks__c = 0,
          Is_Qualified__c = True));
    driversList.add(new Driver__c(
          First_Name__c = 'Test_6',
          Last_Name__c = 'Driver_6',
          Age__c =  22,
          Hat_Tricks__c = 0,
          Is_Qualified__c = True));*/
      insert driversList;
        
   	  List<Race__c> racesList = new List<Race__c>();
      racesList.add(new Race__c(        
          Name = 'Grond_prix_name_1',
          Track__c = 'AVUS',
          Date__c = Date.newInstance(2022, 10, 19),
          Laps__c  =  3,
          Status__c = 'Active'));
      racesList.add(new Race__c(        
          Name = 'Grond_prix_name_2',
          Track__c = 'Circuit de Monaco',
          Date__c = Date.newInstance(2022, 01, 05),
          Laps__c  =  5,
          Status__c = 'Completed'));
      racesList.add(new Race__c(        
          Name = 'Grond_prix_name_3',
          Track__c = 'Mosport Park', 
          Date__c = Date.newInstance(2023, 06, 03),
          Laps__c  =  7,
          Status__c = 'Active'));
      racesList.add(new Race__c(        
          Name = 'Grond_prix_name_4',
          Track__c = 'Nurburgring',
          Date__c = Date.newInstance(2099, 01, 01),
          Laps__c  =  1 ,
          Status__c =  'Completed'));
      insert racesList;
        
      List<Id> drvsId = new List<Id>(new Map<Id, Driver__c>([SELECT id FROM Driver__c]).keySet());
 	  List<Id> rcsId = new List<Id>(new Map<Id, Race__c>([SELECT id FROM Race__c]).keySet());
     
      List<Race_Result__c> raceResultsList = new List<Race_Result__c>();
      For(Id r: rcsId){
          if(r != NULL){
              Integer driverPosition = 1;
              Boolean fastestLap = true;
              for (Id d : drvsId) {
                  raceResultsList.add(new Race_Result__c(
                      Grand_Prix__c = r,
                      Grid__c = driverPosition,                    
                      Is_Fastest_Lap__c = fastestLap,
                      Position__c = driverPosition,
                      // Name = String.valueOf(d + '_' + driverPosition),
                      Racer__c = d
                  ));
                  
                  System.debug('Race-(' + r + ') Position-' + driverPosition + ' Driver-[' + d + ']');
                  fastestLap = false;
                  driverPosition++;
              }
          }
      }
	System.debug(raceResultsList);
      insert raceResultsList;
    }

    @isTest 
    static void generateKeyTest() {
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String objectName='Driver__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(ObjectName).getDescribe().fields.getMap();

        List<sObjectField> testFieldsList = new list<SObjectField>();
        testFieldsList.add(fieldMap.get('First_Name__c'));
        testFieldsList.add(fieldMap.get('Last_Name__c'));
		testFieldsList.add(fieldMap.get('Age__c'));
        
        Driver__c testsObj = [SELECT First_Name__c, Last_Name__c, Age__c FROM Driver__c LIMIT 1];

        string expectedResult = 'Test_1---Driver_1---20';

        Test.startTest();
            String testResult = FormulaOneServices.generateKey(testsObj, testFieldsList, '---');
        Test.stopTest();

        System.assertEquals(expectedResult, testResult, 'FormulaOneServices.generateKey TEST FAILURE');
    }

    @isTest
    static void isHatTrickTest(){
       // List<Race_Result__c> raceResultRecords = [SELECT Position__c, Grid__c, Is_Fastest_Lap__c FROM Race_Result__c LIMIT 2];
      //  System.debug(records[1] + records[2]);
        Race_Result__c correctRaceResult = new Race_Result__c(
            Position__c = 1, Grid__c = 1, Is_Fastest_Lap__c = true);
        Race_Result__c failRaceResult = new Race_Result__c(
            Position__c = 2, Grid__c = 2, Is_Fastest_Lap__c = false);

        Test.startTest();
        Boolean resultTrue = FormulaOneServices.isHatTrick(correctRaceResult);
        Boolean resultFalse = FormulaOneServices.isHatTrick(failRaceResult);
        Test.stopTest();

        System.assertEquals(true, resultTrue, 
                            'FormulaOneServices.isHatTrickTest TEST FAILURE');
        System.assertEquals(false, resultFalse, 
                            'FormulaOneServices.isHatTrickTest NEGATIVE TEST FAILURE');


    }
    
    @isTest
    static void createDriverTest() {
        Driver__c newDriver = new Driver__c(
            First_Name__c='Test', Last_Name__c='Driver', Age__c = 19);

        Test.startTest();
        FormulaOneServices.createDriver(
            String.valueOf(newDriver.First_Name__c), 
            String.valueOf(newDriver.Last_Name__c), 
            Integer.valueOf(newDriver.Age__c));
        Test.stopTest();

        Driver__c queryDriver = [SELECT Id, First_Name__c, Last_Name__c, Age__c FROM Driver__c 
            WHERE First_Name__c=: newDriver.First_Name__c 
            AND Last_Name__c=: newDriver.Last_Name__c 
            AND Age__c=: newDriver.Age__c
            LIMIT 1];

        System.assertEquals(newDriver.First_Name__c, queryDriver.First_Name__c, 
        					'FormulaOneServices.createDriverTest First_Name__c TEST FAILURE');
        System.assertEquals(newDriver.Last_Name__c , queryDriver.Last_Name__c, 
        					'FormulaOneServices.createDriverTest Last_Name__c TEST FAILURE');
        System.assertEquals(newDriver.Age__c, queryDriver.Age__c, 
        					'FormulaOneServices.createDriverTest Age__c TEST FAILURE');
    }

    @isTest
    static void createDriversTest() {
       Driver__c newDriver = new Driver__c(
            First_Name__c='Test', Last_Name__c='Driver_DTO', Age__c = 19);
        
        List<DriverDTO> drivers = new List<DriverDTO>();
        drivers.add(new DriverDTO(
         	String.valueOf(newDriver.First_Name__c) + '_1', 
            String.valueOf(newDriver.Last_Name__c), 
            Integer.valueOf(newDriver.Age__c+1)));
        
        drivers.add(new DriverDTO(
         	String.valueOf(newDriver.First_Name__c) + '_2', 
            String.valueOf(newDriver.Last_Name__c), 
            Integer.valueOf(newDriver.Age__c)));
        
        
        Test.startTest();
        FormulaOneServices.createDrivers(drivers);
        Test.stopTest();

        List <Driver__c> queryDrivers = [
            SELECT First_Name__c, Last_Name__c, Age__c FROM Driver__c
            WHERE Last_Name__c='Driver_DTO'];

        System.assertEquals(2, queryDrivers.size(), 
        					'FormulaOneServices.createDriversTest size TEST FAILURE');
/*		System.Assert.areEqual(drivers, queryDrivers, 
        					'FormulaOneServices.createDriversTest objects TEST FAILURE');
*/
        System.assertEquals(drivers.get(1).firstName, queryDrivers.get(1).First_Name__c, 
        					'FormulaOneServices.createDriversTest First_Name__c TEST FAILURE');
        System.assertEquals(drivers.get(1).lastName, queryDrivers.get(1).Last_Name__c, 
        					'FormulaOneServices.createDriversTest Last_Name__c TEST FAILURE');
        System.assertEquals(drivers.get(1).age, queryDrivers.get(1).Age__c, 
        					'FormulaOneServices.createDriversTest Age__c TEST FAILURE');
       
    }
    
     @isTest
     static void updateDriverNameTest() {
 		Driver__c newDriver = new Driver__c(
        First_Name__c='Test', Last_Name__c='Driver');
        Driver__c[] queryDriver = [SELECT id, First_Name__c, Last_Name__c FROM Driver__c LIMIT 1];
      	String qDriverId;
         if (queryDriver.size() > 0){
             qDriverId = queryDriver[0].Id;
         }
		
         
        Test.startTest();
        Driver__c testDriver = FormulaOneServices.updateDriverName(qDriverId, newDriver.First_Name__c, newDriver.Last_Name__c);
        Test.stopTest();

        System.assertEquals(qDriverId, testDriver.Id,
        					'FormulaOneServices.updateDriverNameTest id TEST FAILURE');
        System.assertEquals(newDriver.First_Name__c, testDriver.First_Name__c,
        					'FormulaOneServices.updateDriverNameTest First_Name__c TEST FAILURE');
        System.assertEquals(newDriver.Last_Name__c, testDriver.Last_Name__c,
        					'FormulaOneServices.updateDriverNameTest Last_Name__c TEST FAILURE');
    }
    
      @isTest
    static void updateGrandPrixWinnersTest() {
        Map<Id, Race__c> racesAndWinnersMap = new Map<Id, Race__c>([SELECT Id, (
            SELECT Racer__r.Id, Position__c 
            FROM Racing_Results__r
            WHERE Position__c <= 3
            ORDER BY Position__c) FROM Race__c]);
/*        
        set<id> raceIds = new Set()[SELECT Grand_Prix__r.id FROM Race_Result__c WHERE Position__c <= 3];
		list<Race__c> races = [SELECT winer__c, Podium_Second__c, Podium_Third__c FROM Race__c where id IN :raceIds];
        list<Race_Result__c> drivers = [SELECT Grand_Prix__c, Position__c, Racer__c FROM Race_Result__c WHERE Grand_Prix__c IN :raceIds AND Position__c <= 3]
*/
        Test.startTest();
        List<Race__c> testRaces = FormulaOneServices.updateGrandPrixWinners(racesAndWinnersMap.keySet());
        Test.stopTest();

        Set<Id> racesIds = new Set<Id>();
        for (Race__c r: racesAndWinnersMap.values()) {
            for (Race__c t: testRaces) {
                if (r.Id == t.Id) {
                    racesIds.add(r.Id);
					List<Race_Result__c> raceResult = r.Racing_Results__r;
                    
                    System.assertEquals(raceResult.get(0).Racer__c, t.Winer__c,
                                        'FormulaOneServices.updateGrandPrixWinnersTest Winer__c TEST FAILURE');
                    System.assertEquals(raceResult.get(1).Racer__c, t.Podium_Second__c,
                                        'FormulaOneServices.updateGrandPrixWinnersTest Podium_Second__c TEST FAILURE');
                    System.assertEquals(raceResult.get(2).Racer__c, t.Podium_Third__c,
                                        'FormulaOneServices.updateGrandPrixWinnersTest Podium_Third__c TEST FAILURE');
                }
            }
        }

        System.assertEquals(racesIds, racesAndWinnersMap.keySet(),
        					'FormulaOneServices.updateGrandPrixWinnersTest ID-SET TEST FAILURE');
    }

}