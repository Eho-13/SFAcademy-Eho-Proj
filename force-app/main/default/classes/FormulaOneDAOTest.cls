@isTest
private class FormulaOneDAOTest {
  @testSetup
  static void dataSetup() {
    List<Driver__c> driversList = new List<Driver__c>();
    /* for (Integer i = 0; i==6; i++) {
          driversList.add(new Driver__c(
              First_Name__c = 'Test_' + i,
              Last_Name__c = 'Driver_' + i,
              Age__c = i + 19
          ));
      }  */
    driversList.add(
      new Driver__c(
        First_Name__c = 'Test_1',
        Last_Name__c = 'Driver_1',
        Age__c = 20,
        Hat_Tricks__c = 0,
        Is_Qualified__c = true
      )
    );
    driversList.add(
      new Driver__c(
        First_Name__c = 'Test_2',
        Last_Name__c = 'Driver_2',
        Age__c = 19,
        Hat_Tricks__c = 0,
        Is_Qualified__c = true
      )
    );
    driversList.add(
      new Driver__c(
        First_Name__c = 'Test_3',
        Last_Name__c = 'Driver_3',
        Age__c = 35,
        Hat_Tricks__c = 0,
        Is_Qualified__c = true
      )
    );
    driversList.add(
      new Driver__c(
        First_Name__c = 'Test_4',
        Last_Name__c = 'Driver_4',
        Age__c = 33,
        Hat_Tricks__c = 0,
        Is_Qualified__c = true
      )
    );
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
    racesList.add(
      new Race__c(
        Name = 'Grond_prix_name_1',
        Track__c = 'AVUS',
        Date__c = Date.newInstance(2022, 10, 19),
        Laps__c = 3,
        Status__c = 'Active'
      )
    );
    racesList.add(
      new Race__c(
        Name = 'Grond_prix_name_2',
        Track__c = 'Circuit de Monaco',
        Date__c = Date.newInstance(2022, 1, 5),
        Laps__c = 5,
        Status__c = 'Completed'
      )
    );
    racesList.add(
      new Race__c(
        Name = 'Grond_prix_name_3',
        Track__c = 'Mosport Park',
        Date__c = Date.newInstance(2023, 6, 3),
        Laps__c = 7,
        Status__c = 'Active'
      )
    );
    racesList.add(
      new Race__c(
        Name = 'Grond_prix_name_4',
        Track__c = 'Nurburgring',
        Date__c = Date.newInstance(2099, 1, 1),
        Laps__c = 1,
        Status__c = 'Completed'
      )
    );
    insert racesList;

    List<Id> drvsId = new List<Id>(
      new Map<Id, Driver__c>([SELECT id FROM Driver__c]).keySet()
    );
    List<Id> rcsId = new List<Id>(
      new Map<Id, Race__c>([SELECT id FROM Race__c]).keySet()
    );

    List<Race_Result__c> raceResultsList = new List<Race_Result__c>();
    for (Id r : rcsId) {
      if (r != null) {
        integer driverPosition = 1;
        Boolean fastestLap = true;
        for (id d : drvsId) {
          raceResultsList.add(
            new Race_Result__c(
              Grand_Prix__c = r,
              Grid__c = driverPosition,
              Is_Fastest_Lap__c = fastestLap,
              Position__c = driverPosition,
              // Name = String.valueOf(d + '_' + driverPosition),
              Racer__c = d
            )
          );

          System.debug(
            'Race-(' +
            r +
            ') Position-' +
            driverPosition +
            ' Driver-[' +
            d +
            ']'
          );
          fastestLap = false;
          driverPosition++;
        }
      }
    }
    System.debug(raceResultsList);
    insert raceResultsList;
  }
  @isTest
  static void getDriverTest() {
    Driver__c qDriver = [
      SELECT
        id,
        Age__c,
        CreatedById,
        Name,
        First_Name__c,
        Full_Name__c,
        Hat_Tricks__c,
        Is_Qualified__c,
        LastModifiedById,
        Last_Name__c,
        OwnerId
      FROM Driver__c
      LIMIT 1
    ];
    test.startTest();
    Driver__c testDriver = FormulaOneDAO.getDriver(qDriver.id);
    test.stopTest();

    System.assertEquals(
      qDriver,
      testDriver,
      'FormulaOneDAOTest.getDriverTest TEST FAILURE'
    );
  }

  @isTest
  static void getRaceResultsTest() {
    Driver__c qDriver = [SELECT id FROM Driver__c LIMIT 1];
    List<Race_Result__c> expectedRaces = [
      SELECT
        CreatedById,
        Grand_Prix__c,
        Grid__c,
        Is_Fastest_Lap__c,
        LastModifiedById,
        Position__c,
        Name,
        Racer__c
      FROM Race_Result__c
      WHERE Racer__c = :qDriver.id
    ];

    test.startTest();
    List<Race_Result__c> testRaceResults = FormulaOneDAO.getRaceResults(
      qDriver.id
    );
    test.stopTest();

    System.assertEquals(
      expectedRaces,
      testRaceResults,
      'FormulaOneDAOTest.getRaceResultsTest TEST FAILURE'
    );
  }

  @isTest
  static void getDriverCircuitsTest() {
    Driver__c qDriver = [
      SELECT Id, (SELECT Name, Grand_Prix__r.Name FROM Racing_Results__r)
      FROM Driver__c
      LIMIT 1
    ];

    Set<String> expectedDriverCircuits = new Set<String>();
    for (Race_Result__c r : qDriver.Racing_Results__r) {
      expectedDriverCircuits.add(r.Grand_Prix__r.Name);
    }

    Test.startTest();
    Set<String> testDriverCircuits = FormulaOneDAO.getDriverCircuits(
      qDriver.Id
    );
    Test.stopTest();

    System.assertEquals(
      expectedDriverCircuits,
      testDriverCircuits,
      'FormulaOneDAOTest.getDriverCircuitsTest TEST FAILURE'
    );
  }

  @isTest
  static void getAllDriversByCircuitTest() {
    List<Race__c> qAllRacesNames = [SELECT Name FROM Race__c];

    Test.startTest();
    Map<String, List<String>> AllDriversByCircuit = FormulaOneDAO.getAllDriversByCircuit();
    Test.stopTest();

    System.assertEquals(
      AllDriversByCircuit.size(),
      qAllRacesNames.size(),
      'FormulaOneDAOTest.getAllDriversByCircuitTest MAP is Corrupted TEST FAILURE'
    );
    for (Race__c r : qAllRacesNames) {
      System.assert(
        AllDriversByCircuit.containsKey(r.Name),
        'FormulaOneDAOTest.getAllDriversByCircuitTest MAP Name miss TEST FAILURE'
      );
    }
  }

  @isTest
  static void getYoungestDriverOnRaceTest() {
    Race__c qRace = [
      SELECT
        Id,
        (SELECT Racer__r.Age__c FROM Racing_Results__r ORDER BY Racer__r.Age__c)
      FROM Race__c
      LIMIT 1
    ];
    Driver__c expectedDriver = [
      SELECT Name, Age__C
      FROM Driver__c
      WHERE
        Id IN (
          SELECT Racer__c
          FROM Race_Result__c
          WHERE Grand_Prix__c = :qRace.Id
        )
      ORDER BY Age__c
      LIMIT 1
    ];

    Test.startTest();
    Driver__c testDriver = FormulaOneDAO.getYoungestDriverOnRace(qRace.Id);
    Test.stopTest();

    System.assertEquals(
      expectedDriver,
      testDriver,
      'FormulaOneDAOTest.getYoungestDriverOnRaceTest TEST FAILURE'
    );
  }
}