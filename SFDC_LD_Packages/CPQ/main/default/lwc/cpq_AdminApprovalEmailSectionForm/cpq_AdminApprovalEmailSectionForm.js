import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

// Insert Method
import insertRecords from '@salesforce/apex/cpq_AdminContainerClass.insertRecords';

export default class CPQ_AdminApprovalEmailSectionForm extends LightningElement {

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
    @track ansColumns;

    // Color value trackers
    @track headerColor;
    @track entryColor;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this email section?';

    // On Mount
    connectedCallback() {
        if (this.section !== undefined) {
            this.sectionType = this.section.sectionInfo.Section_Type__c;
            this.ansColumns = this.section.sectionInfo.Answer_Table_Questions__c;
            this.headerColor = this.section.sectionInfo.Table_Headers_Font_Color__c;
            this.entryColor = this.section.sectionInfo.Table_Entries_Font_Color__c;
        }
    }

    get hasId() {
        return this.section !== undefined;
    }

    get approvalId() {
        return this.selected.approval.split('-')[0];
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
        return ['Text - 1 column', 'Text - 2 columns (1:1)', 'Text - 2 columns (1:2)', 'Text - 2 columns (2:1)', 'Text - 3 columns', 'Image and Text - 2 columns (1:1)', 'Image and Text - 2 columns (1:2)', 'Image and Text - 2 columns (1:3)', 'Record Table', 'Answer Table - 1 column','Answer Table - 2 columns'].includes(this.sectionType);
    }

    get showTextBlock2() {
        return ['Text - 2 columns (1:1)', 'Text - 2 columns (1:2)', 'Text - 2 columns (2:1)', 'Text - 3 columns'].includes(this.sectionType);
    }

    get showTextBlock3() {
        return ['Text - 3 columns'].includes(this.sectionType);
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
                            message: 'Email Section was deleted',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'approvals',
                            approval: this.selected.approval,
                            approvalName: this.selected.approvalName,
                            approvalTab: 'emailSections',
                            emailSection: undefined,
                            emailSectionName: undefined,
                            emailSectionTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the email section',
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
                        message: 'Email Section was saved',
                        variant: 'success'
                    },
                    selected: {
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'approvals',
                        approval: this.selected.approval,
                        approvalName: this.selected.approvalName,
                        approvalTab: 'emailSections',
                        emailSection: event.detail.id,
                        emailSectionTab: 'section'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the email section',
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
                objectAPI: 'CPQ_Playbook_Approval_Email_Section__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Email Section was cloned',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'approvals',
                            approval: this.selected.approval,
                            approvalName: this.selected.approvalName,
                            approvalTab: 'emailSections',
                            emailSection: newRecord.id,
                            emailSectionName: newRecord.Name,
                            emailSectionTab: 'section'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the email section',
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

        let linkCreated = false;
        try {
            await insertRecords({
                records: [
                    {
                        sobjectType: 'ContentDistribution',
                        Name: event.detail.files[0].name,
                        ContentVersionId: event.detail.files[0].contentVersionId,
                        PreferencesAllowViewInBrowser: true
                    }
                ]
            });

            linkCreated = true;

        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to create the public link',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        if (linkCreated === true) {
            if (this.section.sectionInfo.AttachedContentDocuments !== undefined &&
                this.section.sectionInfo.AttachedContentDocuments.length > 0    
            ) {
                try {
                    await deleteRecords({
                        records: this.section.sectionInfo.AttachedContentDocuments
                    });

                    // Send saved event to parent
                    const savedEvent = new CustomEvent(
                        'childsaved', {
                            detail: {
                                toast: {
                                    title: 'Success!',
                                    message: 'Email Section Image was saved',
                                    variant: 'success'
                                },
                                selected: {
                                    playbook: this.selected.playbook,
                                    playbookName: this.selected.playbookName,
                                    playbookTab: 'approvals',
                                    approval: this.selected.approval,
                                    approvalName: this.selected.approvalName,
                                    approvalTab: 'emailSections',
                                    emailSection: this.selected.emailSection,
                                    emailSectionName: this.selected.emailSectionName,
                                    emailSectionTab: 'section'
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
                    'childsaved', {
                        detail: {
                            toast: {
                                title: 'Success!',
                                message: 'Proposal Section Image was saved',
                                variant: 'success'
                            },
                            selected: {
                                playbook: this.selected.playbook,
                                playbookName: this.selected.playbookName,
                                playbookTab: 'approvals',
                                approval: this.selected.approval,
                                approvalName: this.selected.approvalName,
                                approvalTab: 'emailSections',
                                emailSection: this.selected.emailSection,
                                emailSectionName: this.selected.emailSectionName,
                                emailSectionTab: 'section'
                            }
                        }
                    });
                this.dispatchEvent(savedEvent);
            }
        }

        this.loading = false;
    }

    // Submit
    submitSection() {
        this.loading = true;
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

    // Header Color Change
    headerColorChange(event) {
        this.headerColor = event.target.value;
    }

    // Entry Color Change
    entryColorChange(event) {
        this.entryColor = event.target.value;
    }

}