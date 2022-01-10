/**
* @author tmoser@launchdarkly.com
* @date 1/6/2022
*
* @description Data Driven Territory Mapping setup
* Any sObject record can be passed in and have any String field updated based on the given values of a String field
*
* Tested by TerritoryMappingTest
*/
public class TerritoryMapping {

    // All Mappings queried up to a given point in an execution context
    private static Map<String, List<TerritoryMappingObj>> queriedMappings = new Map<String, List<TerritoryMappingObj>>();

    /**
    * @description Evaluate Territory Mappings of a given objectName against a record in a trigger context
    * @param record updated/current version of sObject record
    * @param oldRecord previous version of sObject record
    * @param objectName objectName of Territory Mapping
    * @return User Info
    */
    public static void evaluateMappings(sObject record, sObject oldRecord, String objectName) {

        // Mappings for object
        List<TerritoryMappingObj> mappings = getMappings(objectName);

        for (TerritoryMappingObj mappingObj : mappings) {

            Boolean territoryAssigned = false;

            // Find first condition set that is met
            for (Territory_Mapping_Condition_Set__c conditionSet : mappingObj.conditionSets) {
                // Do not evaluate if already assigned value
                if (territoryAssigned != true) {

                    List<Boolean> conditionsMet = new List<Boolean>();
                    
                    for (Territory_Mapping_Condition__c condition : conditionSet.Territory_Mapping_Conditions__r) {

                        Boolean eligibleMet = false;
                        Boolean ineligibleMet = false;

                        // If no values to check, then it is a default condition
                        if (condition.Eligible_Values__c ==  null) {
                            eligibleMet = true;
                        } else {

                            // Determine if record's source field value is one of the eligible values
                            String values = condition.Eligible_Values__c;
                            String sourceValue = (String) record.get(condition.Source_Field__c);
                            if (condition.Case_Insensitive__c == true) {
                                values = values.toLowerCase();
                                if (sourceValue != null) {
                                    sourceValue = sourceValue.toLowerCase();
                                }
                            }
                            List<String> eligibleValues = values.split(';');

                            if (eligibleValues.contains(sourceValue)) {
                                eligibleMet = true;
                            }
                        }

                        // If no values to check, then it is a default condition
                        if (condition.Ineligible_Values__c ==  null) {
                            ineligibleMet = true;
                        } else {

                            // Determine if record's source field value is NOT one of the ineligible values
                            String values = condition.Ineligible_Values__c;
                            String sourceValue = (String) record.get(condition.Source_Field__c);
                            if (condition.Case_Insensitive__c == true) {
                                values = values.toLowerCase();
                                if (sourceValue != null) {
                                    sourceValue = sourceValue.toLowerCase();
                                }
                            }
                            List<String> ineligibleValues = values.split(';');

                            if (!ineligibleValues.contains(sourceValue)) {
                                ineligibleMet = true;
                            }
                        }

                        if (eligibleMet == true &&
                            ineligibleMet == true
                        ) {
                            conditionsMet.add(true);
                        }
                    }

                    // Update record's target field value if condition met
                    if (conditionsMet.size() == conditionSet.Territory_Mapping_Conditions__r.size()) {
                        record.put(mappingObj.mapping.Target_Field__c, conditionSet.Target_Value__c);
                        territoryAssigned = true;
                    }
                }
            }
        }
    }


    /**
    * @description Retrieve Territory Mappings of a given objectName
    * @param objectName objectName of Territory Mapping
    * @return List of Territory Mappings
    */
    private static List<TerritoryMappingObj> getMappings(String objectName) {

        // Only query if object's mappings have not been queried in this transacion
        if (!queriedMappings.containsKey(objectName)) {

            Map<Id, TerritoryMappingObj> territoryObjMap = new Map<Id, TerritoryMappingObj>();
            for (Territory_Mapping__c mapping : [
                SELECT Id,
                    Evaluation_Order__c,
                    Is_Active__c,
                    Mapping_Name__c,
                    Object__c,
                    Target_Field__c
                FROM Territory_Mapping__c
                WHERE Object__c =:objectName AND
                    Target_Field__c != null AND
                    Is_Active__c = true
                ORDER BY Evaluation_Order__c ASC
            ]) {

                TerritoryMappingObj mappingObj = new TerritoryMappingObj();
                mappingObj.mapping = mapping;
                mappingObj.conditionSets = new List<Territory_Mapping_Condition_Set__c>();
                territoryObjMap.put(mapping.Id, mappingObj);
            }

            if (territoryObjMap.size() > 0) {
                for (Territory_Mapping_Condition_Set__c conditionSet : [
                    SELECT Id,
                        Evaluation_Order__c,
                        Is_Active__c,
                        Name,
                        Target_Value__c,
                        Territory_Mapping__c,
                        (
                            SELECT Id,
                                Case_Insensitive__c,
                                Eligible_Values__c,
                                Ineligible_Values__c,
                                Is_Active__c,
                                Name,
                                Source_Field__c
                            FROM Territory_Mapping_Conditions__r
                            WHERE Is_Active__c = true AND
                                Source_Field__c != null
                        )
                    FROM Territory_Mapping_Condition_Set__c
                    WHERE Territory_Mapping__c IN:territoryObjMap.keySet() AND
                        Is_Active__c = true 
                    ORDER BY Evaluation_Order__c ASC
                ]) {
                    territoryObjMap.get(conditionSet.Territory_Mapping__c).conditionSets.add(conditionSet);
                }
            }
            queriedMappings.put(objectName, territoryObjMap.values());
        }

        return queriedMappings.get(objectName);
    }

