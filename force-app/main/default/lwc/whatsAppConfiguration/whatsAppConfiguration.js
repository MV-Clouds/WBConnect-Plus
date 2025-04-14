import { LightningElement, track } from 'lwc';
import saveWhatsAppConfiguration from '@salesforce/apex/WhatsAppConfigurationController.saveConfiguration';
import getWhatsAppConfiguration from '@salesforce/apex/WhatsAppConfigurationController.getConfiguration';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo';
import homePageBGImg from '@salesforce/resourceUrl/homePageBG';

export default class WhatsAppConfiguration extends LightningElement {
    @track wBAccountIdValue = '';
    @track accessTokenValue = '';
    @track phoneNoIdValue = '';
    @track appIdValue = '';
    @track wBAccountId = '';
    @track accessToken = '';
    @track phoneNoId = '';
    @track appId = '';
    @track WBConnectLogo = logoImg;
    backgroundStyle = `background-image: url(${homePageBGImg});`;
    @track isEditing = false;
    @track isDisabled = true;
    @track isFirstTime = false;

    connectedCallback(){
        getWhatsAppConfiguration()
        .then(result => {
            if (result != null) {
                this.wBAccountIdValue = result.Business_Account_Id__c;
                this.accessTokenValue = result.Access_Token__c;
                this.phoneNoIdValue = result.Phone_Number_Id__c;
                this.appIdValue = result.Application_Id__c;
                this.wBAccountId = '*'.repeat(this.wBAccountIdValue.length);
                this.accessToken = '*'.repeat(this.accessTokenValue.length);
                this.phoneNoId = '*'.repeat(this.phoneNoIdValue.length);
                this.appId = '*'.repeat(this.appIdValue.length);
                if(this.wBAccountIdValue != '' && this.accessTokenValue != '' && this.phoneNoIdValue != '' && this.appIdValue != ''){
                    this.isDisabled = true;
                    this.isEditing = false;
                } else {
                    this.isDisabled = false;
                    this.isFirstTime = true;
                    this.isEditing = false;
                }
                    
                console.log('result values:- ',this.wBAccountIdValue, this.accessTokenValue, this.phoneNoIdValue, this.appIdValue);
            }
        }).catch(error => {
            console.log(error);
        })
    }

    handleCancel() {
        this.wBAccountId = '*'.repeat(this.wBAccountIdValue.length);
        this.accessToken = '*'.repeat(this.accessTokenValue.length);
        this.phoneNoId = '*'.repeat(this.phoneNoIdValue.length);
        this.appId = '*'.repeat(this.appIdValue.length);
        this.isEditing = false;
        this.isDisabled = true;
    }
    
    handleEdit(){
        this.wBAccountId = this.wBAccountIdValue;
        this.accessToken = this.accessTokenValue;
        this.phoneNoId = this.phoneNoIdValue
        this.appId = this.appIdValue;
        this.isDisabled = false;
        this.isEditing = true;
    }

    handleInput(event) {
        if(event.target.name == 'WBAccountId'){
            this.wBAccountId = event.target.value;
            this.wBAccountId = this.wBAccountId.replaceAll(' ','');
            this.wBAccountIdValue = this.wBAccountId;
        } if(event.target.name == 'AccessToken'){
            this.accessToken = event.target.value;
            this.accessToken = this.accessToken.replaceAll(' ','');
            this.accessTokenValue = this.accessToken;
        } if(event.target.name == 'PhoneNumberId'){
            this.phoneNoId = event.target.value;
            this.phoneNoId = this.phoneNoId.replaceAll(' ','');
            this.phoneNoIdValue = this.phoneNoId;
        } if(event.target.name == 'WBAppId'){
            this.appId = event.target.value;
            this.appId = this.appId.replaceAll(' ','');
            this.appIdValue = this.appId;
        }
    }

    // Similar handlers for other fields

    handleSave() {
        // Basic validation (add more as needed)
        if (!this.wBAccountId || !this.accessToken || !this.phoneNoId|| !this.appId) {
            this.showMessageToast('Error', 'Please Enter value for all the Fields', 'error');
            return;
        }

        // Handle saving logic (e.g., API calls, data storage)
        console.log('Saved values:', this.wBAccountId, this.accessToken, this.phoneNoId, this.appId);
        saveWhatsAppConfiguration({WBAccountId : this.wBAccountId, AppId : this.appId , AccessToken : this.accessToken, PhoneNumberId : this.phoneNoId})
        .then(() => {
            this.showMessageToast('Success', 'Saved successfully', 'success');
            this.wBAccountId = '*'.repeat(this.wBAccountIdValue.length);
            this.accessToken = '*'.repeat(this.accessTokenValue.length);
            this.phoneNoId = '*'.repeat(this.phoneNoIdValue.length);
            this.appId = '*'.repeat(this.appIdValue.length);
            this.isDisabled = true;
            this.isEditing = false;
            this.isFirstTime = false;
        }).catch(error => {
            this.showMessageToast('Error', error?.body?.message, 'error');
        });
    }

    showMessageToast(title, message, status){
        const messageContainer = this.template.querySelector('c-message-popup')
        messageContainer?.showMessageToast({
            status: status,
            title: title,
            message : message
        });
    }

    // Similar handlers for other info icons
}