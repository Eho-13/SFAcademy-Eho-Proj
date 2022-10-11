public class FormulaOneServices {
    public static String generateKey (SObject record, List<SObjectField> fields, String separator){

        List<String> stringFields = new List<String>();
		stringFields.add(
            record.get(fields)
        );
        string key;
        for(String s: stringFields){
            Key = Key + separator + s;
        }
        
        return Key; 
    }
    
    public static Boolean isHatTrick(Race_Result__c raceResult){
        if (raceResult.Position__c == 1 && raceResult.Grid__c == 1 && raceResult.Is_Fastest_Lap__c)
        {
            return true;
                } 
        else 
        {
            return false;
                }       
    }
}