    /**
	* @description Helper object to store organized mappings and condition sets
	*/ 
    public class TerritoryMappingObj {
        @AuraEnabled public Territory_Mapping__c mapping;
        @AuraEnabled public List<Territory_Mapping_Condition_Set__c> conditionSets;
    }

    /**
    * @description Retrieve Territory Mappings of a given objectName
    * @param objectName objectName of Territory Mapping
    * @return List of Territory Mappings
    */
    @AuraEnabled
    public static List<TerritoryMappingObj> getAllMappings(String objectName) {

        // Only query if object's mappings have not been queried in this transacion
        if (!queriedMappings.containsKey(objectName)) {

            Map<Id, TerritoryMappingObj> territoryObjMap = new Map<Id, TerritoryMappingObj>();
            for (Territory_Mapping__c mapping : [
                SELECT Id,
                    Evaluation_Order__c,
                    Is_Active__c,
                    Mapping_Name__c,
                    Object__c,
                    Target_Field__c
                FROM Territory_Mapping__c
                WHERE Object__c =:objectName
                ORDER BY Is_Active__c DESC, 
                    Evaluation_Order__c ASC,
                    Mapping_Name__c
            ]) {

                TerritoryMappingObj mappingObj = new TerritoryMappingObj();
                mappingObj.mapping = mapping;
                mappingObj.conditionSets = new List<Territory_Mapping_Condition_Set__c>();
                territoryObjMap.put(mapping.Id, mappingObj);
            }

            if (territoryObjMap.size() > 0) {
                for (Territory_Mapping_Condition_Set__c conditionSet : [
                    SELECT Id,
                        Evaluation_Order__c,
                        Is_Active__c,
                        Name,
                        Target_Value__c,
                        Territory_Mapping__c,
                        (
                            SELECT Id,
                                Case_Insensitive__c,
                                Eligible_Values__c,
                                Ineligible_Values__c,
                                Is_Active__c,
                                Name,
                                Source_Field__c
                            FROM Territory_Mapping_Conditions__r
                            ORDER BY Is_Active__c DESC,
                                Name

                        )
                    FROM Territory_Mapping_Condition_Set__c
                    WHERE Territory_Mapping__c IN:territoryObjMap.keySet()
                    ORDER BY Is_Active__c DESC, 
                        Evaluation_Order__c ASC,
                        Name
                ]) {
                    territoryObjMap.get(conditionSet.Territory_Mapping__c).conditionSets.add(conditionSet);
                }
            }
            queriedMappings.put(objectName, territoryObjMap.values());
        }

        return queriedMappings.get(objectName);
    }

    @AuraEnabled
    public static void deleteRecords(List<sObject> records) {
        delete records;
    }

    @AuraEnabled
    public static sObject cloneRecord(String recordId, String objectAPI) {
        SObjectType objType = ((SObject)(Type.forName('Schema.' + objectAPI).newInstance())).getSObjectType();
        DescribeSObjectResult obj = objType.getDescribe();
        List<String> fields = new List<String>();
        for (String field : obj.fields.getMap().keySet()) {
            fields.add(field);
        }
        String qry = 'SELECT ' + string.join(fields, ',') + ' FROM ' + objectAPI + ' WHERE Id =:recordId';
        sObject existingRecord = Database.query(qry);
        sObject clonedRecord = existingRecord.clone(false, false, false, false);

        String nameString = 'Name';
        if (objectAPI == 'Territory_Mapping__c') {
            nameString = 'Mapping_Name__c';
        }
        String currentName = (String) clonedRecord.get(nameString);
        clonedRecord.put(nameString, 'CLONE: ' + currentName.left(73));

        insert clonedRecord;

        return clonedRecord;
    }
}
