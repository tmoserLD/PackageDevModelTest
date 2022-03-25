import { LightningElement, api, track } from 'lwc';

// Upload PDF method
import generatePDF from '@salesforce/apex/cpq_ContainerClass.generatePDF';

export default class CPQ_ProposalPDF extends LightningElement {

    // Opportunity Info
    @api oppInfo;

    // Quote Info
    @api quote;

    // Spinner
    @track loading = false;

    // PDF URL for iframe
    @track pdfURL;


    // On Mount
    connectedCallback() {

        // Determine if draft
        let isDraft = false;
        if (
            this.quote.CPQ_Quote_Approvals__r !== undefined &&
            this.quote.CPQ_Quote_Approvals__r.filter(approval => approval.Status__c != 'Approved').length > 0
        ) {
            isDraft = true;
        }

        // Set PDF VF page URL
        this.pdfURL = '/apex/cpq_ProposalVF?quoteId=' + this.quote.Id + '&isDraft=' + isDraft;
    }


    get cannotSave() {
        return this.loading;
    }

    get definedURL() {
        return this.pdfURL !== undefined;
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

    // Save PDF as file
    async savePDF() {
        this.loading = true;

        try {
            await generatePDF(
                {
                    quoteInfo: this.quote,
                    oppInfo: this.oppInfo
                }
            );

            // Send save event to parent
            const saveEvent = new CustomEvent(
                'save', {
                    detail: {}
                });
            this.dispatchEvent(saveEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to generate the proposal',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }
}