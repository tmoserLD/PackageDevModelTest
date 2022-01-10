public class OppContractUtil {

    /****************
     * ENTRY METHODS
    ****************/

    /**
    * @description Logic run after an Opportunity Insert
    * Handles updates of related records
    * @param insertedOpps Opportunity records with inserted values in trigger context
    */ 
    public static void processAfterInsert(
        List<Opportunity> insertedOpps
    ) {
        relatedObjectAfterUpdates(
            insertedOpps,
            new Map<Id, Opportunity>()
        );
    }

    /**
    * @description Logic run after an Opportunity Update
    * Handles updates of related records
    * @param updatedOpps Opportunity records with updated values in trigger context
    * @param oldOppsMap Map - Opportunity Id to Old version of Opportunity
    */ 
    public static void processAfterUpdate(
        List<Opportunity> updatedOpps,
        Map<Id, Opportunity> oldOppsMap
    ) {
        relatedObjectAfterUpdates(
            updatedOpps,
            oldOppsMap
        );
    }

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

        // Gather Related IDs that may be needed
        Set<Id> syncedQuoteIDs = new Set<Id>();
        for (Opportunity opp : opps) {
            syncedQuoteIDs.add(opp.SyncedQuoteId);
        }

        // Related records to query
        RelatedQueryRecords queriedRecords = new RelatedQueryRecords();

        // Contract records to insert
        List<Contract> contractsToInsert = new List<Contract>();

        // Opp to Contract Adjustment Type
        Map<Id, String> adjTypeMap = new Map<Id, String>();

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

                // Synced Quote exists
                if (opp.SyncedQuoteId != null) {

                    // Get Synced Quote
                    Quote syncedQuote = getSyncedQuote(
                        opp.SyncedQuoteId,
                        syncedQuoteIDs,
                        queriedRecords
                    );

                    // Generate new Contract
                    Contract newCont = new Contract();
                    newCont.AccountId = opp.AccountId;
                    newCont.Opportunity__c = opp.Id;
                    newCont.Quote__c = opp.SyncedQuoteId;
                    newCont.CPQ_Playbook__c = syncedQuote.CPQ_Playbook__c;

                    // Contract being adjusted (if applicable)
                    newCont.Adjustment_of_Contract__c = syncedQuote.Adjustment_of_Contract__c;

                    // Adjustment Type (if applicable)
                    adjTypeMap.put(opp.Id, syncedQuote.Adjustment_Type__c);

                    // Generate new Contract Entitlements
                    Date startDate;
                    Date endDate;
                    for (QuoteLineItem qli : syncedQuote.QuoteLineItems) {

                        // New Entitlement
                        Contract_Entitlement__c ent = new Contract_Entitlement__c();
                        ent.Quote_Line_Item__c = qli.Id;
                        ent.Discount__c = qli.Discount__c;
                        ent.End_Date__c = qli.End_Date__c;
                        ent.List_Price__c = qli.List_Price__c;
                        ent.Product__c = qli.Product2Id;
                        ent.Quantity__c = qli.Quantity__c;
                        ent.Start_Date__c = qli.Start_Date__c;
                        ent.Unit_Price__c = qli.Quoted_Price__c;
                        ent.CPQ_Playbook_Rule_Action__c = qli.CPQ_Playbook_Rule_Action__c;

                        if (!entitlementsToInsert.containsKey(opp.Id)) {
                            entitlementsToInsert.put(opp.Id, new List<Contract_Entitlement__c>());
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

                    // Update Standard dates
                    newCont.StartDate = startDate;
                    newCont.ContractTerm = startDate.monthsBetween(endDate);
                    if (newCont.ContractTerm <= 0) {
                        newCont.ContractTerm = 1;
                    }

                    // Generate new Contract Playbook Answers
                    for (CPQ_Playbook_Answer__c answer : syncedQuote.CPQ_Playbook_Answers__r) {

                        // New Answer
                        Contract_Playbook_Answer__c ans = new Contract_Playbook_Answer__c();
                        ans.CPQ_Playbook_Question__c = answer.CPQ_Playbook_Question__c;
                        ans.Name = answer.Name;
                        ans.Value_Boolean__c = answer.Value_Boolean__c;
                        ans.Value_Currency__c = answer.Value_Currency__c;
                        ans.Value_Date__c = answer.Value_Date__c;
                        ans.Value_Decimal__c = answer.Value_Decimal__c;
                        ans.Value_Integer__c = answer.Value_Integer__c;
                        ans.Value_Text__c = answer.Value_Text__c;

                        if (!answersToInsert.containsKey(opp.Id)) {
                            answersToInsert.put(opp.Id, new List<Contract_Playbook_Answer__c>());
                        }

                        answersToInsert.get(opp.Id).add(ans);
                    }

                    contractsToInsert.add(newCont);

                }
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
                        Id=cont.Adjustment_of_Contract__c,
                        Adjusted_by_Contract__c=cont.Id
                    );

                    if (adjTypeMap.get(cont.Opportunity__c) == 'Replacement') {
                        adjustedContract.IsReplaced__c = true;
                    }

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
            // Query and organize Steps by Opportunity
            for (Quote q : [
                SELECT Id,
                    Adjustment_of_Contract__c,
                    Adjustment_Type__c,
                    CPQ_Playbook__c,
                    (
                        SELECT Id,
                            CPQ_Playbook_Rule_Action__c,
                            Discount__c,
                            End_Date__c,
                            List_Price__c,
                            Product2Id,
                            Product2.Do_Not_Create_Entitlement__c,
                            Quantity__c,
                            Quoted_Price__c,
                            Start_Date__c,
                            TotalPrice
                        FROM QuoteLineItems
                        WHERE Product2.Do_Not_Create_Entitlement__c != true
                    ),
                    (
                        SELECT Id,
                            CPQ_Playbook_Question__c,
                            Name,
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
	* @description Helper object to help store related records to query
	*/ 
    public class RelatedQueryRecords {
        public Map<Id, Quote> syncedQuotes;
    }
}