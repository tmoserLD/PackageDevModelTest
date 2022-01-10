/**
 * @author tmoser@launchdarkly.com
 * @date 1/6/2022
 *
 * @description Generic SOSL Query Class
 *
 */
public with sharing class SearchController {
    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm){
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        returningQuery = objectName+' ( Id, '+String.join(fields,',')+')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        List<List<sObject>> searchRecords = Search.Query(Query);
        return searchRecords.get(0);
    }
}
