@isTest 
private class FormulaOneServicesTest {

@TestSetup
    static void dataSetup(){
      //  TestDataFactory.createTestData();
          
      List<Race__c> racesList = new List<Race__c>();
      List<Driver__c> driversList = new List<Driver__c>();
  
      for (Integer i = 0; i==6; i++) {
          driversList.add(new Driver__c(
              First_Name__c = 'First_name_' + i,
              Last_Name__c = 'Last_name_' + i,
              Age__c = i + 17
          ));
      }       
   
      racesList.add(new Race__c(        
          Name = 'Grond_prix_name_1',
          Track__c = 'AVUS',
          Date__c = Date.newInstance(2022, 10, 19),
          Laps__c  =  3,
          Status__c = 'Active'
      ));
      racesList.add(new Race__c(        
          Name = 'Grond_prix_name_2',
          Track__c = 'Circuit de Monaco',
          Date__c = Date.newInstance(2022, 01, 05),
          Laps__c  =  5,
          Status__c = 'Completed'
      ));
      racesList.add(new Race__c(        
          Name = 'Grond_prix_name_3',
          Track__c = 'Mosport Park', 
          Date__c = Date.newInstance(2023, 06, 03),
          Laps__c  =  7,
          Status__c = 'Active'
      ));
      racesList.add(new Race__c(        
          Name = 'Grond_prix_name_4',
          Track__c = 'Nurburgring',
          Date__c = Date.newInstance(2099, 01, 01),
          Laps__c  =  1 ,
          Status__c =  'Completed'
      ));
          
      insert driversList;
      insert racesList;


        
      List<Id> drvsId = new List<Id>(new Map<Id, Driver__c>([SELECT id FROM Driver__c]).keySet());
 	  List<Id> rcsId = new List<Id>(new Map<Id, Race__c>([SELECT id FROM Race__c]).keySet());
     
      List<Race_Result__c> raceResultsList = new List<Race_Result__c>();

      For(Id r: rcsId){
          integer driverPosition = 1;
          Boolean fastestLap = true;
          for (id d : drvsId) {
              raceResultsList.add(new Race_Result__c(
                  Grand_Prix__c = r,
                  Grid__c = driverPosition,                    
                  Is_Fastest_Lap__c = fastestLap,
                  Position__c = driverPosition,
                  // Name = String.valueOf(d + '_' + driverPosition),
                  Racer__c = d
              ));
              fastestLap = false;
              driverPosition++;
          }
      }
      insert raceResultsList;
    }

    @isTest 
    static void generateKeyTest() {
        //sObject testsObj = new sObject();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String objectName='Race__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(ObjectName).getDescribe().fields.getMap();

        List<sObjectField> testFieldsList = new list<SObjectField>();
        testFieldsList.add(fieldMap.get('Name'));
        testFieldsList.add(fieldMap.get('Track__c'));
        
        Race__c testsObj = [SELECT Name,Track__c FROM Race__c LIMIT 1];

        string expectedResult = 'Grond_prix_name_1---AVUS';

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
        Driver__c queryDriver = [SELECT id, First_Name__c, Last_Name__c FROM Driver__c LIMIT 1];

        Test.startTest();
        Driver__c testDriver = FormulaOneServices.updateDriverName(queryDriver.Id, newDriver.First_Name__c, newDriver.Last_Name__c);
        Test.stopTest();

        System.assertEquals(queryDriver.Id, testDriver.Id,
        					'FormulaOneServices.updateDriverNameTest id TEST FAILURE');
        System.assertEquals(newDriver.First_Name__c, testDriver.First_Name__c,
        					'FormulaOneServices.updateDriverNameTest First_Name__c TEST FAILURE');
        System.assertEquals(newDriver.Last_Name__c, testDriver.Last_Name__c,
        					'FormulaOneServices.updateDriverNameTest Last_Name__c TEST FAILURE');
    }
    

}