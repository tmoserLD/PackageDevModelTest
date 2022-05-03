import { LightningElement, api, track } from 'lwc';

// Query Method
import query from '@salesforce/apex/cpq_ConfigQuoteClass.queryLookupQuestion';

export default class CPQ_RecordLookupResults extends LightningElement {

    // Configuration Type
    @api configType;

    // Question Info
    @api questionInfo;

    // Diplay mode
    @api mode;

    @api
    get querySet() {
        return this.questionInfo.querySet;
    }
    set querySet(value) {
        if (this.questionInfo !== undefined) {
            this.queryRecords();
        }
    }

    @api getSelectedRecords() {
        return this.queriedRecords.filter(r => r.selected === true);
    }

    // Columns
    @track columns = [];

    // Loading / Show Spinner
    @track loading = false;

    // Queried records
    @track queriedRecords = [];

    // Current Sort Column
    @track sortCol = {};

    // Boolean indicator if any exist
    get noRecordsToDisplay() {

        if (
            this.mode === 'selected' &&
            (
                this.questionInfo.selectedRecords === undefined ||
                this.questionInfo.selectedRecords.length < 1
            )
        ) {
            return true;
        } else if (
            this.mode === 'queried' &&
            (
                this.queriedRecords === undefined ||
                this.queriedRecords.length < 1
            )
        ) {
            return true;
        }
        else {
            return false;
        }
    }

    // Queried mode
    get queriedMode() {
        return this.mode === 'queried';
    }

    // Columns to display
    get columnsToDisplay() {
        let columns = [];

        JSON.parse(JSON.stringify(this.columns)).forEach(function(col) {
            // Sort
            if (this.sortCol.field === col.field) {
                col.sortUp = this.sortCol.sort === 'Up';
                col.sortDown = this.sortCol.sort === 'Down';
            }

            columns.push(col);
        }, this);

        return columns;
    }

    // CSS class names string for component
    get colCSS() {
        let colCSS = 'slds-col slds-p-horizontal_x-small slds-p-bottom_xx-small';
        if (this.columns.length >= 6) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-6';
        }
        else if (this.columns.length >= 5) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-5 slds-large-size_1-of-5';
        }
        else if (this.columns.length >= 4) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-4 slds-large-size_1-of-4';
        }
        else if (this.columns.length >= 3) {
            colCSS += ' slds-size_1-of-3 slds-medium-size_1-of-3 slds-large-size_1-of-3';
        }
        return colCSS;
    }

    // Sorted Records
    get sortedRecords() {
        return this.sorter(this.sortCol);
    }

    // Sorter
    sorter(sortCol) {
        let records = [];

        // Get Stored Records
        if (this.mode === 'selected' &&
            this.questionInfo.selectedRecords !== undefined
        ) {
            records = JSON.parse(JSON.stringify(this.questionInfo.selectedRecords));
        }
        else if (
            this.mode === 'queried' &&
            this.queriedRecords !== undefined
        ) {
            records = this.queriedRecords;
        }

        return records.sort(function(recordA, recordB) {

            // Sort by sort col
            if (sortCol.field !== undefined) {
                // Sort Up
                if (sortCol.sort === 'Up') {
                    if (recordA[sortCol.field] > recordB[sortCol.field]) {
                        return -1;
                    }
                    if (recordA[sortCol.field] < recordB[sortCol.field]) {
                        return 1;
                    }
                }

                // Sort Down
                else if (sortCol.sort === 'Down') {
                    if (recordA[sortCol.field] < recordB[sortCol.field]) {
                        return -1;
                    }
                    if (recordA[sortCol.field] > recordB[sortCol.field]) {
                        return 1;
                    }
                }
            }

            // Otherwise, treat as the same
            return 0;
        });
    }

    // Sort column
    sortColumn(event) {
        if (this.sortCol.field !== undefined) {
            if (this.sortCol.field === event.target.id.split('-')[0]) {
                if (this.sortCol.sort === 'Up') {
                    this.sortCol = {
                        field: event.target.id.split('-')[0],
                        sort: 'Down'
                    }
                } else {
                    this.sortCol = {}
                }
            } else {
                this.sortCol = {
                    field: event.target.id.split('-')[0],
                    sort: 'Up'
                };
            }
        } else {
            this.sortCol = {
                field: event.target.id.split('-')[0],
                sort: 'Up'
            };
        }
    }

    // Query Apex call
    async queryRecords() {

        let question = {
            Id: this.questionInfo.Id,
            Query_String__c: this.questionInfo.Query_String__c,
            Record_Display_Fields__c: this.questionInfo.Record_Display_Fields__c,
            sobjectType: 'CPQ_Playbook_Question__c'
        };

        this.loading = true;
        let queryReturnInfo;

        // Send object to database
        try {
            queryReturnInfo = await query({
                question: question
            });

            this.columns = queryReturnInfo.columns;
            this.queriedRecords = queryReturnInfo.records;
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to query the record(s)',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        // Auto selections
        if (this.mode === 'selected' &&
            !this.configType.includes('View') &&
            (
                this.questionInfo.Record_Selection_Behavior__c === 'Automatic Record Selection (With Deselection)' &&
                this.configType !== 'Edit'  
            ) ||
            this.questionInfo.Record_Selection_Behavior__c === 'Automatic Record Selection (No Deselection)'
        ) {

            // Store all record IDs
            let answerIDs = [];
            let selectedRecords = [];
            this.queriedRecords.forEach(function(record) {
                if (this.questionInfo.Maximum_Record_Selections__c === undefined ||
                    answerIDs.length < this.questionInfo.Maximum_Record_Selections__c    
                ) {
                    answerIDs.push(record.Id);
                    selectedRecords.push(record);
                }
            }, this);

            // Send update to parent
            const touchEvent = new CustomEvent(
                'touch', {
                    detail: {
                        answer: answerIDs.join(';'),
                        selectedRecords: selectedRecords
                    }
                });
            this.dispatchEvent(touchEvent);
        }

        // Existing selections
        if (this.mode === 'queried' &&
            this.questionInfo.selectedRecords !== undefined
        ) {
            this.queriedRecords.forEach(function(record) {
                if (this.questionInfo.selectedRecords.filter(r => r.Id === record.Id).length > 0) {
                    record.selected = true;
                } else {
                    record.selected = false;
                }
            }, this);
        }

        // Update Selections to be those only in the queried records
        if (this.mode === 'selected' &&
            this.questionInfo.selectedRecords !== undefined
        ) {
            // Store all record IDs
            let answerIDs = [];
            let selectedRecords = [];
            this.questionInfo.selectedRecords.forEach(function(record) {
                if (this.queriedRecords.filter(r => r.Id === record.Id).length > 0) {
                    answerIDs.push(record.Id);
                    selectedRecords.push(record);
                }
            }, this);

            // Send update to parent
            const touchEvent = new CustomEvent(
                'touch', {
                    detail: {
                        answer: answerIDs.join(';'),
                        selectedRecords: selectedRecords
                    }
                });
            this.dispatchEvent(touchEvent);
        }

        this.loading = false;
    }

    recordSelectionUpdate(event) {
        this.queriedRecords.forEach(function(record) {
            if (record.Id === event.target.name) {
                record.selected = event.target.checked;
            }
        }, this);
    }

}