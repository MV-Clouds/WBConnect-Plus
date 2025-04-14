import { LightningElement, track } from 'lwc';
import getAllAutomations from '@salesforce/apex/AutomationConfigController.getAllAutomations';
import getTemplates from '@salesforce/apex/AutomationConfigController.getTemplates';
import saveAutomations from '@salesforce/apex/AutomationConfigController.saveAutomations';
// import updateAutomations from '@salesforce/apex/AutomationConfigController.updateAutomations';
import deleteAutomations from '@salesforce/apex/AutomationConfigController.deleteAutomations';
import homePageBGImg from '@salesforce/resourceUrl/homePageBG';
import Edit_Button from '@salesforce/resourceUrl/Edit_Button';
import Delete_Button from '@salesforce/resourceUrl/Delete_Button';
import emptyState from '@salesforce/resourceUrl/emptyState';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { NavigationMixin } from 'lightning/navigation';

export default class AutomationConfig extends LightningElement {
    @track automationData = [];
    @track originalAutomationData = [];
    @track isLoading = true;
    @track isModalOpen = false;
    @track templateOptions = [];
    @track name = '';
    @track description = '';
    @track selectedTemplateId = '';
    @track recordId = null;

    // @track isEditMode = false;
    @track backgroundStyle = `background-image: url(${homePageBGImg});`;
    @track editButton = Edit_Button;
    @track deleteButton = Delete_Button;
    @track emptyState = emptyState;
    
    connectedCallback() {
        this.fetchAutomations();
        this.fetchTemplates();
    }

