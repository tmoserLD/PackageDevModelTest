/**
* @author Tristan Moser
* @date 1/12/2022
*
* @description Opportunity object - Contract automation Updates class
*
* Tested by OppContractTest
*/
public with sharing class OppContractUtil {

    /****************
     * MAIN METHODS
    ****************/

    /**
    * @description All same Related Object updates that should run on After Insert AND After Update
    * @param opps Opportunity records with updated/inserted values in trigger context
    * @param oldOppsMap Map - Opportunity Id to Old version of Opportunity
    */ 
    public static void relatedObjectAfterUpdates(
        List<Opportunity> opps,
        Map<Id, Opportunity> oldOppsMap
    ) {

        // Field Mapping metadata
        List<Entitlement_Field_Mapping__mdt> fieldMappings = Entitlement_Field_Mapping__mdt.getAll().values();

        // Gather Related IDs that may be needed
        Set<Id> syncedQuoteIDs = new Set<Id>();
        Set<Id> accountIDs = new Set<Id>();
        Set<Id> oppIDs = new Set<Id>();
        for (Opportunity opp : opps) {
            syncedQuoteIDs.add(opp.SyncedQuoteId);
            accountIDs.add(opp.AccountId);
            oppIDs.add(opp.Id);
        }

        // Related records to query
        RelatedQueryRecords queriedRecords = new RelatedQueryRecords();

        // Contract records to insert
        List<Contract> contractsToInsert = new List<Contract>();

        // Contract Entitlement records to insert
        Map<Id, List<Contract_Entitlement__c>> entitlementsToInsert = new Map<Id, List<Contract_Entitlement__c>>();

        // Contract Playbook Answer records to insert
        Map<Id, List<Contract_Playbook_Answer__c>> answersToInsert = new Map<Id, List<Contract_Playbook_Answer__c>>();

        // Evaluate each Opportunity
        for (Opportunity opp : opps) {

            // Get Old version of Opportunity
            Opportunity oldOpp = new Opportunity();
            // Not in Insert context
            if (oldOppsMap.containsKey(opp.Id)) {
                oldOpp = oldOppsMap.get(opp.Id);
            }

            // Opp Create Contract flag tripped
            if (opp.Create_Contract__c == true &&
                oldOpp.Create_Contract__c != true
            ) {

                // Get Synced Quote
                Quote syncedQuote = new Quote();
                if (opp.SyncedQuoteId != null) {
                    syncedQuote = getSyncedQuote(
                        opp.SyncedQuoteId,
                        syncedQuoteIDs,
                        queriedRecords
                    );
                }

                // Generate new Contract
                Contract newCont = new Contract();
                newCont.AccountId = opp.AccountId;
                newCont.Opportunity__c = opp.Id;
                newCont.Quote__c = opp.SyncedQuoteId;
                newCont.CPQ_Playbook__c = syncedQuote.CPQ_Playbook__c;

                // Contract being adjusted (if applicable)
                newCont.Adjustment_of_Contract__c = opp.Adjustment_of_Contract_Override__c != null ? opp.Adjustment_of_Contract_Override__c: syncedQuote.Adjustment_of_Contract__c;

                // Adjustment Type (if applicable)
                newCont.Adjustment_Type__c = opp.Adjustment_Type_Override__c != null ? opp.Adjustment_Type_Override__c: syncedQuote.Adjustment_Type__c;

                // Generate new Contract Entitlements
                Date startDate;
                Date endDate;
                entitlementsToInsert.put(opp.Id, new List<Contract_Entitlement__c>());
                for (OpportunityLineItem oli : getOppLines(
                    opp.Id,
                    oppIDs,
                    fieldMappings,
                    queriedRecords
                )) {

                    // New Entitlement
                    Contract_Entitlement__c ent = new Contract_Entitlement__c();

                    // Map fields
                    for (Entitlement_Field_Mapping__mdt fm : fieldMappings) {
                        ent.put(fm.Entitlement_Field__c, oli.get(fm.OpportunityLineItem_Field__c));
                    }

                    entitlementsToInsert.get(opp.Id).add(ent);

                    // Update contract dates
                    if (startDate == null ||
                        ent.Start_Date__c < startDate
                    ) {
                        startDate = ent.Start_Date__c;
                    }
                    if (endDate == null ||
                        ent.End_Date__c > endDate
                    ) {
                        endDate = ent.End_Date__c;
                    }
                }

                // Bring over original contract entitlements (if applicable)
                if (newCont.Adjustment_Type__c == 'Amendment') {

                    // Find existing contract being upgraded (if exists and upgradeable)
                    Contract existingContract = getExistingContract(
                        newCont.Adjustment_of_Contract__c,
                        accountIDs,
                        fieldMappings,
                        queriedRecords
                    );

                    if (existingContract != null) {
                        for (Contract_Entitlement__c existingEnt : existingContract.Contract_Entitlements__r) {

                            // New Entitlement
                            Contract_Entitlement__c ent = new Contract_Entitlement__c();

                            // Map fields
                            for (Entitlement_Field_Mapping__mdt fm : fieldMappings) {
                                ent.put(fm.Entitlement_Field__c, existingEnt.get(fm.Entitlement_Field__c));
                            }

                            entitlementsToInsert.get(opp.Id).add(ent);

                            // Update contract dates
                            if (startDate == null ||
                                ent.Start_Date__c < startDate
                            ) {
                                startDate = ent.Start_Date__c;
                            }
                            if (endDate == null ||
                                ent.End_Date__c > endDate
                            ) {
                                endDate = ent.End_Date__c;
                            }
                        }
                    }
                }

                // Update Standard dates
                if (startDate == null) {
                    startDate = Date.today();
                }
                if (endDate == null) {
                    endDate = Date.today();
                }
                newCont.StartDate = startDate;
                newCont.ContractTerm = startDate.monthsBetween(endDate);
                if (newCont.ContractTerm <= 0) {
                    newCont.ContractTerm = 1;
                }

                // Generate new Contract Playbook Answers
                answersToInsert.put(opp.Id, new List<Contract_Playbook_Answer__c>());
                if (opp.SyncedQuoteId != null) {
                    for (CPQ_Playbook_Answer__c answer : syncedQuote.CPQ_Playbook_Answers__r) {

                        // New Answer
                        Contract_Playbook_Answer__c ans = new Contract_Playbook_Answer__c();
                        ans.CPQ_Playbook_Question__c = answer.CPQ_Playbook_Question__c;
                        ans.Name = answer.Name;
                        ans.Selected_Records_String__c = answer.Selected_Records_String__c;
                        ans.Value_Boolean__c = answer.Value_Boolean__c;
                        ans.Value_Currency__c = answer.Value_Currency__c;
                        ans.Value_Date__c = answer.Value_Date__c;
                        ans.Value_Decimal__c = answer.Value_Decimal__c;
                        ans.Value_Integer__c = answer.Value_Integer__c;
                        ans.Value_Text__c = answer.Value_Text__c;

                        answersToInsert.get(opp.Id).add(ans);
                    }
                }

                contractsToInsert.add(newCont);
            }
        }

        // Insert contracts if present
        if (contractsToInsert.size() > 0) {

            // Insert records
            insert contractsToInsert;

            List<Contract_Entitlement__c> entitlements = new List<Contract_Entitlement__c>();
            List<Contract_Playbook_Answer__c> answers = new List<Contract_Playbook_Answer__c>();

            List<Contract> adjustedContracts = new List<Contract>();

            // Relate contracts to entitlements and answers
            for (Contract cont : contractsToInsert) {

                // Get Entitlements
                for (Contract_Entitlement__c ent : entitlementsToInsert.get(cont.Opportunity__c)) {
                    ent.Contract__c = cont.Id;

                    entitlements.add(ent);
                }

                // Get Answers
                for (Contract_Playbook_Answer__c answer : answersToInsert.get(cont.Opportunity__c)) {
                    answer.Contract__c = cont.Id;

                    answers.add(answer);
                }

                // Update source contract
                if (cont.Adjustment_of_Contract__c != null) {
                    Contract adjustedContract = new Contract(
                        Id = cont.Adjustment_of_Contract__c,
                        Adjusted_by_Contract__c = cont.Id
                    );

                    adjustedContracts.add(adjustedContract);
                }
            }

            if (entitlements.size() > 0) {
                insert entitlements;
            }

            if (answers.size() > 0) {
                insert answers;
            }

            if (adjustedContracts.size() > 0) {
                update adjustedContracts;
            }
        }
    }


    /****************
     * QUERY HELPER METHODS
     ****************/

    /**
    * @description Get Synced Quote record for a given Opportunity
    * @param syncedQuoteId Synced Quote Id of Opportunity record is needed for
    * @param allSyncedQuoteIDs All Synced Quote IDs for all Opportunity records in trigger context
    * @param queriedRecords Current state of helper object to determine which related records have been queried
    * @return Quote
    */
    private static Quote getSyncedQuote(
        Id syncedQuoteId,
        Set<Id> allSyncedQuoteIDs,
        RelatedQueryRecords queriedRecords
    ) {

        // Query Quote records ONLY if not already queried in this transaction
        if (queriedRecords.syncedQuotes == null) {
            // Define Synced Quotes map
            queriedRecords.syncedQuotes = new Map<Id, Quote>();

            // Query Quotes
            for (Quote q : [
                SELECT Id,
                    Adjustment_of_Contract__c,
                    Adjustment_Type__c,
                    CPQ_Playbook__c,
                    (
                        SELECT Id,
                            CPQ_Playbook_Question__c,
                            Name,
                            Selected_Records_String__c,
                            Value_Boolean__c,
                            Value_Currency__c,
                            Value_Date__c, 
                            Value_Decimal__c, 
                            Value_Integer__c, 
                            Value_Text__c
                        FROM CPQ_Playbook_Answers__r
                    )
                FROM Quote
                WHERE Id IN:allSyncedQuoteIDs
            ]) {
                queriedRecords.syncedQuotes.put(q.Id, q);
            }
        }

        return queriedRecords.syncedQuotes.get(syncedQuoteId);
    }

    /**
    * @description Get Opportunity Line Item records for a given Opportunity
    * @param oppId Id of Opportunity records are needed for
    * @param allOppIDs All Opportunity IDs for all records in trigger context
    * @param fieldMappings OLI => Entitlement field mapping values
    * @param queriedRecords Current state of helper object to determine which related records have been queried
    * @return List<OpportunityLineItem>
    */
    private static List<OpportunityLineItem> getOppLines(
        Id oppId,
        Set<Id> allOppIDs,
        List<Entitlement_Field_Mapping__mdt> fieldMappings,
        RelatedQueryRecords queriedRecords
    ) {

        // Query Opportunity records ONLY if not already queried in this transaction
        if (queriedRecords.oppLinesMap == null) {
            // Define Opportunity Line Items map
            queriedRecords.oppLinesMap = new Map<Id, List<OpportunityLineItem>>();
            
            // Get OLI fields needed
            String oliFieldsString = '';
            Set<String> oliFieldsSet = new Set<String>();
            for (Entitlement_Field_Mapping__mdt fm : fieldMappings) {
                if (!oliFieldsSet.contains(fm.OpportunityLineItem_Field__c)) {
                    oliFieldsSet.add(fm.OpportunityLineItem_Field__c);
                    oliFieldsString += fm.OpportunityLineItem_Field__c + ',';
                }
            }
            oliFieldsString = oliFieldsString.removeEnd(',');
            if (oliFieldsString == '') {
                oliFieldsString = 'Id';
            }

            // Set query string
            String oppLinesQuery = ''
                + 'SELECT Id, '
                    + '( '
                        + 'SELECT '
                            + oliFieldsString
                            + ' FROM OpportunityLineItems'
                            + ' WHERE Product2.Do_Not_Create_Entitlement__c != true '
                    + ')'
                + ' FROM Opportunity'
                + ' WHERE Id IN:allOppIDs';

            // Query Opportunities
            for (Opportunity opp : Database.query(oppLinesQuery)) {
                queriedRecords.oppLinesMap.put(opp.Id, opp.OpportunityLineItems);
            }
        }

        return queriedRecords.oppLinesMap.containsKey(oppId) == true ? queriedRecords.oppLinesMap.get(oppId) : new List<OpportunityLineItem>();
    }

    /**
    * @description Get Existing Contract being adjusted
    * @param contractId Contract Id of record being adjusted
    * @param allAccountIDs All Account IDs for all Opportunity records in trigger context
    * @param fieldMappings QLI => Entitlement field mapping values
    * @param queriedRecords Current state of helper object to determine which related records have been queried
    * @return Contract
    */
    private static Contract getExistingContract(
        Id contractId,
        Set<Id> allAccountIDs,
        List<Entitlement_Field_Mapping__mdt> fieldMappings,
        RelatedQueryRecords queriedRecords
    ) {

        // Query Contract records ONLY if not already queried in this transaction
        if (queriedRecords.existingContracts == null) {
            // Define Existing Contracts map
            queriedRecords.existingContracts = new Map<Id, Contract>();

            // Get Entitlement fields needed
            String entFieldsString = '';
            Set<String> entFieldsSet = new Set<String>();
            for (Entitlement_Field_Mapping__mdt fm : fieldMappings) {
                if (!entFieldsSet.contains(fm.Entitlement_Field__c)) {
                    entFieldsSet.add(fm.Entitlement_Field__c);
                    entFieldsString += fm.Entitlement_Field__c + ',';
                }
            }
            entFieldsString = entFieldsString.removeEnd(',');
            if (entFieldsString == '') {
                entFieldsString = 'Id';
            }

            // Set query string
            String contractQuery = ''
                + 'SELECT Id, '
                    + '( '
                        + 'SELECT '
                            + entFieldsString
                            + ' FROM Contract_Entitlements__r'
                    + ')'
                + ' FROM Contract'
                + ' WHERE AccountId IN:allAccountIDs AND'
                + ' Contract_Status__c NOT IN (\'Amended\', \'Replaced\', \'Renewed\', \'Void\')';
                
            // Query Contracts
            for (Contract c : Database.query(contractQuery)) {
                queriedRecords.existingContracts.put(c.Id, c);
            }
        }

        return queriedRecords.existingContracts.get(contractId);
    }

    /**
	* @description Helper object to help store related records to query
	*/ 
    public class RelatedQueryRecords {
        public Map<Id, Contract> existingContracts;
        public Map<Id, List<OpportunityLineItem>> oppLinesMap;
        public Map<Id, Quote> syncedQuotes;
    }
}