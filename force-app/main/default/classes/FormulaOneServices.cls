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
}