    /** 
    * Method Name: fetchAutomations 
    * @description: fetches all automation records to display on the UI  
    * Date: 27/03/2025
    * Created By: Kavya Trivedi
    */
    fetchAutomations() {
        this.isLoading = true;
        getAllAutomations()
            .then(data => {
                this.originalAutomationData = data.map((record, index) => ({
                    id: record.Id,
                    srNo: index + 1,
                    name: record.Name,
                    description: record.Description__c,
                    template: record.Template__r ? record.Template__r.Template_Name__c : '',
                    templateType: record.Template__r ? record.Template__r.Template_Type__c : ''
                }));
                console.log('this.automationData =', JSON.stringify(this.originalAutomationData));
                this.automationData = [...this.originalAutomationData];
            })
            .catch(error => {
                console.error('Error fetching automation records:', error);
                this.automationData = [];
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    /** 
    * Method Name: fetchTemplates 
    * @description: fetches all templates for picklist  
    * Date: 27/03/2025
    * Created By: Kavya Trivedi
    */
    fetchTemplates() {
        getTemplates()
            .then(data => {
                this.templateOptions = data.map(template => ({
                    label: template.Template_Name__c,
                    value: template.Id
                }));
            })
            .catch(error => {
                console.error('Error fetching templates:', error);
            });
    }

    /**
    * Method Name: handleChange
    * @description: Updates fields based on field change
    * Date: 27/03/2025
    * Created By: Kavya Trivedi
    */
    handleChange(event) {
        const fieldName = event.target.label;
        if (fieldName === 'Name') {
            this.name = event.target.value;
        } else if (fieldName === 'Description') {
            this.description = event.target.value || '';
        } else if (fieldName === 'Template') {
            this.selectedTemplateId = event.target.value;
        }
    }

    /**
    * Method Name: handleSave 
    * @description: Saves automation records based on create/edit mode  
    * Date: 27/03/2025
    * Created By: Kavya Trivedi
    */
    handleSave() {
        if (!this.name || !this.selectedTemplateId) {
            this.showToast('Error', 'Please fill necessary fields before saving.', 'error');
            return;
        }

        const automationRecord = {
            // Id: this.isEditMode ? this.recordId : undefined,
            Name: this.name,
            Description__c: this.description,
            Template__c: this.selectedTemplateId
        };

        console.log('Automation Record:', JSON.stringify(automationRecord));

        // const apexMethod = this.isEditMode ? updateAutomations : saveAutomations;

        saveAutomations({ automations: [automationRecord] })
        .then((result) => {
            this.showToast('Success', `Automation saved successfully.`, 'success');
            this.closeModal();

            const savedRecordId = result[0].Id;

            getAllAutomations()
            .then(data => {
                this.originalAutomationData = data.map((record, index) => ({
                    id: record.Id,
                    srNo: index + 1,
                    name: record.Name,
                    description: record.Description__c,
                    template: record.Template__r ? record.Template__r.Template_Name__c : '',
                    templateType: record.Template__r ? record.Template__r.Template_Type__c : ''
                }));
                // console.log('this.automationData =', JSON.stringify(this.originalAutomationData));
                this.automationData = [...this.originalAutomationData];

                console.log('this.automationData in handleSave =', JSON.stringify(this.automationData));

                const savedAutomation = this.automationData.find(auto => auto.id === savedRecordId);
                console.log('savedRecordId:', savedRecordId, 'savedAutomation:', JSON.stringify(savedAutomation));

                if (savedAutomation) {
                    // let cmpDef = {
                    //     componentDef : 'c:automationPath',
                    //     attributes: {
                    //         recordId: savedAutomation.id,
                    //         templateType: savedAutomation.templateType
                    //     }
                    // };
                    console.log('Record ID:', savedAutomation.id, 'Template Type:', savedAutomation.templateType);

                    // let encodedDef = btoa(JSON.stringify(cmpDef));
                    try {
                        
                        this.dispatchEvent(new CustomEvent('navigate', {
                            detail: {
                                page: 'path',
                                recordId: savedAutomation.id,
                                templateType: savedAutomation.templateType
                            }
                        }));
                    } catch (error) {
                        console.error('Error dispatching event:', error);
                    }
                    console.log('this.dispatchEvent', this.dispatchEvent);
                } else {
                    console.warn('Saved automation not found in automationData.');
                }
            })
            .catch(error => {
                console.error('Error fetching automation records:', error);
                this.automationData = [];
            })
            .finally(() => {
                this.isLoading = false;
            });
        })
        .catch(error => {
            const message = error.body && error.body.message ? error.body.message : JSON.stringify(error);
            console.error(`Error saving record:`, message);
            this.showToast('Error', `Failed to save automation: ${message}`, 'error');
        });        
    }

    get modalTitle() {
        return 'New Automation';
    }

    /**
    * Method Name: handleSearch 
    * @description: Searches automation records  
    * Date: 27/03/2025
    * Created By: Kavya Trivedi
    */
    handleSearch(event) {
        console.log('Search term:', event.target.value);
        const searchTerm = event.target.value.toLowerCase().trim();
        this.automationData = this.originalAutomationData.filter(auto =>
            (auto.name || '').toLowerCase().includes(searchTerm) ||
            (auto.description || '').toLowerCase().includes(searchTerm) ||
            (auto.template || '').toLowerCase().includes(searchTerm)
        );
        console.log('Filtered Data:', this.automationData);
    }

    handleNew() {
        this.isModalOpen = true;
        this.name = '';
        this.description = '';
        this.selectedTemplateId = '';
        // this.isEditMode = false;
    }

    closeModal() {
        this.isModalOpen = false;
        // this.isEditMode = false;
        this.recordId = null;
        this.name = '';
        this.description = '';
        this.selectedTemplateId = '';
    }

    /**
    * Method Name: handleEdit 
    * @description: Opens edit modal for selected automation record  
    * Date: 27/03/2025
    * Created By: Kavya Trivedi
    */
    handleEdit(event) {
        const recordId = event.currentTarget.dataset.id;
        const templateType = event.currentTarget.dataset.templateType;
        // const selectedRecord = this.automationData.find(auto => auto.id === recordId);

        // if (selectedRecord) {
        //     this.isEditMode = true;
        //     this.isModalOpen = true;
        //     this.recordId = recordId;
        //     this.name = selectedRecord.name;
        //     this.description = selectedRecord.description;
        //     this.selectedTemplateId = this.templateOptions.find(option => option.label === selectedRecord.template)?.value || '';
        // }

        // let cmpDef = {
        //     componentDef : 'c:automationPath',
        //     attributes: {
        //         recordId: recordId,
        //         templateType: templateType
        //     }
        // };
        console.log('Record ID:', recordId, 'Template Type:', templateType);
        // let encodedDef = btoa(JSON.stringify(cmpDef));
        try {
            const event1 = new CustomEvent('navigate', {
                detail: {
                    page: 'path',
                    recordId: recordId,
                    templateType: templateType
                }
            });
            this.dispatchEvent(event1);
        } catch (error) {
            console.error('Error dispatching event:', error);
        }
        console.log('this.dispatchEvent', this.dispatchEvent);
    }

    /**
    * Method Name: handleDelete 
    * @description: Deletes selected automation record
    * Date: 27/03/2025
    * Created By: Kavya Trivedi
    */
    handleDelete(event) {
        const recordId = event.currentTarget.dataset.id;
        if (!recordId) return;
    
        deleteAutomations({ recordIds: [recordId] })
        .then(() => {
            this.showToast('Success', 'Automation deleted successfully.', 'success');
            this.fetchAutomations();
        })
        .catch(error => {
            console.error('Error deleting record:', error);
            this.showToast('Error', 'Error deleting automation.', 'error');
        });
    }    

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}