import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class CPQ_AdminPlaybookForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Playbook
    @api playbook;

    // Playbook Id
    @api playbookId;

    // Proposal Header Type
    @track headerType;

    // Product Summary Columns
    @track prodSummaryColumns = 'Product_Name;Start_Date;End_Date;Quantity;Unit_Price;List_Price;Total_Price';

    // Entitlement Summary Columns
    @track entSummaryColumns = 'Product_Name__c;Start_Date__c;End_Date__c;Quantity__c;Unit_Price__c;List_Price__c;Total_Price__c';

    // Default Term
    @track defaultTerm = 12;

    // Spinner
    @track loading = false;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this playbook?';

    // On Mount
    connectedCallback() {
        if (this.playbook !== undefined) {
            this.headerType = this.playbook.playbookInfo.Proposal_Header_Type__c;
            this.prodSummaryColumns = this.playbook.playbookInfo.Product_Summary_Columns__c;
            this.entSummaryColumns = this.playbook.playbookInfo.Entitlement_Summary_Columns__c;
            this.defaultTerm = this.playbook.playbookInfo.Default_Term_in_Months__c;
        }
    }

    get acceptedFormats() {
        return ['.jpeg', '.jpg', '.png'];
    }

    get existingHeaderPath() {
        if (this.playbook !== undefined) {
            if (this.playbook.playbookInfo.AttachedContentDocuments !== undefined &&
                this.playbook.playbookInfo.AttachedContentDocuments.length > 0
            ) {
                return '/sfc/servlet.shepherd/version/download/' + this.playbook.playbookInfo.AttachedContentDocuments[0].ContentDocument.LatestPublishedVersionId;
            } else {
                return '';
            }
        } else {
            return '';
        }
    }

    get hasExistingHeaderImage() {
        if (this.playbook !== undefined) {
            if (this.playbook.playbookInfo.AttachedContentDocuments !== undefined) {
                return this.playbook.playbookInfo.AttachedContentDocuments.length > 0;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    get hasId() {
        return this.playbookId !== undefined;
    }

    get headerText() {
        return this.headerType === 'Text';
    }

    get inactivePricebook() {
        let inactivePricebook = false;
        if (this.playbook !== undefined &&
            this.playbook.playbookInfo.Pricebook__c !== undefined &&
            this.playbook.playbookInfo.Pricebook__r.IsActive === false    
        ) {
            inactivePricebook = true;
        }
        return inactivePricebook;
    }

    get showImageAttach() {
        return (this.headerType === 'Image' && this.playbook !== undefined);
    }

    get showImagePostCreate() {
        return (this.headerType === 'Image' && this.playbook === undefined);
    }

    // Cancel delete
    cancelDelete() {
        this.showConfirmDelete = false;
    }
    
    // Confirmation received to delete
    async confirmDelete() {
        this.showConfirmDelete = false;

        this.loading = true;

        try {
            await deleteRecords({
                records: [this.playbook.playbookInfo]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Playbook was deleted',
                            variant: 'success'
                        },
                        selected: {
                            playbook: undefined,
                            playbookName: undefined,
                            playbookTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the playbook',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deletePlaybook() {
        this.showConfirmDelete = true;
    }

    // Header Type Change
    headerTypeChange(event) {
        this.headerType = event.target.value;
    }

    // Product Summary Columns Change
    productColumnChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.prodSummaryColumns = cols;
    }

    // Entitlement Summary Columns Change
    entitlementColumnChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.entSummaryColumns = cols;
    }

    // Saved Playbook
    savedPlaybook(event) {

        this.loading = false;

        // Send saved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Playbook was saved',
                        variant: 'success'
                    },
                    selected: {
                        playbook: event.detail.id
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the playbook',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // File Upload
    async handleUploadFinished(event) {

        this.loading = true;

        if (this.playbook.playbookInfo.AttachedContentDocuments !== undefined &&
            this.playbook.playbookInfo.AttachedContentDocuments.length > 0    
        ) {

            try {
                await deleteRecords({
                    records: this.playbook.playbookInfo.AttachedContentDocuments
                });

                // Send saved event to parent
                const savedEvent = new CustomEvent(
                    'childsaved', {
                        detail: {
                            toast: {
                                title: 'Success!',
                                message: 'Playbook Header Image was saved',
                                variant: 'success'
                            },
                            selected: {
                                playbook: this.playbookId
                            }
                        }
                    });
                this.dispatchEvent(savedEvent);
            } catch (e) {
                this.template.querySelector('c-error-modal').showError(
                    {
                        title: 'An error occurred while trying to delete the existing image',
                        body: JSON.stringify(e),
                        forceRefresh: true
                    }
                );
            }
        } else {
            // Send saved event to parent
            const savedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Playbook Header Image was saved',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.playbookId
                        }
                    }
                });
            this.dispatchEvent(savedEvent);
        }

        this.loading = false;
    }

    // Clone record
    async clonePlaybook() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.playbook.playbookInfo.Id,
                objectAPI: 'CPQ_Playbook__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Playbook was cloned',
                            variant: 'success'
                        },
                        selected: {
                            playbook: newRecord.Id,
                            playbookName: newRecord.Name,
                            playbookTab: 'playbook'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the playbook',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Submit
    submitPlaybook() {
        this.loading = true;
    }

    cancel() {
        // Send cancel event to parent
        const cancelEvent = new CustomEvent(
            'cancel'
        );
        this.dispatchEvent(cancelEvent);
    }
}