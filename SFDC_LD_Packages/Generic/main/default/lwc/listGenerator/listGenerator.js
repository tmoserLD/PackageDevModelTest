import { LightningElement, api, track } from 'lwc';

export default class ListGenerator extends LightningElement {

    @api orderLabelTitle;
    @api label;
    @api placeholder;
    @api helpText;
    @api initialOptions;
    @api initialOptionsSource;

    @track selectedOptions = [];
    @track showOrderModal= false;

    connectedCallback() {
        if (this.initialOptions !== undefined) {
            if (this.initialOptionsSource === 'List') {
                this.selectedOptions = this.initialOptions;
            } else if (this.initialOptionsSource === 'Semicolon delineated') {
                this.selectedOptions = this.initialOptions.split(';');
            } else if (this.initialOptionsSource === 'Comma delineated') {
                this.selectedOptions = this.initialOptions.split(',');
            }
        }
    }

    addOption() {
        let option;
        this.template.querySelectorAll('lightning-input').forEach(function(input) {
            option = input.value;
        }, this);
        if (!this.selectedOptions.includes(option)) {
            this.selectedOptions.push(option);
        }
        this.sendUpdateEvent();

        this.template.querySelectorAll('lightning-input').forEach(function(input) {
            input.value = '';
        }, this);
    }

    removeOption(event) {
        this.selectedOptions = this.selectedOptions.filter(
            option => option !== event.target.label
        );
        this.sendUpdateEvent();
    }

    sendUpdateEvent() {
        const updateEvent = new CustomEvent(
            'update', {
                detail: this.selectedOptions
            });
        this.dispatchEvent(updateEvent);
    }

    showOrder() {
        this.showOrderModal = true;
    }

    closeOrder() {
        this.showOrderModal = false;
    }

    orderUpdate(event) {
        this.selectedOptions = event.detail;
        this.sendUpdateEvent();
    }
}