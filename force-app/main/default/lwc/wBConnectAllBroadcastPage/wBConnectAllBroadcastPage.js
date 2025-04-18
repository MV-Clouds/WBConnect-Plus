import { LightningElement, track } from 'lwc';
import getBroadcastRecs from '@salesforce/apex/BroadcastMessageController.getBroadcastRecs';
import getBroadcastGroups from '@salesforce/apex/BroadcastMessageController.getBroadcastGroups';
import getTemplatesByObject from '@salesforce/apex/BroadcastMessageController.getTemplatesByObject';
import createChatRecods from '@salesforce/apex/BroadcastMessageController.createChatRecods';
import emptyState from '@salesforce/resourceUrl/emptyState';

export default class WBConnectAllBroadcastPage extends LightningElement {
    @track data = [];
    @track paginatedData = [];
    @track filteredData = [];
    @track broadcastGroups = [];
    @track filteredGroups = [];
    @track selectedGroupIds = [];
    @track templateOptions = []; // Will store the processed template options
    @track templateMap = new Map(); // Store the raw Map from Apex
    selectedTemplate = null;
    selectedDateTime;
    currentPage = 1;
    pageSize = 15;
    visiblePages = 5;
    isLoading = false;
    showPopup = false;
    selectedObjectName = 'WBConnect_Contact__c';
    popUpFirstPage = true;
    popUpSecondpage = false;
    popUpLastPage = false;
    popupHeader = 'Choose Broadcast Groups';

    @track emptyState = emptyState;

    get showNoRecordsMessage() {
        return this.filteredData.length === 0;
    }

    get totalItems() {
        return this.filteredData.length;
    }
    
    get totalPages() {
        return Math.ceil(this.totalItems / this.pageSize);
    }
    
    get pageNumbers() {
        try {
            const totalPages = this.totalPages;
            const currentPage = this.currentPage;
            const visiblePages = this.visiblePages;

            let pages = [];

            if (totalPages <= visiblePages) {
                for (let i = 1; i <= totalPages; i++) {
                    pages.push({
                        number: i,
                        isEllipsis: false,
                        className: `pagination-button ${i === currentPage ? 'active' : ''}`
                    });
                }
            } else {
                pages.push({
                    number: 1,
                    isEllipsis: false,
                    className: `pagination-button ${currentPage === 1 ? 'active' : ''}`
                });

                if (currentPage > 3) {
                    pages.push({ isEllipsis: true });
                }

                let start = Math.max(2, currentPage - 1);
                let end = Math.min(currentPage + 1, totalPages - 1);

                for (let i = start; i <= end; i++) {
                    pages.push({
                        number: i,
                        isEllipsis: false,
                        className: `pagination-button ${i === currentPage ? 'active' : ''}`
                    });
                }

                if (currentPage < totalPages - 2) {
                    pages.push({ isEllipsis: true });
                }

                pages.push({
                    number: totalPages,
                    isEllipsis: false,
                    className: `pagination-button ${currentPage === totalPages ? 'active' : ''}`
                });
            }
            return pages;
        } catch (error) {
            this.showMessageToast('Error', 'Error in pageNumbers->' + error, 'error');
            return null;
        }
    }
    
    get isFirstPage() {
        return this.currentPage === 1;
    }
    
    get isLastPage() {
        return this.currentPage === Math.ceil(this.totalItems / this.pageSize);
    }

    get isNextDisabled() {
        return this.selectedGroupIds.length === 0;
    }
    
    connectedCallback() {
        this.loadBroadcastGroups();
        this.loadAllTemplates(); // Load templates on component initialization
    }

