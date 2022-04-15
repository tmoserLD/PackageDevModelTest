import { LightningElement, api, track } from 'lwc';

export default class CPQ_ApprovalsHubOpportunity extends LightningElement {

    // Opportunity record
    @api opp;

    // Info for current user
    @api currentUser;

    // Default currency for org
    @track defaultCurrency;

    // Toggle to display CPQ Config
    @track showConfig = false;

    // Config objects
    @track userForConfig;

    // Hide Config event received
    hideConfig(event) {
        this.showConfig = false;
    }

    reload(event) {
        // Send reload event to parent
        const reloadEvent = new CustomEvent(
            'reload', {
                detail: {}
            });
        this.dispatchEvent(reloadEvent);
    }

    // View Quote event received
    viewQuote(event) {
    
        // Quote
        let quote = JSON.parse(JSON.stringify(this.opp.quotes.find(
            q => q.quoteInfo.Id === event.detail
        )));

        this.quoteForConfig = quote.quoteInfo;
        this.userForConfig = {};
        this.showConfig = true;
    }

}