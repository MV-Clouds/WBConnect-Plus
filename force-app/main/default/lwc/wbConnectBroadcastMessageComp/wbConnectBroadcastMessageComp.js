import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processBroadcastMessageWithObject from '@salesforce/apex/BroadcastMessageController.processBroadcastMessageWithObject';
import getBroadcastGroupDetails from '@salesforce/apex/BroadcastMessageController.getBroadcastGroupDetails';
import getAllLeads from '@salesforce/apex/BroadcastMessageController.getAllLeads';
export default class WbConnectBroadcastMessageComp extends LightningElement {
    @track data = [];
    @track filteredData = []; // filtered data based on search
    @track paginatedData = [];
    @track currentPage = 1;
    @track pageSize = 10;
    @track visiblePages = 5;
    @track isLoading = false;
    @track searchTerm = '';
    @track selectedRecords = new Set(); // Track selected record IDs
    @track isCreateBroadcastModalOpen = false;
    @track messageText = '';
    @track broadcastGroupName = '';
    @track isCreateBroadcastComp = true;
    @track isAllBroadcastGroupPage = false;
    
    @api broadcastGroupId;

    broadcastHeading = 'New Broadcast Group';
    createBtnLabel= 'Create Broadcast Group'


    /**
    * Getter Name : isAllSelected
    * @description : return true if all records are selected
    * Date: 03/04/2025
    * Created By: Rachit Shah
    */
    get isAllSelected() {
        return this.paginatedData.length > 0 && 
                this.paginatedData.every(record => this.selectedRecords.has(record.Id));
    }

    get isIndeterminate() {
        return this.paginatedData.some(record => this.selectedRecords.has(record.Id)) && 
                !this.isAllSelected;
    }

    get showNoRecordsMessage() {
        return this.paginatedData.length === 0;
    }

    get isBtnDisabled() {
        return !this.paginatedData.length;
    }

    /**
     * Getter Name : totalItems
     * @description : set the totalItems count.
     */
    get totalItems() {
        return this.filteredData.length;
    }
    
    /**
    * Getter Name : totalPages
    * @description : set the totalpages count.
    */
    get totalPages() {
        return Math.ceil(this.totalItems / this.pageSize);
    }

