import { LightningElement, api, track } from 'lwc';

export default class ConfirmationModal extends LightningElement {

    // Theme variant
    @api variant = 'warning';

    // Theme texture
    @api addTexture = false;

    // Title
    @api title = '';

    // Body Text
    @api body = '';

    // Text for confirmation button
    @api confirmButtonTitle = '';

    // Text for cancel button
    @api cancelButtonTitle = '';

    // CSS for header with theme variant
    get headerCSS() {
        let headerCSS = 'slds-modal__header';
        if (this.variant === 'warning') {
            headerCSS += ' slds-theme_warning';
        } else if (this.variant === 'info') {
            headerCSS += ' slds-theme_info';
        } else if (this.variant === 'error') {
            headerCSS += ' slds-theme_error';
        } else if (this.variant === 'success') {
            headerCSS += ' slds-theme_success';
        } else if (this.variant === 'shade') {
            headerCSS += ' slds-theme_shade';
        } else if (this.variant === 'inverse') {
            headerCSS += ' slds-theme_inverse';
        } else if (this.variant === 'alt-inverse') {
            headerCSS += ' slds-theme_alt-inverse';
        } else if (this.variant === 'default') {
            headerCSS += ' slds-theme_default';
        }

        if (this.addTexture === true) {
            headerCSS += ' slds-theme_alert-texture';
        }

        return headerCSS;
    }

    // Confirm Button variant
    get confirmButtonVariant() {
        if (this.variant === 'warning') {
            return 'destructive-text';
        } else if (this.variant === 'info') {
            return 'brand';
        } else if (this.variant === 'error') {
            return 'destructive';
        } else if (this.variant === 'success') {
            return 'success';
        } else if (this.variant === 'shade') {
            return 'brand';
        } else if (this.variant === 'inverse') {
            return 'brand';
        } else if (this.variant === 'alt-inverse') {
            return 'brand';
        } else if (this.variant === 'default') {
            return 'brand';
        }
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
                detail: {}
            });
        this.dispatchEvent(confirmEvent);
    }
}