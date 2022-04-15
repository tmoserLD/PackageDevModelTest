import { LightningElement, api, track } from 'lwc';

export default class CPQ_ApprovalsHubDecisionReason extends LightningElement {

    @api 
    get reason() {
        return this.reasonText;
    }
    set reason(value) {
        this.template.querySelectorAll('lightning-textarea').forEach(function(textArea) {
            textArea.value = value;
        }, this);
        this.reasonText = value;
    }

    @track reasonText;

    updateReason(event) {
        this.reasonText = event.target.value;
    }

    // Cancel clicked
    cancelClick() {
        // Send cancel event to parent
        const cancelEvent = new CustomEvent(
            'cancel', {
                detail: {}
            });
        this.dispatchEvent(cancelEvent);
    }

    // Confirm clicked
    confirmClick() {
        // Send confirm event to parent
        const confirmEvent = new CustomEvent(
            'confirm', {
                detail: {
                    reason: this.reasonText
                }
            });
        this.dispatchEvent(confirmEvent);
    }

}