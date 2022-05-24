/**
* @author Tristan Moser
* @date 4/27/2022
*
* @description CPQ object record api name validation class
*
* Tested by CPQ_Record_Validation_Test
*/
public with sharing class CPQ_Record_Validation {

    // All Schmea described up to a given point in an execution context
    private static Map<String, DescribeSObjectResult> schemas = new Map<String, DescribeSObjectResult>();

    /**
    * @description Verify that the list of field names are acceptable for the related field
    * @param fields List of input fields
    * @param acceptableCPQValues possible field names that are not valid field API names
    * @param obj Object Name field API names belong to
    * @param baseField Field Name where field names are being input
    * @return Verification Result
    */
    public static ResultClass verifyFields(List<String> fields, List<String> acceptableCPQValues, String obj, String baseField) {

        ResultClass resultsObj = new ResultClass();
        resultsObj.result = true;
        resultsObj.errorMessage = '';

        // Get Schema for object
        DescribeSObjectResult describedSchema = getSchema(obj);

        for (String field : fields){
            // Valid field
            if (!describedSchema.fields
                    .getMap()
                    .containsKey(field) &&
                !acceptableCPQValues.contains(field)
            ) {
                resultsObj.result = false;
                resultsObj.errorMessage = '"' + field + '"' + ' is not a valid field on the ' + obj + ' object. Please adjust the "' + baseField + '" field.';
            }
        }

        return resultsObj;
    }

    /**
    * @description Verify that the object field pair is valid
    * @param objectFieldPair String in object.field form
    * @param validObjects (Map) Object Name Input => Valid Object API Name : denotes valid objects
    * @param baseField Field Name where object field pair is being input
    * @return Verification Result
    */
    public static ResultClass verifyObjectFieldPair(String objectFieldPair, Map<String, String> validObjects, String baseField) {

        ResultClass resultsObj = new ResultClass();
        resultsObj.result = true;
        resultsObj.errorMessage = '';

        // Valid field values are formatted as obj.field
        if (objectFieldPair.split('\\.').size() == 2) {

            // Extract object and field names
            String obj = objectFieldPair.split('\\.')[0];
            String field = objectFieldPair.split('\\.')[1];

            // Only allow valid objects
            if (validObjects == null ||
                validObjects.containsKey(obj)
            ) {

                // Validate field exists on object
                resultsObj = verifyFields(
                    new List<String>{field},
                    new List<String>(),
                    validObjects.get(obj),
                    baseField
                );
            }
            // Not valid object
            else {
                resultsObj.result = false;
                resultsObj.errorMessage = '"' + obj + '" is not an appropriate object to reference. Please adjust the "' + baseField + '" field.';
            }
        }
        // Invalid format
        else {
            resultsObj.result = false;
            resultsObj.errorMessage = '"' + objectFieldPair + '" is not in the appropriate "object.field" structure. Please adjust the "' + baseField + '" field.';
        }

        return resultsObj;
    }

    /**
    * @description Verify that the query string is a valid query
    * @param queryString query string being input
    * @param baseField Field Name where field names are being input
    * @return Verification Result
    */
    public static ResultClass verifyQuery(String queryString, String baseField) {

        ResultClass resultsObj = new ResultClass();
        resultsObj.result = true;
        resultsObj.errorMessage = '';

        // Attempt to query
        try {
            List<sObject> recordList = new List<sObject>();
            recordList = Database.query(queryString);
        } catch (Exception e) {
            resultsObj.result = false;
            resultsObj.errorMessage = 'Unable to execute the the query in the "' + baseField + '" field. Error: ' + e.getMessage();
        }

        // Attempt to extract Object name from query string
        try {
            String objectName = queryString.toLowerCase().split('from')[1].split(' ')[1];
            DescribeSObjectResult describedSchema = getSchema(objectName);
        } catch (Exception e) {
            resultsObj.result = false;
            resultsObj.errorMessage = 'Unable to read the object for the query in the "' + baseField + '" field.';
        }

        return resultsObj;
    }

    /**
    * @description Verify that the child field contains value that parent field has
    * @param parentFieldValue Value of parent field
    * @param parentField Name of parent field
    * @param childFieldValue Value of child field
    * @param childField Name of child field
    * @return Verification Result
    */
    public static ResultClass verifyDependentFields(String parentFieldValue, String parentField, String childFieldValue, String childField) {

        ResultClass resultsObj = new ResultClass();
        resultsObj.result = true;
        resultsObj.errorMessage = '';

        // Validate child field value in parent field value
        if (!parentFieldValue.split(';').contains(childFieldValue)) {
            resultsObj.result = false;
            resultsObj.errorMessage = '"' + childFieldValue + '" is not listed in the "'+ parentField + '" field. Please adjust the "' + parentField +'" field or input a different value for the "' + childField + '" field.';
        }

        return resultsObj;
    }

    public class ResultClass {
        public Boolean result;
        public String errorMessage;
    }

    /**
    * @description Retrieve Described Schema for a given object name
    * @param objectName object name
    * @return Described Schema
    */
    private static DescribeSObjectResult getSchema(String objectName) {

        // Only act if object's schema has not been described in this transacion
        if (!schemas.containsKey(objectName)) {

            SObjectType objType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
            DescribeSObjectResult obj = objType.getDescribe();

            schemas.put(objectName, obj);
        }

        return schemas.get(objectName);
    }
}
