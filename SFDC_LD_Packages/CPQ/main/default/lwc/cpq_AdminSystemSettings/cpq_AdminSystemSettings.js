import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminSystemSettings extends LightningElement {

    // System Settings
    @api systemSettings;

    // Spinner
    @track loading = false;

    // Contract Table Columns
    @track contractColumns;

    @track quoteColumns;

    // On Mount
    connectedCallback() {
        this.contractColumns = this.systemSettings.Contract_Table_Columns__c;
        this.quoteColumns = this.systemSettings.Quote_Table_Columns__c;
    }

    // Contract Table Columns Change
    contractColumnChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.contractColumns = cols;
    }

    // Quote Table Columns Change
    quoteColumnChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.quoteColumns = cols;
    }

    // Saved Settings
    savedSettings(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'System Settings were saved',
                        variant: 'success'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the system settings',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitSettings() {
        this.loading = true;
    }
}