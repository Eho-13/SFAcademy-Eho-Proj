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
        List<Race_Result__c> raceResultRecords = [SELECT Position__c, Grid__c, Is_Fastest_Lap__c FROM Race_Result__c LIMIT 2];
      //  System.debug(records[1] + records[2]);
       /* Race_Result__c correctRaceResult = new Race_Result__c(
            Position__c = 1, Grid__c = 1, Is_Fastest_Lap__c = true);
        Race_Result__c correctRaceResult = new Race_Result__c(
            Position__c = 2, Grid__c = 2, Is_Fastest_Lap__c = false);*/

        Test.startTest();
        Boolean resultTrue = FormulaOneServices.isHatTrick(records.get(0));
        Boolean resultFalse = FormulaOneServices.isHatTrick(records.get(1));
        Test.stopTest();

        System.assertEquals(true, resultTrue, 'FormulaOneServices.isHatTrickTest TEST FAILURE');
        System.assertEquals(false, resultFalse, 'FormulaOneServices.isHatTrickTest NEGATIVE TEST FAILURE');

    }

}