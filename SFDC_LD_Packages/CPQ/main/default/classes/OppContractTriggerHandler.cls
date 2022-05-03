/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description Opportunity object - Contract automation Trigger Handler class
*
* Tested by OppContractTest
*/
public with sharing class OppContractTriggerHandler {

    // track current loop for Apex transaction
    public static Boolean firstRunAfterInsert = true;
    public static Boolean firstRunAfterUpdate = true;

    /**
    * @description Process to be run in the AFTER INSERT trigger context
    * @param opps records in trigger execution
    */
    public static void afterInsert(List<Opportunity> opps) {
        if (firstRunAfterInsert) {
            firstRunAfterInsert = false;
            OppContractUtil.relatedObjectAfterUpdates(
                opps,
                new Map<Id, Opportunity>()
            );
        }        
    }
    
    /**
    * @description Process to be run in the AFTER UPDATE trigger context
    * @param opps records in trigger execution
    * @param oldOppsMap (Map) Record Id => Old version of record before updates
    */
    public static void afterUpdate(List<Opportunity> opps, Map<Id, Opportunity> oldOppsMap) {
        if (firstRunAfterUpdate) {
            firstRunAfterUpdate = false;
            OppContractUtil.relatedObjectAfterUpdates(
                opps,
                oldOppsMap
            );
        }        
    }

}