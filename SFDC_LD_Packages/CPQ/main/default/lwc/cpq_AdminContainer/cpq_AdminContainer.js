import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Query Methods
import getSystemSettings from '@salesforce/apex/cpq_AdminContainerClass.getSystemSettings';
import getPlaybooks from '@salesforce/apex/cpq_AdminContainerClass.getPlaybooks';
import getPricebooks from '@salesforce/apex/cpq_AdminContainerClass.getPricebooks';
import getProducts from '@salesforce/apex/cpq_AdminContainerClass.getProducts';

export default class CPQ_AdminContainer extends LightningElement {

    // Spinner
    @track loading = false;

    // All playbooks in system
    @track playbooks;

    // Object containing selections for all playbook levels
    @track playbookSelected;

    // History of playbookSelected
    @track playbookSelectedHistory = [];

    // All pricebooks in system
    @track pricebooks;

    // Object containing selections for all pricebook levels
    @track pricebookSelected;

    // History of pricebookSelected
    @track pricebookSelectedHistory = [];

    // All products in system
    @track products;

    // Object containing selections for all product levels
    @track productSelected;

    // History of productSelected
    @track productSelectedHistory = [];

    // System Settings
    @track systemSettings;

    get settingsLoaded() {
        return this.systemSettings !== undefined;
    }

    // // On Mount
    // connectedCallback() {
    //     // Query System Settings since default tab
    //     this.reloadSystemSettings();
    // }

    // Reload System Settings data
    async reloadSystemSettings(event) {

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
        this.systemSettings;

        // Get data
        try {
            this.systemSettings = await getSystemSettings();
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to retrieve the system settings',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Playbooks tab clicked
    playbooksClick() {
        if (this.playbooks === undefined) {
            this.reloadPlaybooks();
        }
    }

    // Reload playbook data
    async reloadPlaybooks(event) {

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
        this.playbooks = [];

        // Get data
        try {
            this.playbooks = await getPlaybooks();

            // Set selected
            if (event) {
                if (event.detail) {
                    if (event.detail.selected) {
                        this.playbookSelected = event.detail.selected;
                    }
                }
            }
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to retrieve the playbooks',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Cross tab select update
    crossPlaybookSelectionUpdate(event) {
        let tabSet = this.template.querySelector('lightning-tabset');
        tabSet.activeTabValue = 'playbooks';
        this.updatePlaybookSelections(event);
    }

    // Select Event
    updatePlaybookSelections(event) {
        this.playbookSelected = event.detail.selected;
        let addHistory = true;
        if (this.playbookSelectedHistory.length > 0 &&
            JSON.stringify(this.playbookSelectedHistory[this.playbookSelectedHistory.length - 1]) === JSON.stringify(event.detail.selected)    
        ) {
            addHistory = false;
        }
        if (event.detail.selected.tabChange !== undefined &&
            event.detail.selected.tabChange === false    
        ) {
            addHistory = false;
        }
        if (addHistory === true) {
            this.playbookSelectedHistory.push(event.detail.selected);
        }
    }

    // Undo Event
    undoPlaybookSelections(event) {
        let updatedPlaybookSelectedHistory = JSON.parse(JSON.stringify(this.playbookSelectedHistory));
        updatedPlaybookSelectedHistory.pop();
        this.playbookSelectedHistory = updatedPlaybookSelectedHistory;
        if (updatedPlaybookSelectedHistory.length > 0) {
            this.playbookSelected = updatedPlaybookSelectedHistory[updatedPlaybookSelectedHistory.length - 1];
        } else {
            this.playbookSelected = {};
        }
    }

    // Pricebooks tab clicked
    pricebooksClick() {
        if (this.pricebooks === undefined) {
            this.reloadPricebooks();
        }
    }

    // Reload pricebook data
    async reloadPricebooks(event) {

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
        this.pricebooks = [];

        // Get data
        try {
            this.pricebooks = await getPricebooks();

            // Set selected
            if (event) {
                if (event.detail) {
                    if (event.detail.selected) {
                        this.pricebookSelected = event.detail.selected;
                    }
                }
            }
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to retrieve the pricebooks',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Select Event
    updatePricebookSelections(event) {
        this.pricebookSelected = event.detail.selected;
        let addHistory = true;
        if (this.pricebookSelectedHistory.length > 0 &&
            JSON.stringify(this.pricebookSelectedHistory[this.pricebookSelectedHistory.length - 1]) === JSON.stringify(event.detail.selected)    
        ) {
            addHistory = false;
        }
        if (event.detail.selected.tabChange !== undefined &&
            event.detail.selected.tabChange === false    
        ) {
            addHistory = false;
        }
        if (addHistory === true) {
            this.pricebookSelectedHistory.push(event.detail.selected);
        }
    }

    // Undo Event
    undoPricebookSelections(event) {
        let updatedPricebookSelectedHistory = JSON.parse(JSON.stringify(this.pricebookSelectedHistory));
        updatedPricebookSelectedHistory.pop();
        this.pricebookSelectedHistory = updatedPricebookSelectedHistory;
        if (updatedPricebookSelectedHistory.length > 0) {
            this.pricebookSelected = updatedPricebookSelectedHistory[updatedPricebookSelectedHistory.length - 1];
        } else {
            this.pricebookSelected = {};
        }
    }

    // Products tab clicked
    productsClick() {
        if (this.products === undefined) {
            this.reloadProducts();
        }
    }

    // Reload product data
    async reloadProducts(event) {

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
        this.products = [];

        // Get data
        try {
            this.products = await getProducts();

            // Set selected
            if (event) {
                if (event.detail) {
                    if (event.detail.selected) {
                        this.productSelected = event.detail.selected;
                    }
                }
            }
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to retrieve the products',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Select Event
    updateProductSelections(event) {
        this.productSelected = event.detail.selected;
        let addHistory = true;
        if (this.productSelectedHistory.length > 0 &&
            JSON.stringify(this.productSelectedHistory[this.productSelectedHistory.length - 1]) === JSON.stringify(event.detail.selected)    
        ) {
            addHistory = false;
        }
        if (event.detail.selected.tabChange !== undefined &&
            event.detail.selected.tabChange === false    
        ) {
            addHistory = false;
        }
        if (addHistory === true) {
            this.productSelectedHistory.push(event.detail.selected);
        }
    }

    // Undo Event
    undoPricebookSelections(event) {
        let updatedProductSelectedHistory = JSON.parse(JSON.stringify(this.productSelectedHistory));
        updatedProductSelectedHistory.pop();
        this.productSelectedHistory = updatedProductSelectedHistory;
        if (updatedProductSelectedHistory.length > 0) {
            this.productSelected = updatedProductSelectedHistory[updatedProductSelectedHistory.length - 1];
        } else {
            this.productSelected = {};
        }
    }
}