    /**
    * Getter Name : pageNumbers
    * @description : set the list for page number in pagination.
    */
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
            this.showToast('Error', 'Error in pageNumbers->' + error, 'error');
            return null;
        }
    }

        /**
    * Getter Name : isFirstPage
    * @description : check the current page is first.
    */
    get isFirstPage() {
        return this.currentPage === 1;
    }

    /**
    * Getter Name : isLastPage
    * @description : check the current page is last.
    */
    get isLastPage() {
        return this.currentPage === Math.ceil(this.totalItems / this.pageSize);
    }
    
    connectedCallback() {
        this.loadLeads();
    }

    loadLeads() {
        this.isLoading = true;
    
        getAllLeads()
            .then(allLeads => {
                // Step 1: Format all leads
                this.data = allLeads.map((record, index) => ({
                    index: index + 1,
                    Id: record.Id,
                    name: record.Name,
                    phone: record.Phone,
                    isSelected: false
                }));
    
                // Step 2: Set filteredData initially to all leads
                this.filteredData = [...this.data];
    
                // Step 3: If broadcastGroupId exists, fetch group details
                if (this.broadcastGroupId) {
                    getBroadcastGroupDetails({ groupId: this.broadcastGroupId })
                        .then(result => {
                            this.broadcastHeading = 'Edit Broadcast Group';
                            this.createBtnLabel = 'Update Broadcast Group';
    
                            const groupData = result.group || {};
                            this.broadcastGroupName = groupData.Name;
                            this.messageText = groupData.Description__c;
    
                            const members = result.members || [];
                            const phoneSet = new Set(
                                members.map(m => m.Phone_Number__c).filter(Boolean)
                            );
    
                            this.data.forEach(lead => {
                                const isSelected = phoneSet.has(lead.phone);
                                if (isSelected) {
                                    this.selectedRecords.add(lead.Id); // Add the lead's Id to selectedRecords
                                }
                                lead.isSelected = isSelected; // Update the isSelected property directly
                            });
                            
                        })
                        .catch(error => {
                            console.error('Error fetching group details:', error);
                        });
                }
            })
            .catch(error => {
                console.error('Error loading leads or broadcast group:', error);
            })
            .finally(() => {
                this.isLoading = false;
                this.updateShownData(); // Refresh UI view
            });
    }

    /**
    * Method Name : updateShownData
    * @description : update the shownProcessedLisitingData when pagination is applied.
    * date: 20/08/2024
    * Created By:Vyom Soni
    */
    updateShownData() {
        try {
            const startIndex = (this.currentPage - 1) * this.pageSize;
            const endIndex = Math.min(startIndex + this.pageSize, this.totalItems);
            this.paginatedData = this.filteredData.slice(startIndex, endIndex);
            
        } catch (error) {
            this.showToast('Error', 'Error updating shown data', 'error');
        }
    }

    /**
    * Method Name : handlePrevious
    * @description : handle the previous button click in the pagination.
    * date: 20/08/2024
    * Created By:Vyom Soni
    */
    handlePrevious() {
        try{
            if (this.currentPage > 1) {
                this.currentPage--;
                this.updateShownData();
            }
        }catch(error){
            this.showToast('Error', 'Error handling previous button click', 'error');
        }
    }

    /**
    * Method Name : handleNext
    * @description : handle the next button click in the pagination.
    * date: 20/08/2024
    * Created By:Vyom Soni
    */
    handleNext() {
        try{
            if (this.currentPage < this.totalPages) {
                this.currentPage++;
                this.updateShownData();
            }
        }catch(error){
            this.showToast('Error', 'Error handling next button click', 'error');
        }
    }

        /**
    * Method Name : handlePageChange
    * @description : handle the direct click on page number.
    * date: 20/08/2024
    * Created By:Vyom Soni
    */
    handlePageChange(event) {
        try{
            const selectedPage = parseInt(event.target.getAttribute('data-id'), 10);
            if (selectedPage !== this.currentPage) {
                this.currentPage = selectedPage;
                this.updateShownData();
            }
        }catch(error){
            this.showToast('Error', 'Error handling page change', 'error');
        }
    }

    handleBack() {
        this.cleardata();
        this.isCreateBroadcastComp = false;
        this.isAllBroadcastGroupPage = true;
        
    }

    cleardata() {
        this.data = [];
        this.filteredData = [];
        this.paginatedData = [];
        this.currentPage = 1;
        this.selectedRecords.clear(); // Clear selections
        this.broadcastGroupName = '';
        this.messageText = '';
        this.isCreateBroadcastModalOpen = false;
        this.broadcastGroupId = null;
    }        

    handleSearch(event) {
        this.searchTerm = event.target.value.toLowerCase();
        const term = this.searchTerm.trim();
        this.filteredData = this.data.filter(item => {
            const name = item.name?.toLowerCase() || '';
            const phone = item.phone?.toLowerCase() || '';
            return !term || name.includes(term) || phone.includes(term);
        });
        this.currentPage = 1;
        this.updateShownData();    
    }

    handleInputChange(event) {
        const { name, value } = event.target;
        switch(name) {
            case 'name':
                this.broadcastGroupName = value;
                break;
            case 'message':
                this.messageText = value;
                break;
        }
    }

    /**
     * Handle individual record selection
     */
    handleRecordSelection(event) {
        const recordId = event.target.dataset.recordId;
        const record = this.paginatedData.find(row => row.Id === recordId);
        if (record) {
            record.isSelected = event.target.checked;
            if (record.isSelected) {
                this.selectedRecords.add(recordId);
            } else {
                this.selectedRecords.delete(recordId);
            }
            this.selectedRecords = new Set(this.selectedRecords);
        }
    }

    /**
     * Handle select all records
     */
    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.paginatedData.forEach(record => {
            record.isSelected = isChecked;
            if (isChecked) {
                this.selectedRecords.add(record.Id);
            } else {
                this.selectedRecords.delete(record.Id);
            }
        });
        this.selectedRecords = new Set(this.selectedRecords);
    }

    handleModalOpen(){

        if(this.selectedRecords.size === 0){
            this.showToast('Error', 'Please select at least one record', 'error');
            return;
        }

        // Check selectedRecords for invalid phone numbers
        if (Array.from(this.selectedRecords).some(recordId => {
            const record = this.data.find(r => r.Id === recordId);
            return !record || !record.phone || record.phone.trim() === '';
        })) {
            this.showToast('Error', 'One or more selected records have invalid or missing phone numbers', 'error');
            return;
        }


        this.isCreateBroadcastModalOpen = true;
    }

    closePopUp(){
        this.isCreateBroadcastModalOpen = false;
        this.broadcastGroupName = '';
        this.messageText = '';

    }

    handleSave(){
        if(this.messageText.trim() === '' || this.broadcastGroupName.trim() === ''){            
            this.showToast('Error', 'Please fill in all required fields', 'error');
            return;
        }

        const phoneNumbers = Array.from(this.selectedRecords)
        .map(recordId => {
            const record = this.data.find(r => r.Id === recordId);
            return record ? record.phone : null;
        })
        .filter(phone => phone !== null && phone !== '');
  
            
        const isUpdate = this.broadcastGroupId != null;
        

        const messageData = {
            phoneNumbers: phoneNumbers,
            description: this.messageText,
            name: this.broadcastGroupName,
            isUpdate: isUpdate,
            broadcastGroupId: this.broadcastGroupId,
        };

        this.isLoading = true;

        // Call the Apex method
        processBroadcastMessageWithObject({ requestJson: JSON.stringify(messageData) })
        .then(() => {
            this.showToast('Success', 'Broadcast group created successfully', 'success');
            this.closePopUp();
            this.selectedRecords.clear();
            this.updateShownData();

        })
        .catch(error => {
            this.showToast('Error', error.body?.message || 'Failed to process broadcast', 'error');
        })
        .finally(() => {
            this.isLoading = false;
            this.isCreateBroadcastComp = false;
            this.isAllBroadcastGroupPage = true;
        });;
    }

    showToast(title, message, variant){
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }

}