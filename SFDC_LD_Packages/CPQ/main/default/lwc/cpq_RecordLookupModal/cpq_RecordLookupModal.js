import { LightningElement, api, track } from 'lwc';

export default class CPQ_RecordLookupModal extends LightningElement {

    // Question Info
    @api questionInfo;

    // Loading / Show Spinner
    @track loading = false;


    get hasMaxSelections() {
        return this.questionInfo.Maximum_Record_Selections__c !== undefined;
    }

    // Close clicked
    closeClick() {
        // Send close event to parent
        const closeEvent = new CustomEvent(
            'close', {
                detail: {}
            });
        this.dispatchEvent(closeEvent);
    }

    // Save clicked
    saveClick() {
        let selectedRecords = this.template.querySelector('c-cpq_-record-lookup-results').getSelectedRecords();
        
        // Store all record IDs
        let answerIDs = [];
        selectedRecords.forEach(function(record) {
            answerIDs.push(record.Id);
        }, this);

        // Over Max threshold
        if (this.questionInfo.Maximum_Record_Selections__c !== undefined &&
            answerIDs.length > this.questionInfo.Maximum_Record_Selections__c    
        ) {
            alert("Error! Only " + this.questionInfo.Maximum_Record_Selections__c + " record(s) are allowed to be selected.");
        }
        
        else {

            // Send update to parent
            const saveEvent = new CustomEvent(
                'save', {
                    detail: {
                        answer: answerIDs.join(';'),
                        selectedRecords: selectedRecords
                    }
                });
            this.dispatchEvent(saveEvent);
        }
    }

}