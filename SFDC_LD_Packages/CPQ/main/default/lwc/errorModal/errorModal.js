import { LightningElement, api, track } from 'lwc';

export default class ErrorModal extends LightningElement {

    // Title
    @api title = '';

    // Body Text
    @api body = '';

    // Refresh page
    @api forceRefresh = false;

    // Display toggle
    @track showModal = false;

    // Close clicked
    closeClick() {

        // Force page refresh
        if (this.forceRefresh == true) {
            location.reload();
        }

        this.showModal = false;
    }

    // Parent toggle method
    @api 
    showError(infoObj) {
        this.title = infoObj.title;
        this.body = infoObj.body;
        this.forceRefresh = infoObj.forceRefresh;
        this.showModal = true;
    }
}