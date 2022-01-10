import { LightningElement, api, track } from 'lwc';

// Upload PDF method
import generatePDF from '@salesforce/apex/cpq_ContainerClass.generatePDF';

export default class CPQ_ProposalPDF extends LightningElement {

    // Opportunity Info
    @api oppInfo;

    // Quote Info
    @api quote;

    // HTML display text
    @track displayText = 'LMNOP';

    // Spinner
    @track loading = false;

    // PDF URL for iframe
    @track pdfURL;


    // On Mount
    connectedCallback() {
        this.pdfURL = '/apex/cpq_ProposalVF?quoteId=' + this.quote.Id;
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