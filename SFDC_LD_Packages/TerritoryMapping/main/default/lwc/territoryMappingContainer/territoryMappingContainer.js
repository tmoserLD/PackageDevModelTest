import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Query Methods
import getAllMappings from '@salesforce/apex/TerritoryMapping.getAllMappings';

export default class TerritoryMappingContainer extends LightningElement {

    // Spinner
    @track loading = false;

    // Mappings
    @track mappings = [];

    // Object
    @track object = 'Account';

    // Object containing selections for all mapping levels
    @track selected = {};

    // Object base options
    @track objectBaseOptions = ['Account'];

    // On Mount
    connectedCallback() {
        // Query initial mappings
        this.reloadMappings(this.object);
    }

    // Object picklist options
    get objectOptions() {
        let objectOptions = [];
        this.objectBaseOptions.forEach(function(object) {
            objectOptions.push(
                {
                    label: object,
                    value: object
                }
            );
        });
        return objectOptions;
    }

    // Reload mappings data
    async reloadMappings(event) {

        // Show Toast
        if (event) {
            if (event.detail) {
                if (event.detail.toast) {
                    const toastEvent = new ShowToastEvent({
                        title: event.detail.toast.title,
                        message: event.detail.toast.message,
                        variant: event.detail.toast.variant,
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }

        this.loading = true;

        // Reset data
        this.mappings = [];

        // Get data
        if (this.object !== undefined &&
            this.object !== null &&
            this.object !== ''    
        ) {
            try {
                this.mappings = await getAllMappings(
                    {
                        objectName: this.object
                    }
                );

                // Set selected
                if (event) {
                    if (event.detail) {
                        if (event.detail.selected) {
                            this.selected = event.detail.selected;
                        }
                    }
                }
            } catch (e) {
                this.template.querySelector('c-error-modal').showError(
                    {
                        title: 'An error occurred while trying to retrieve the mappings',
                        body: JSON.stringify(e),
                        forceRefresh: false
                    }
                );
            }
        }

        this.loading = false;
        this.template.querySelector('lightning-combobox').value = this.object;
    }

    // Object picklist change event
    objectChange(event) {
        this.object = event.target.value;
        this.reloadMappings();
    }

    // Selection event
    updateSelections(event) {
        this.selected = event.detail.selected;
    }

}