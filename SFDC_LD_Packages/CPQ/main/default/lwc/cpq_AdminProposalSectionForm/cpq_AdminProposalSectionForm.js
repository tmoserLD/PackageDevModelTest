import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class Cpq_AdminProposalSectionForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Section
    @api section

    // Section Id
    @api sectionId;

    // Seciton Type
    @track sectionType;

    // Spinner
    @track loading = false;

    // Object containing selections for all levels
    @api selected;

    // Picklist value trackers
    @track input1Columns;
    @track input2Columns;
    @track input3Columns;
    @track ansColumns;

    // Color value trackers
    @track inputColor;
    @track headerColor;
    @track entryColor;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this proposal section?';

    // On Mount
    connectedCallback() {
        if (this.section !== undefined) {
            this.sectionType = this.section.sectionInfo.Section_Type__c;
            this.input1Columns = this.section.sectionInfo.Inputs_Column_1__c;
            this.input2Columns = this.section.sectionInfo.Inputs_Column_2__c;
            this.input3Columns = this.section.sectionInfo.Inputs_Column_3__c;
            this.ansColumns = this.section.sectionInfo.Answer_Table_Questions__c;
            this.inputColor = this.section.sectionInfo.Inputs_Font_Color__c;
            this.headerColor = this.section.sectionInfo.Table_Headers_Font_Color__c;
            this.entryColor = this.section.sectionInfo.Table_Entries_Font_Color__c;
        }
    }

    get hasId() {
        return this.section !== undefined;
    }

    get playbookId() {
        return this.selected.playbook.split('-')[0];
    }

    get acceptedFormats() {
        return ['.jpeg', '.jpg', '.png'];
    }

    get existingPath() {
        if (this.section !== undefined) {
            if (this.section.sectionInfo.AttachedContentDocuments !== undefined &&
                this.section.sectionInfo.AttachedContentDocuments.length > 0
            ) {
                return '/sfc/servlet.shepherd/version/download/' + this.section.sectionInfo.AttachedContentDocuments[0].ContentDocument.LatestPublishedVersionId;
            } else {
                return '';
            }
        } else {
            return '';
        }
    }

    get hasExistingImage() {
        if (this.section !== undefined) {
            if (this.section.sectionInfo.AttachedContentDocuments !== undefined) {
                return this.section.sectionInfo.AttachedContentDocuments.length > 0;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    get showImageAttach() {
        return (['Image - 1 column', 'Image and Text - 2 columns (1:1)', 'Image and Text - 2 columns (1:2)', 'Image and Text - 2 columns (1:3)'].includes(this.sectionType) && this.section !== undefined);
    }

    get showImagePostCreate() {
        return (['Image - 1 column', 'Image and Text - 2 columns (1:1)', 'Image and Text - 2 columns (1:2)', 'Image and Text - 2 columns (1:3)'].includes(this.sectionType) && this.section === undefined);
    }

    get showTextBlock1() {
        return ['Text - 1 column', 'Text - 2 columns (1:1)', 'Text - 2 columns (1:2)', 'Text - 2 columns (2:1)', 'Text - 3 columns', 'Image and Text - 2 columns (1:1)', 'Image and Text - 2 columns (1:2)', 'Image and Text - 2 columns (1:3)', 'Record Table', 'Answer Table - 1 column','Answer Table - 2 columns', 'User Input - 1 column', 'User Input - 2 columns', 'User Input - 3 columns'].includes(this.sectionType);
    }

    get showTextBlock2() {
        return ['Text - 2 columns (1:1)', 'Text - 2 columns (1:2)', 'Text - 2 columns (2:1)', 'Text - 3 columns', 'User Input - 2 columns', 'User Input - 3 columns'].includes(this.sectionType);
    }

    get showTextBlock3() {
        return ['Text - 3 columns', 'User Input - 3 columns'].includes(this.sectionType);
    }

    get showInputs1() {
        return ['User Input - 1 column', 'User Input - 2 columns', 'User Input - 3 columns'].includes(this.sectionType);
    }

    get showInputs2() {
        return ['User Input - 2 columns', 'User Input - 3 columns'].includes(this.sectionType);
    }

    get showInputs3() {
        return ['User Input - 3 columns'].includes(this.sectionType);
    }

    get showTable() {
        return ['Record Table','Answer Table - 1 column','Answer Table - 2 columns'].includes(this.sectionType);
    }

    get showRecordTable() {
        return ['Record Table'].includes(this.sectionType);
    }

    get showAnsTable() {
        return ['Answer Table - 1 column','Answer Table - 2 columns'].includes(this.sectionType);
    }

    // Section Type Change
    sectionTypeChange(event) {
        this.sectionType = event.target.value;
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
                records: [this.section.sectionInfo]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Proposal Section was deleted',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'proposalSections',
                            proposalSection: undefined,
                            proposalSectionName: undefined,
                            proposalSectionTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the proposal section',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteSection() {
        this.showConfirmDelete = true;
    }

    // Saved Section
    savedSection(event) {

        this.loading = false;

        // Send childsaved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Proposal Section was saved',
                        variant: 'success'
                    },
                    selected: {
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'proposalSections',
                        proposalSection: event.detail.id,
                        proposalSectionTab: 'section'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the proposal section',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Clone record
    async cloneSection() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.section.sectionInfo.Id,
                objectAPI: 'CPQ_Playbook_Proposal_Section__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Proposal Section was cloned',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'proposalSections',
                            proposalSection: newRecord.Id,
                            proposalSectionName: newRecord.Name,
                            proposalSectionTab: 'section'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the proposal section',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    cancel() {
        // Send cancel event to parent
        const cancelEvent = new CustomEvent(
            'cancel'
        );
        this.dispatchEvent(cancelEvent);
    }

    // File Upload
    async handleUploadFinished(event) {

        this.loading = true;

        if (this.section.sectionInfo.AttachedContentDocuments !== undefined &&
            this.section.sectionInfo.AttachedContentDocuments.length > 0    
        ) {
            try {
                await deleteRecords({
                    records: this.section.sectionInfo.AttachedContentDocuments
                });

                // Send saved event to parent
                const savedEvent = new CustomEvent(
                    'saved', {
                        detail: {
                            toast: {
                                title: 'Success!',
                                message: 'Proposal Section Image was saved',
                                variant: 'success'
                            },
                            selected: {
                                playbook: this.selected.playbook,
                                playbookName: this.selected.playbookName,
                                playbookTab: 'proposalSections',
                                proposalSection: event.detail.id,
                                proposalSectionTab: 'proposal'
                            }
                        }
                    });
                this.dispatchEvent(savedEvent);
            } catch (e) {
                this.template.querySelector('c-error-modal').showError(
                    {
                        title: 'An error occurred while trying to delete the existing image',
                        body: JSON.stringify(e),
                        forceRefresh: false
                    }
                );
            }
        } else {
            // Send saved event to parent
            const savedEvent = new CustomEvent(
                'saved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Proposal Section Image was saved',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'proposalSections',
                            proposalSection: event.detail.id,
                            proposalSectionTab: 'proposal'
                        }
                    }
                });
            this.dispatchEvent(savedEvent);
        }

        this.loading = false;
    }

    // Submit
    submitSection() {
        this.loading = true;
    }

    // Input 1 Columns Change
    input1ColumnsChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.input1Columns = cols;
    }

    // Input 2 Columns Change
    input2ColumnsChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.input2Columns = cols;
    }

    // Input 3 Columns Change
    input3ColumnsChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.input3Columns = cols;
    }

    // QLI Columns Change
    qliColumnsChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.qliColumns = cols;
    }

    // Entitlement Columns Change
    entColumnsChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.entColumns = cols;
    }

    // Answer Columns Change
    ansColumnsChange(event) {
        let cols = '';
        if (event.detail.length > 0) {
            let selectedOptions = [];
            event.detail.forEach(function(option) {
                selectedOptions.push(option);
            });
            cols = selectedOptions.join(';');
        }

        this.ansColumns = cols;
    }

    // Input Color Change
    inputColorChange(event) {
        this.inputColor = event.target.value;
    }

    // Header Color Change
    headerColorChange(event) {
        this.headerColor = event.target.value;
    }

    // Entry Color Change
    entryColorChange(event) {
        this.entryColor = event.target.value;
    }

}