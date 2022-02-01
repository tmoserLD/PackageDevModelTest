/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description CPQ Any Opp controller class
*
* Tested by cpq_AnyOppContainerClassTest
*/
public with sharing class cpq_AnyOppContainerClass {

    /**
    * @description Query Opportunity so that is appears under recently viewed
    * @param oppId Id of Opportunity record
    */
    @AuraEnabled
    public static void queryOpp(Id oppId) {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            WHERE Id=:oppId
            FOR VIEW
        ];
    }

    /**
    * @description Query recently viewed opportunity records
    * @return List of recently viewed opportunity records
    */
    @AuraEnabled
    public static List<Opportunity> getRecentlyViewed() {
        Set<Id> recentlyViewedOppIDs = new Set<Id>();
        for (RecentlyViewed rv : [
            SELECT Id
            FROM RecentlyViewed
            WHERE Type='Opportunity'
        ]) {
            recentlyViewedOppIDs.add(rv.Id);
        }

        List<Opportunity> opps = new List<Opportunity>();
        opps = [
            SELECT Id,
                Name,
                Account.Name,
                Owner.Name,
                LastViewedDate
            FROM Opportunity
            WHERE Id IN:recentlyViewedOppIDs
            ORDER BY LastViewedDate DESC
        ];

        return opps;
    }
}
