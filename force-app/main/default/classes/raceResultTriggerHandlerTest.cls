@isTest
private class raceResultTriggerHandlerTest{
    @testSetup
    static void dataSetup(){     
        
      List<Driver__c> driversList = new List<Driver__c>();
     /* for (Integer i = 0; i==6; i++) {
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
     
      insert racesList;
        
      List<Id> drvsId = new List<Id>(new Map<Id, Driver__c>([SELECT id FROM Driver__c OFFSET 1]).keySet());
      List<Id> rcsId = new List<Id>(new Map<Id, Race__c>([SELECT id FROM Race__c]).keySet());
     
      List<Race_Result__c> raceResultsList = new List<Race_Result__c>();
      For(Id r: rcsId){
          if(r != NULL){
              integer driverPosition = 2;
              Boolean fastestLap = false;
              for (id d : drvsId) {
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

 
      insert new Driver__c(
        First_Name__c = 'Test_HatTricks',
        Last_Name__c = 'Driver',
        Age__c =  22,
        Hat_Tricks__c = 0,
        Is_Qualified__c = True);
      
    }
    
    @isTest
    static void driverHatTricksUpd(){
        Race__c race = [SELECT id FROM Race__c LIMIT 1];
        id raceId = race.id;
        Driver__c driver = [SELECT id FROM Driver__c WHERE First_Name__c = 'Test_HatTricks' LIMIT 1];
        Id driverId = driver.Id;

        Driver__c oldDriver = [SELECT id, Hat_Tricks__c FROM Driver__c WHERE id = :driverId];
        Decimal oldHatTricks = oldDriver.Hat_Tricks__c;

        Race_Result__c insertRaceResult = new Race_Result__c(
            Racer__c = driverId,
            Grand_Prix__c = raceId,
            Position__c = 1,
            Is_Fastest_Lap__c = true
        );
        Test.startTest();
        Upsert insertRaceResult;
        Test.stopTest();

        Decimal expectedHatTricks = oldHatTricks + 1;
        Driver__c newDriver = [SELECT id, Hat_Tricks__c FROM Driver__c WHERE id = :driverId];
        Decimal actualHatTricks = newDriver.Hat_Tricks__c;

        System.assertEquals(expectedHatTricks, actualHatTricks, 
        					'raceResultTriggerHandlerTest.driverHatTricksUpd Hat_Tricks__c TEST FAILURE');

    }
    
    @isTest
    static void driverPositionCheck(){
    
    }
    
}