import { LightningElement, track } from 'lwc';
import insertLeads from '@salesforce/apex/ImportDataController.insertLeads';
import homePageBGImg from '@salesforce/resourceUrl/homePageBG';
import NoFileImage from '@salesforce/resourceUrl/NoFileImage';

export default class ImportDataComponent extends LightningElement {
    @track isLoading = false;
    @track leadData = [];
    backgroundStyle = `background-image: url(${homePageBGImg});`;
    noFile = NoFileImage;

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            this.isLoading = true;
            this.readCSV(file);
        }
    }

    readCSV(file) {
        const reader = new FileReader();
        reader.onload = () => {
            const csv = reader.result;
            const lines = csv.split(/\r\n|\n/);
            const parsed = [];

            // Ensure the file has at least one header + one row
            if (lines.length < 2) {
                this.showMessageToast('Error', 'Invalid CSV: Not enough data.', 'error');
                this.isLoading = false;
                return;
            }

            // Validate that both Name and Phone headers are present
            const header = lines[0].split(',').map(col => col.trim().toLowerCase());
            if (header.length < 2 || header[0] !== 'name' || header[1] !== 'phone') {
                this.showMessageToast('Error', 'Invalid CSV format. First two columns must be "Name,Phone".', 'error');
                this.isLoading = false;
                return;
            }

            for (let i = 1; i < lines.length; i++) {
                const row = lines[i].split(',');
                if (row.length >= 2) {
                    const name = row[0]?.trim();
                    const phone = row[1]?.trim();
                    if (name && phone) {
                        parsed.push({
                            Name: name,
                            Phone: phone,
                            RowNumber: parsed.length + 1,
                            key: name + phone
                        });                     
                    }
                }
            }

            if (!parsed.length) {
                this.showMessageToast('Error', 'No valid rows found in the file.', 'error');
                this.isLoading = false;
                return;
            }

            this.leadData = parsed;
            this.isLoading = false;
        };
        reader.readAsText(file);
    }

    handleInsertRecords() {
        if (!this.leadData.length) return;

        this.isLoading = true;
        insertLeads({ leadDataList: this.leadData })
            .then(() => {
                this.showMessageToast('Success', 'Leads inserted successfully!', 'success');
                this.handleCancel();
            })
            .catch((error) => {
                this.showMessageToast('Error', 'Error: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCancel() {
        this.leadData = [];
        const fileInput = this.template.querySelector('input[type="file"]');
        if (fileInput) fileInput.value = '';
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