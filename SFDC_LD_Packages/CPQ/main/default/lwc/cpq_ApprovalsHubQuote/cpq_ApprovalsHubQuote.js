import { LightningElement, api, track } from 'lwc';

export default class CPQ_ApprovalsHubQuote extends LightningElement {

    // Quote record
    @api quote;

    // Info for current user
    @api currentUser;

    reload(event) {
        // Send reload event to parent
        const reloadEvent = new CustomEvent(
            'reload', {
                detail: {}
            });
        this.dispatchEvent(reloadEvent);
    }

    viewQuote() {
        // Send viewquote event to parent
        const viewquoteEvent = new CustomEvent(
            'viewquote', {
                detail: this.quote.quoteInfo.Id
            });
        this.dispatchEvent(viewquoteEvent);
    }
    
}