    // Load all templates once during initialization
    loadAllTemplates() {
        this.isLoading = true;
        getTemplatesByObject()
            .then(result => {
                // Convert the Apex Map to JavaScript Map
                this.templateMap = new Map(Object.entries(result));
                this.updateTemplateOptions(); // Update options based on selected object
            })
            .catch(error => {
                this.showMessageToast('Error', 'Failed to load templates', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    updateTemplateOptions() {
        if (!this.selectedObjectName || this.templateMap.size === 0) {
            this.templateOptions = [];
            return;
        }

        let combinedTemplates = [];

        // Add object-specific templates
        if (this.templateMap.has(this.selectedObjectName)) {
            combinedTemplates = [...this.templateMap.get(this.selectedObjectName)];
        }

        // Add Generic templates
        if (this.templateMap.has('Generic')) {
            combinedTemplates = [...combinedTemplates, ...this.templateMap.get('Generic')];
        }

        // Convert to combobox options format
        this.templateOptions = combinedTemplates.map(template => ({
            label: template.Template_Name__c,
            value: template.Id
        }));

        
    }

    loadBroadcastGroups() {
        this.isLoading = true;
        getBroadcastRecs()
            .then(result => {
                this.data = result.map((item, index) => ({
                    ...item,
                    index : index + 1,
                }));

                this.filteredData = [...this.data];
                this.updateShownData();
            })
            .catch(error => {
                this.showMessageToast('Error', 'Failed to load broadcast groups', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    updateShownData() {
        try {
            const startIndex = (this.currentPage - 1) * this.pageSize;
            const endIndex = Math.min(startIndex + this.pageSize, this.totalItems);
            this.paginatedData = this.filteredData.slice(startIndex, endIndex);
        } catch (error) {
            this.showMessageToast('Error', 'Error updating shown data', 'error');
        }
    }

    handleSearch(event) {
        try {
            if(event.detail.value.trim().toLowerCase() != null) {
                this.filteredData = this.data.filter(item => 
                    item.Name &&
                    item.Name.toLowerCase().includes(event.detail.value.trim().toLowerCase())
                );
                this.updateShownData();
            }
        } catch (error) {
            this.showMessageToast('Error', 'Error searching', 'error');
        }
    }
    
    handlePrevious() {
        try{
            if (this.currentPage > 1) {
                this.currentPage--;
                this.updateShownData();
            }
        }catch(error){
            this.showMessageToast('Error', 'Error navigating to previous page', 'error');
        }
    }
    
    handleNext() {
        try{
            if (this.currentPage < this.totalPages) {
                this.currentPage++;
                this.updateShownData();
            }
        }catch(error){
            this.showMessageToast('Error', 'Error navigating pages', 'error');
        }
    }
    
    handlePageChange(event) {
        try{
            const selectedPage = parseInt(event.target.getAttribute('data-id'), 10);
            if (selectedPage !== this.currentPage) {
                this.currentPage = selectedPage;
                this.updateShownData();
            }
        }catch(error){
            this.showMessageToast('Error', 'Error navigating pages', 'error');
        }
    } 
    newBroadcast(){
        this.showPopup = true;
        this.isLoading = true;

        getBroadcastGroups()
            .then(result => {
                this.broadcastGroups = result;
                this.filteredGroups = [...this.broadcastGroups];
            })
            .catch(() => {
                this.showMessageToast('Error', 'Error fetching broadcast groups', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleSearchPopup(event) {
        const searchValue = event.target.value.trim().toLowerCase();
    
        // Filter the broadcast groups based on the search value
        this.filteredGroups = this.broadcastGroups.filter(group =>
            group.Name.toLowerCase().includes(searchValue)
        );
    
        // Ensure the IsChecked property is updated for filtered groups
        this.filteredGroups = this.filteredGroups.map(group => ({
            ...group,
            IsChecked: this.selectedGroupIds.some(selected => selected.Id === group.Id)
        }));
    }
    // Handle group selection
    handleGroupSelection(event) {
        try {
            const groupId = event.target.dataset.id;
    
            if (event.target.checked) {
                // Add group ID to selected list if checked
                if (!this.selectedGroupIds.some(group => group.Id === groupId)) {
                    this.selectedGroupIds = [
                        ...this.selectedGroupIds,
                        { Id: groupId, ObjName: this.selectedObjectName } // Store both Id and Name
                    ];
                }
            } else {
                // Remove group ID if unchecked
                this.selectedGroupIds = this.selectedGroupIds.filter(group => group.Id !== groupId);
            }
    
    
            // Update filteredGroups to reflect selection
            this.filteredGroups = this.filteredGroups.map(group => ({
                ...group,
                IsChecked: this.selectedGroupIds.some(selected => selected.Id === group.Id)
            }));
        } catch (error) {
            this.showMessageToast('Error', 'Error handling group selection', 'error');
        }
    }

    handleNextOnPopup() {
        try {
    
            this.popupHeader = 'Choose Template'
            this.popUpFirstPage = false;
            this.popUpSecondpage = true;
        } catch (error) {
            this.showMessageToast('Error!', 'Please select template', 'error');
        }
    }

    handleInputChange(event){
        const { name, value } = event.target;
        switch(name) {
            case 'template':
                this.selectedTemplate = value;
            break;
            case 'dateTime':
                this.selectedDateTime = value;                
            break;
        }
    }

    handleCloseOnPopup() {
        this.showPopup = false;
        this.popUpFirstPage = true;
        this.popUpSecondpage = false;
        this.popUpLastPage = false;
        this.popupHeader = 'Select Groups';
    
        // Reset the selected values
        this.selectedGroupIds = [];
        this.selectedTemplate = '';
        this.selectedDateTime = '';
    
        // Reset the filteredGroups and update IsChecked property
        this.filteredGroups = this.broadcastGroups.map(group => ({
            ...group,
            IsChecked: false
        }));
    }

    handlePreviousOnPopup(){
        this.popupHeader = 'Choose Broadcast Groups';
        this.popUpFirstPage = true;
        this.popUpSecondpage = false;
    }

    handleSchedulePopup(){

        if(this.selectedTemplate === '' || this.selectedTemplate === null){
            this.showMessageToast('Error!', 'Please select template', 'error');
            return;
        }

        this.popupHeader = 'Select Date and Time'

        this.popUpFirstPage = false;
        this.popUpSecondpage = false;
        this.popUpLastPage = true;
    }

    handlePreviousLastpage(){
        this.popupHeader = 'Choose Template';
        this.popUpFirstPage = false;
        this.popUpSecondpage = true;
        this.popUpLastPage = false;

    }

    handleSchedule(){

        if(this.selectedDateTime === '' || this.selectedDateTime === null){
            this.showMessageToast('Error!', 'Please select date and time', 'error');
            return;
        }        

        let grpIdList = this.selectedGroupIds.map(record => record.Id);

        createChatRecods({templateId: this.selectedTemplate, groupIds: grpIdList, isScheduled: true, timeOfMessage: this.selectedDateTime})
            .then(result => {
                if(result == 'Success'){
                    this.showMessageToast('Success', 'Broadcast sent successfully', 'success');
                    this.loadBroadcastGroups();
                    this.handleCloseOnPopup();
                } else {
                    this.showMessageToast('Error', `Broadcast sent failed - ${result}`, 'error');
                }
            })
            .catch(error => {
                this.showMessageToast('Error', `Broadcast sent failed - ${error}`, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
        
    }

    handleSendOnPopup(){

        if(this.selectedTemplate === '' || this.selectedTemplate === null){
            this.showMessageToast('Error!', 'Please select template', 'error');
            return;
        }

        this.isLoading = true;
        let grpIdList = this.selectedGroupIds.map(record => record.Id);

        createChatRecods({templateId: this.selectedTemplate, groupIds: grpIdList, isScheduled: false, timeOfMessage: ''})
            .then(result => {
                if(result == 'Success'){
                    this.showMessageToast('Success', 'Broadcast sent successfully', 'success');
                    this.loadBroadcastGroups();
                    this.handleCloseOnPopup();
                } else {
                    this.showMessageToast('Error', `Broadcast sent failed - ${result}`, 'error');
                }
            })
            .catch(error => {
                this.showMessageToast('Error', `Broadcast sent failed - ${error}`, 'error');
            })
            .finally(() => {
                this.isLoading = false;
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
}