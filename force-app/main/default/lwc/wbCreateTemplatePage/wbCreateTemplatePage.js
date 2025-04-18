import { LightningElement, track,api } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import { loadScript } from 'lightning/platformResourceLoader';
import wbCreateTempStyle from '@salesforce/resourceUrl/wbCreateTempStyle';
import richTextZip from '@salesforce/resourceUrl/richTextZip';
import buttonIconsZip from '@salesforce/resourceUrl/buttonIconsZip';
import EMOJI_LIB from '@salesforce/resourceUrl/emojiZip';
import createWhatsappTemplate from '@salesforce/apex/WBTemplateController.createWhatsappTemplate';
import editWhatsappTemplate from '@salesforce/apex/WBTemplateController.editWhatsappTemplate';
import startUploadSession from '@salesforce/apex/WBTemplateController.startUploadSession';
import uploadFileChunk from '@salesforce/apex/WBTemplateController.uploadFileChunk';
import getObjectFields from '@salesforce/apex/WBTemplateController.getObjectFields';
import getWhatsAppTemplates from '@salesforce/apex/WBTemplateController.getWhatsAppTemplates';
import getDynamicObjectData from '@salesforce/apex/WBTemplateController.getDynamicObjectData';
import tempLocationIcon from '@salesforce/resourceUrl/tempLocationIcon';
import tempVideoIcon from '@salesforce/resourceUrl/tempVideoIcon';
import imageUploadPreview from '@salesforce/resourceUrl/imageUploadPreview';
import previewImage  from '@salesforce/resourceUrl/previewImage';
import redirect from '@salesforce/resourceUrl/redirect';
import copy from '@salesforce/resourceUrl/copy';
import uploadDocIcon from '@salesforce/resourceUrl/uploadDocIcon';
import uploadImgIcon from '@salesforce/resourceUrl/uploadImgIcon';
import uploadvideoIcon from '@salesforce/resourceUrl/uploadvideoIcon';
import wbSmileIcon from '@salesforce/resourceUrl/wbSmileIcon';
import docUploadPreview from '@salesforce/resourceUrl/documentPreviewIcon';
import wbiBg from '@salesforce/resourceUrl/wbiBg';
import WBConnectBackground from '@salesforce/resourceUrl/WBConnectBackground';
import NoPreviewAvailable from '@salesforce/resourceUrl/NoPreviewAvailable';
import uploadFile from '@salesforce/apex/FileUploaderController.uploadFile';
import deleteFile from '@salesforce/apex/FileUploaderController.deleteFile';
import getPublicLink  from '@salesforce/apex/FileUploaderController.getPublicLink';
import getObjectsWithPhoneField from '@salesforce/apex/WBTemplateController.getObjectsWithPhoneField';

export default class WbCreateTemplatePage extends LightningElement {
    @track maxTempNamelength = 512;
    @track maxShortlength = 60;
    @track maxTempBodyLength = 1024;
    @track maxWebsiteUrl = 2000;
    @track maxBtnTxt = 25;
    @track maxPhonetxt = 20;
    @track maxCodetxt = 15;
    @track maxPackTxt=224;
    @track maxHashTxt=11;
    @track _edittemplateid;
    @track previewImage = previewImage;
    @track redirect = redirect;
    @track copy = copy;
    @track uploadDocIcon = uploadDocIcon;
    @track uploadImgIcon = uploadImgIcon;
    @track uploadvideoIcon = uploadvideoIcon;
    @track uploadDocIcon = uploadDocIcon;
    @track wbSmileIcon = wbSmileIcon;
    @track wbiBg = wbiBg;
    @track WBConnectBackground = WBConnectBackground;
    @track isNewTemplate=true;
    @track isEditTemplate=false;
    @track totalButtonsCount = 0;
    @track visitWebsiteCount = 0;
    @track callPhoneNumber = 0;
    @track copyOfferCode = 0;
    @track flowCount = 0;
    @track marketingOpt = 0;
    @track isAllTemplate = false;
    @track iseditTemplatevisible = true;
    @track isPreviewTemplate = false;
    @track showReviewTemplate=false;
    @track IsHeaderText = false;
    @track addHeaderVar = false;
    @track addMedia = false;
    @track isImageFile = false;
    @track isImageFileUploader=false;
    @track isImgSelected = false;
    @track isDocSelected = false;
    @track isVidSelected = false;
    @track isVideoFile = false;
    @track isDocFile = false;
    @track isImageFile = false;
    @track isImageFileUploader=false;
    @track isVideoFileUploader=false;
    @track isDocFileUploader=false;
    @track isLocation=false;
    @track addMedia = false;
    @track isCallPhone = false;
    @track isOfferCode = false;
    @track isVisitSite = false;
    @track isFlow = false;
    @track isCustom = false;
    @track createButton = false;
    @track isButtonDisabled = false;
    @track isStopMarketing = false;
    @track buttonDisabled = false;
    @track isRefreshEnabled = true;
    @track isLoading=false;
    @track templateExists=false;
    @track showEmojis = false;
    @track isCheckboxChecked=false;   
    @track showDefaultBtn=true;
    @track templateName = '';
    @track header = '';
    @track footer = '';
    @track tempBody = 'Hello';
    @track previewBody='Hello';
    @track previewHeader='';
    @track formatedTempBody= this.tempBody;
    @track btntext = '';
    @track webURL = '';
    @track Cbtntext = '';
    @track selectedAction = '';
    @track selectedUrlType = 'Static';
    @track variables = [];
    @track header_variables = [];
    @track nextIndex = 1;
    @track headIndex = 1;
    @track selectedOption='Custom';
    @track activeTab = 'Marketing';
    @track activeSection = 'section1';
    @track selectedLabel = 'Add button';
    @track selectedContentType = 'None';  
    @track selectedLanguage = 'en_US';
    @track selectedActionType = '';
    @track selectedCountryType = '+91';  
    @track originalTempBody = '';
    @track placeholderMap = {};
    @track buttonList = [];
    @track customButtonList = [];  
    @track emojis;
    @track originalHeader = '';
    @track menuButtonSelected;    
    @track file;
    @track fileName = '';
    @track fileSize = 0;
    @track fileType = '';
    chunkSize = 5242880;
    uploadSessionId = '';
    @track headerHandle ='';
    @track isfilename=false;
    @track NoFileSelected=true;
    @track filePreview='';
    @track languageOptions=[];
    @track countryType=[];
    @track availableObjects = [];
    @track selectedObject = '';
    @track fields = [];
    @track chatMessages = [];
    @track richTextZip = richTextZip;
    @track buttonIconsZip =buttonIconsZip;
    @track toolbarButtons=[];
    @track isDropdownOpen = false;
    @track dropdownClass = 'dropdown-hidden';
    @track emojiCategories=[];
    @track templateId='';
    @track metaTemplateId='';
    @track allTemplates=[];
    @track headerError='';
    @track imageurl='';
    @track contentDocumentId='';
    @track isRendered=false;

    // -----------------------------------------------------------------
    @track isStage1 = true;
    @track isStage2 = false;

    @track isSection1Active = true;
    @track isSection2Active = false;
    @track isSection3Active = false;
    @track selectedOption='Custom';
    @track activeTab = 'Marketing';
    
    @track showDefaultBtn=true;
    @track utilityOrderStatusSelected = false;
    @track defaultPreview = true;
    @track authenticationPasscodeSelected = false;
    @track UtilityCustomSelected = false;
    @track isDefault=true;
    @track ifAuthentication = false;
    @track isAppSetup=true;
    @track showAutofill=true;
    @track showAuthBtn=false;
    @track authZeroTab=true;
     
    @track isautofillChecked=false;
    @track selectContent=['Add security recommendation'];
    @track showOneTap=false;
    @track autofilLabel='Autofill';
    @track autoCopyCode='Copy Code';
    @track value='zero_tap';
    @track packages = [
        { id: 1, packagename: '', signature: '', curPackageName: 0, curHashCode: 0 }
    ];
    @track expirationTime = 300; 
    @track isExpiration=false;
    @track prevContent=true;
    @track maxPackages=5;
    @track showMsgValidity = false; //change
    @track IsHeaderText = false;
    @track authPrevBody = `{{1}}`;
    @track isAddCallPhoneNumber = false;
    @track isAddVisitWebsiteCount = false;
    @track isAddCopyOfferCode = false;
    @track isAddFlow = false;
    @track tempLocationIcon=tempLocationIcon;
    @track tempVideoIcon=tempVideoIcon;
    @track imageUploadPreview = imageUploadPreview;
    @track docUploadPreviewImg = docUploadPreview;
    @track NoPreviewAvailableImg = NoPreviewAvailable;
    @track isFeatureEnabled = false;
    @track selectedTime = '5 minutes'; // Default value
    @track isFlowMarketing = false;
    @track isFlowUtility = false;
    @track isFlowSelected = false;
    @track isModalOpen = false;
    @track selectedFlowId = ''; 
    @track selectedFlow;
    @track iframeSrc;
    @track isModalPreview = false;

    get expireTime() {
        return [
            { label: '1 minute', value: '1 minute' },
            { label: '2 minutes', value: '2 minutes' },
            { label: '3 minutes', value: '3 minutes' },
            { label: '5 minutes', value: '5 minutes' },
            { label: '10 minutes', value: '10 minutes' }
        ];
    }

    get getwbiBg(){
        return `background-image: url(${this.wbiBg});`;

    }


    get getWBConnectBackground(){
        return `background-image: url(${this.WBConnectBackground});`;
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.isModalPreview = false;
    }
    modalPreview(){
        this.isModalPreview = true;
    }

    handleFlowSelection(event) {
        const { selectedFlow, iframeSrc ,flows } = event.detail; // Destructure the received data
    
        this.selectedFlowId = selectedFlow; // Get selected Flow ID
        this.iframeSrc = iframeSrc;
        this.selectedFlow = flows; // Store the entire list of flows
    
    
        this.isFlowSelected = true; // Hide "Choose Flow" button after selection
        this.NoFileSelected = false; // Hide text after selection
        this.closeModal();
    }

    handleFlowDeleteClick(event){
        this.isFlowSelected = false;
        this.selectedFlowId = ''; // Get selected Flow ID
        this.selectedFlow = undefined;
        this.NoFileSelected = true;
    }
    
    
    
    get contentOption() {
        return [
            { label: 'Add security recommendation', value: 'Add security recommendation' },
            { label: 'Add expiry time for the code', value: 'Add expiry time for the code' },
        ];
    }

    convertTimeToSeconds(label) {
        const timeMap = {
            '1 minute': 60,
            '2 minutes': 120,
            '3 minutes': 180,
            '5 minutes': 300,
            '10 minutes': 600
        };
        return timeMap[label] || 300; // Default to 5 minutes if not found
    }

    get flowBooleanCheck() {
        return this.isFlowMarketing || this.isFlowUtility;
    }
    

    handleTabClick(event) {
        this.activeSection = event.target.dataset.tab;
        
        
        this.resetSections();
        // this.template.querySelectorAll('.section-tab-li').forEach(item => {
        //     item.classList.remove('active-tab');
        // })
        this.isFlowMarketing = false;
        this.isFlowUtility = false;
        this.showMsgValidity=false;
        this.ifAuthentication=false;
        this.isDefault=true;
        if (this.activeSection === 'section1') {
            this.isSection1Active = true;
            this.activeTab = 'Marketing';
            this.selectedOption='CustomMarketing';
        } else if (this.activeSection === 'section2') {
            this.isSection2Active = true;
            this.activeTab = 'Utility';
            this.selectedOption='Custom';
            this.showMsgValidity=true;
        } else if (this.activeSection === 'section3') {            
            this.isSection3Active = true;
            this.ifAuthentication=true;
            this.showMsgValidity=true;
            this.selectedOption='One-time passcode';
            this.isDefault=false;
            this.activeTab = 'Authentication';
        }
        this.handleDefaultValues();
        
        this.template.querySelectorAll('.section-tab-li').forEach(item => {
            item.classList.remove('slds-button_brand');
        });
        const activeBtn = this.template.querySelector(`[data-tab="${this.activeSection}"]`);
        if (activeBtn) {
            activeBtn.classList.add('slds-button_brand');
        }
        // this.template.querySelector('.' + this.activeSection).classList.add('active-tab');
    }

    handleDefaultValues(){
        this.utilityOrderStatusSelected = false;
        this.authenticationPasscodeSelected = false;
        this.UtilityCustomSelected = false;
        this.defaultPreview = false;
        
        this.isFlowMarketing = false;
        this.isFlowUtility = false;
        this.showDefaultBtn = true;
        
        switch (this.selectedOption) {
            case 'ORDER_STATUS':
                this.utilityOrderStatusSelected = true;
                this.showDefaultBtn = false;
                break;
            case 'One-time passcode':
                this.authenticationPasscodeSelected = true;
                // this.showDefaultBtn = true;
                break;
            case 'Custom':
                this.UtilityCustomSelected = true;
                // this.showDefaultBtn = true;
                break;
            case 'CustomMarketing':
                this.defaultPreview = true;
                break;
            case 'flow':
                this.isFlowMarketing = true;
                break;
            case 'flowutility':
                this.isFlowUtility = true;
                break;
            default:
                this.defaultPreview = true;
                // this.showDefaultBtn = true;
                break;
        }
        
    }

    resetSections() {
        this.isSection1Active = false;
        this.isSection2Active = false;
        this.isSection3Active = false;
        
        
    }
    
    handleRadioChange(event) {
        this.selectedOption = '';
        this.selectedOption = event.target.value;

        
        this.ifUtilty = false;
        // this.showDefaultBtn = false;
        this.utilityOrderStatusSelected = false;
        this.authenticationPasscodeSelected = false;
        this.UtilityCustomSelected = false;
        this.defaultPreview = false;
        this.isFlowMarketing = false;
        this.isFlowUtility = false;
        this.showDefaultBtn = true;

        switch(this.selectedOption) {
            case 'ORDER_STATUS':
                this.ifUtilty = true;
                this.utilityOrderStatusSelected = true;
                this.showDefaultBtn = false;
                break;
            case 'One-time passcode':
                this.authenticationPasscodeSelected = true;
                break;
            case 'Custom':
                this.UtilityCustomSelected = true;
                // this.showDefaultBtn = true;
                break;
            case 'flow':
                this.isFlowMarketing = true;
                this.handleMenuSelect({
                    currentTarget: {
                        dataset: {
                            value: 'Flow',
                            buttonData: false
                        }
                    }
                });
                break;
                case 'flowutility' :
                this.isFlowUtility = true;
                this.handleMenuSelect({
                    currentTarget: {
                        dataset: {
                            value: 'Flow',
                            buttonData: false
                        }
                    }
                });
                break;
            default:
                this.defaultPreview = true;
                // this.showDefaultBtn = true;
                break;
        }

    }

    
    handleChange(event) {
        this.value = event.target.value;
        
        if(this.value=='zero_tap'){
            
            this.authZeroTab=true;
            this.isAppSetup=true;
            this.showAutofill = true;
            
            this.showAuthBtn=false;
            this.showOneTap=false;
            // this.showOneTap=true;
        }
        else if(this.value=='COPY_CODE'){
            
            this.authZeroTab=false;
            this.isAppSetup=false;
            this.showAutofill = false;
            
            this.showAuthBtn=true;
            this.showOneTap=false;
        }else if(this.value=='ONE_TAP'){
            
            this.authZeroTab=false;
            this.isAppSetup=true;
            this.showAutofill = true;
            
            this.showAuthBtn=false;
            this.showOneTap=true;
        }
    }

    

    @api
    get edittemplateid() {
        return this._edittemplateid;
    }

    set edittemplateid(value) {
        this._edittemplateid = value;
        if (this._edittemplateid) {
            this.isNewTemplate=false;
            this.isEditTemplate=true;
            this.isAllTemplate=false;
            // this.isStage2 = true ;
            // this.isStage1 = false;
            this.fetchTemplateData();
        }
    }

    get acceptedFormats() {
        return ['png','jpeg','jpg'];
    }

    get typeOptions() {
        return [
            { label: 'None', value: 'None'},
            { label: 'Text', value: 'Text'},
            { label: 'Image', value: 'Image'},
            { label: 'Video', value: 'Video'},
            { label: 'Document', value: 'Document'}
        ];
    }

    get typeactionOption() {
        return [
            { label: 'Call Phone Number', value: 'PHONE_NUMBER' },
            { label: 'Visit Website', value: 'URL' },
            { label: 'Copy Offer Code', value: 'COPY_CODE' },
            { label: 'Complete flow', value: 'Flow' }
        ];
    }
    
    get customOption() {
        return [
            { label: 'Custom', value: 'QUICK_REPLY' },
            {label: 'Marketing opt-out', value: 'Marketing opt-out'}
        ];
    }

    get urlType() {
        return [
            { label: 'Static', value: 'Static' }
        ];
    }

    get selectedLanguageLabel() {
        const selectedOption = this.languageOptions.find(option => option.value === this.selectedLanguage);
        return selectedOption ? selectedOption.label : '';
    }
 
    get hasButtons() {
        return this.buttonList.length > 0 || this.customButtonList.length > 0;
    }

    get buttonListWithDisabledState() {
        return this.customButtonList.map(button => ({
            ...button,
            isDisabled: button.selectedCustomType === 'Marketing opt-out'
        }));
    }
    get visitWebsiteDisabled() {
        return this.visitWebsiteCount >= 2;
    }

    get callPhoneNumberDisabled() {
        return this.callPhoneNumber >= 1;
    }

    get copyOfferDisabled() {
        return this.copyOfferCode >= 1;
    }

    get flowDisabled(){
        return this.flowCount>=1;
    }
    get marketingOptDisabled() {
        return this.marketingOpt >= 1;
    }

    get buttonClass() {
        return this.isButtonDisabled ? 'select-button disabled' : 'select-button';
    }

    get tempHeaderExample() {
        return this.header_variables.map(varItem => `{{${varItem.object}.${varItem.field}}}`);
    }

    get templateBodyText() {
        return this.variables.map(varItem => `{{${varItem.object}.${varItem.field}}}`);
    }
    
    get refreshButtonClass() {
        return this.isRefreshEnabled ? 'refresh-icon refresh-disabled' : 'refresh-icon';
    }

    get computedVariables() {
        return this.variables.map((varItem) => {
            return {
                ...varItem,
                options: this.fields ? this.fields.map((field) => ({
                    ...field,
                    isSelected: field.value === varItem.field
                })) : []
            };
        });
    }

    get availableObjectsWithSelection() {
        return this.availableObjects.map(obj => ({
            ...obj,
            isSelected: obj.value === this.selectedObject
        }));
    }

    connectedCallback() {
        this.fetchCountries();
        this.fetchLanguages();
        // this.fetchFields('Lead');
        this.generateEmojiCategories();
        this.fetchUpdatedTemplates(false);
        this.fetchObjectsWithPhoneField();
        console.log(this.activeSection);
        
        // const activeBtn = this.template.querySelector(`[data-tab="${this.activeSection}"]`);
        // if (activeBtn) {
        //     activeBtn.classList.add('slds-button_brand');
        // }
    }

    // fetchObjectsWithPhoneField() {
    //     this.isLoading = true;
    //     getObjectsWithPhoneField()
    //     .then((result) => {            
    //         this.availableObjects = result;
    //         this.selectedObject = this.availableObjects[0].value;
    //         this.fetchFields(this.selectedObject);
    //     })
    //     .catch((error) => {
    //         console.error('Error fetching objects with phone field: ', error);
    //         this.showMessageToast('Error', `Error fetching objects with phone field: ${error.message}`, 'error');
    //     })
    //     .finally(() => {
    //         this.isLoading = false;
    //     });
    // }
    fetchObjectsWithPhoneField() {
        this.isLoading = true;
        try {
            // Directly set the available objects
            this.availableObjects = [
                { label: 'Property', value: 'Property__c' },
                { label: 'Inquiry', value: 'Inquiry__c' },
                { label: 'Listing', value: 'Listing__c' },
                { label: 'Contact', value: 'WBConnect_Contact__c' }
            ];
            this.selectedObject = this.availableObjects[0].value; // Default to the first object
            this.fetchFields(this.selectedObject); // Fetch fields for the selected object
        } catch (error) {
            console.error('Error setting available objects: ', error);
            this.showMessageToast('Error', `Error setting available objects: ${error.message}`, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    renderedCallback() {
        // if(!this.isStage2){
        //     this.buttonList = [];
        // }
        loadStyle(this, wbCreateTempStyle).then(() => {
            try {
                
                this.template.querySelectorAll('.section-tab-li').forEach(item => {
                    item.classList.remove('slds-button_brand');
                });
                
                if(this.isStage1){
                    
                        const activeBtn = this.template.querySelector(`[data-tab="${this.activeSection}"]`);
                        if (activeBtn) {
                            activeBtn.classList.add('slds-button_brand');
                        }
                        else {
                        console.warn(`Element with class .${this.activeSection} not found`);
                    }
                }
                
                // var c = '.' + this.activeSection;
                // this.template.querySelector('.section1').classList.add('active-tab');

            } catch (error) {
                console.error('eror :: ', error);
                
            }
        }).catch(error => {
            console.error("Error in loading the colors",error);
        })

        
        if (this.isRendered) return;
        this.isRendered = true;
        let headerEls = this.template.querySelectorAll('.field-header-dd');
        if(headerEls!=null && this.addHeaderVar) {
            for(let i=0; i< this.header_variables.length; i++){
                this.header_variables.forEach((hv, i) => {
                    headerEls[i].value = hv.field;
                })
            }
            this.addHeaderVar=false;
        }
        let bodyEls = this.template.querySelectorAll('.field-body-dd');
        if(bodyEls !=null && this.addVar) {
            this.variables.forEach((bv, i) => {
                bodyEls[i].value = bv.field;
            })
            this.addVar=false;
        }
    }

    fetchTemplateData() {
        try {
            getDynamicObjectData({templateId:this.edittemplateid})
            .then((data) => {
                const { template, templateVariables } = data;

                this.selectedOption = template.Template_Type__c;
                this.activeTab = template.Template_Category__c;
                 let sec = '';
                 if (this.activeTab === 'Marketing') {
                     sec = 'section1';
                 } else if (this.activeTab === 'Utility') {
                     sec = 'section2';
                 } else if (this.activeTab === 'Authentication') {
                     sec = 'section3';
                 }
                 
                 // ✅ Create a mock event to pass correctly
                 const event = {
                     target: {
                         dataset: {
                             tab: sec
                         }
                     }
                 };
                 
                 // Pass this mock event to handleTabClick()
                 this.handleTabClick(event);
                this.handleRadioChange({ target: { value: this.selectedOption } });
                this.handleNextclick();

                setTimeout(() => {
                    
                    this.templateName = template.Template_Name__c || '';
                    this.metaTemplateId = template.Template_Id__c || '';
                    const headerBody = template.Header_Body__c || '';
                    
                    const headerType = template.Header_Type__c || 'None';
                    
                    this.footer = template.Footer_Body__c || '';
                    this.selectedLanguage = template.Language__c;
                    this.languageOptions = this.languageOptions.map(option => ({
                        ...option,
                        isSelected: option.value === this.selectedLanguage
                    }));
                    
                    this.tempBody = template.Template_Body__c || 'Hello';
                    
                    this.previewBody = this.tempBody ? this.formatText(this.tempBody) : 'Hello';
                    
                    
                    
                    try{
                        const templateMiscellaneousData = JSON.parse(template.Template_Miscellaneous_Data__c);
                        this.contentVersionId = templateMiscellaneousData.contentVersionId
                        this.isImageFile = templateMiscellaneousData.isImageFile
                        this.isImgSelected = templateMiscellaneousData.isImgSelected
                        this.isDocSelected = templateMiscellaneousData.isDocSelected
                        this.isVidSelected = templateMiscellaneousData.isVidSelected
                        this.IsHeaderText = templateMiscellaneousData.isHeaderText
                        this.addHeaderVar = templateMiscellaneousData.addHeaderVar
                        this.addMedia = templateMiscellaneousData.addMedia
                        this.isImageFileUploader = templateMiscellaneousData.isImageFileUploader
                        this.isVideoFileUploader = templateMiscellaneousData.isVideoFileUploader
                        this.isDocFileUploader = templateMiscellaneousData.isDocFileUploader
                        this.isVideoFile = templateMiscellaneousData.isVideoFile
                        this.isDocFile = templateMiscellaneousData.isDocFile
                        
                    }
                    catch(error){
                        console.error('Miss Error ::: ',error)
                    }
                    

                    // const parser = new DOMParser();
                    // const doc = parser.parseFromString(template?.Header_Body__c, "text/html");
                    // this.previewHeader = doc.documentElement.textContent;
                    if(template.Header_Type__c=='Image' || template.Header_Type__c=='Video' || template.Header_Type__c=='Document'){
                        const parser = new DOMParser();
                        const doc = parser.parseFromString(template?.Header_Body__c, "text/html");
                        this.previewHeader = doc.documentElement.textContent||"";
                        
                        this.fileName = template.File_Name__c;
                        this.fileType = template.Header_Type__c;
                        
                        this.filePreview = template.Header_Body__c;
                        
                    }else{
                        this.previewHeader= this.formatText(headerBody) ||'';
                    }
                    
                    
                    // this.previewHeader= this.formatText(headerBody) ||'';
                    this.selectedContentType=template.Header_Type__c || 'None';
                    this.btntext = template.Button_Label__c || '';
                    let tvs =templateVariables.map(tv=>{
                        let temp = {
                            object:tv.objName,
                            field:tv.fieldName,
                            alternateText:tv.alternateText?tv.alternateText:'',
                            id:tv.variable.slice(2,3),
                            index:tv.variable,
                            type:tv.type
                        };
                        return temp;
                    })
                    
                    this.variables = tvs.filter(tv=>tv.type=='Body') || [];
                    this.header_variables = tvs.filter(tv=>tv.type=='Header') || [];
                    this.updatePreviewContent(this.previewHeader,'header');
                    this.updatePreviewContent(this.previewBody,'body');
                    this.addHeaderVar=this.header_variables?.length>0?true:false;
                    this.addVar=this.variables?.length>0?true:false;
                    if (this.addHeaderVar) {
                        this.buttonDisabled = true;
                    }  
                    if (template.Button_Body__c) {
                        // Parse JSON from Button_Body__c
                        let buttonDataList = JSON.parse(template.Button_Body__c);
                    
                        // Clear existing button and custom button lists before populating
                        this.buttonList = [];
                        this.customButtonList = [];
                        this.callPhoneNumber = 0;
                        this.visitWebsiteCount = 0;
                        this.copyOfferCode = 0;
                        this.flowCount = 0;
                        this.marketingOpt = 0;
                    
                        buttonDataList.forEach((button, index) => {
                            if (button.type === 'QUICK_REPLY' || button.type === 'Marketing opt-out') {
                                // Handle custom buttons
                                try{
                                    if(button.isMarketingOpt){
                                        button.type = 'Marketing opt-out';
                                    }
                                }
                                catch(error){
                                    console.error(error);
                                }
                                let buttonData = {
                                    btntext : button.text
                                }
                                
                                this.handleMenuSelect({
                                    currentTarget: {
                                        dataset: {
                                            value: button.type,
                                            buttonData: buttonData
                                        }
                                    }
                                });
                            } else {
                                // Handle regular buttons
                                let newButton = {
                                    id: index + 1, // Unique ID for button
                                    selectedActionType: button.type || '',
                                    iconName: this.getButtonIcon(button.type),
                                    btntext: button.text || '',
                                    webURL: button.url || '',
                                    phonenum: button.phone_number || '',
                                    offercode: button.example || '',
                                    selectedUrlType: button.type === 'URL' ? 'Static' : '',
                                    selectedCountryType: button.phone_number ? button.phone_number.split(' ')[0] : '',
                                    isCallPhone: button.type === 'PHONE_NUMBER',
                                    isVisitSite: button.type === 'URL',
                                    isOfferCode: button.type === 'COPY_CODE',
                                    isFlow : button.type === 'Flow',
                                    hasError: false,
                                    errorMessage: ''
                                };
                    
                                // Call handleMenuSelect() to process button creation correctly
                                this.handleMenuSelect({
                                    currentTarget: {
                                        dataset: {
                                            value: button.type,
                                            buttonData: newButton
                                        }
                                    }
                                });
                            }
                        });
                    
                    }
                    
                    
                    if(headerType.toLowerCase()=='image' || headerType.toLowerCase() == 'video'){
                        this.headerHandle=template.Header_Handle__c;
                        this.imageurl=template.Header_Body__c;
                        this.NoFileSelected = false;
                        this.isfilename=true;
                        this.fileName=template.File_Name__c;
                        this.fileType = template.Header_Type__c.toLowerCase();
                        
                            this.filePreview=headerBody;
                    }
                    else{
                        this.header = headerBody.trim().replace(/^\*\*|\*\*$/g, '');
                    }
                 
                }, 1000);
            })
            .catch((error) => {
                console.error('Error fetching fields: ', error);
            });
        } catch (error) {
            console.error('Error fetching template data: ', error);
        }
    }

    getIconPath(iconName) {
        return `${richTextZip}/rich-texticon/${iconName}.png`;
    }

    get toolbarButtonsWithClasses() {
        return this.toolbarButtons.map(button => ({
            ...button,
            iconUrl: this.getIconPath(button.iconName), 
            classes: `toolbar-button ${button.title.toLowerCase()}`,
            imgClasses: `custom-icon ${button.iconName.toLowerCase()}`
        }));
    }

    toolbarButtons = [
        { title: 'bold', iconName: 'bold' },
        { title: 'italic', iconName: 'italic' },
        { title: 'strikethrough', iconName: 'stike' },
        { title: 'codeIcon', iconName: 'code' }
    ];

    addOutsideClickListener() {
        document.addEventListener('click', this.handleOutsideClick.bind(this));
    }

    removeOutsideClickListener() {
        document.removeEventListener('click', this.handleOutsideClick.bind(this));
    }

    disconnectedCallback() {
        this.removeOutsideClickListener();
    }

    handleOutsideClick(event) {
        const emojiContainer = this.template.querySelector('.toolbar-button');
        const button = this.template.querySelector('button');        
        if (
            (emojiContainer && !emojiContainer.contains(event.target)) && 
            (button && !button.contains(event.target))
        ) {
            this.showEmojis = false;
            this.removeOutsideClickListener();
        }
        if (this.template.querySelector('.dropdown-container') && !this.template.querySelector('.dropdown-container').contains(event.target)) {
            if (this.isDropdownOpen) {
                this.isDropdownOpen = false;
                this.dropdownClass = 'dropdown-hidden';
            }
        }
    }

    //fetch object related fields
    fetchFields(objectName) {
        try {
            getObjectFields({objectName: objectName})
            .then((result) => {
                this.fields = result.map((field) => ({ label: field, value: field }));
            })
            .catch((error) => {
                console.error('Error fetching fields: ', error);
            });
        } catch (error) {
            console.error('Error fetching objects fields: ', error);
        }
    }

    
    @track contentVersionId; // Store ContentVersionId

    // Handle file selection
    handleFileChange(event) {
        const file = event.target.files[0];
        
        if (file) {
            this.file = file ;
            this.fileName = file.name;
            this.fileType = file.type;
            this.fileSize = file.size;
            // Optional: File size limit (10 MB)
            const MAX_FILE_SIZE = 10 * 1024 * 1024;
            if (file.size > MAX_FILE_SIZE) {
                this.showMessageToast('Error', 'File size exceeds 10 MB. Please select a smaller file.', 'error');

                return;
            }

            const reader = new FileReader();
            reader.onload = () => {
                this.fileData = reader.result.split(',')[1];
                // this.generatePreview(file);
                this.handleUpload(); // Auto-upload
            };
            reader.readAsDataURL(file);

        }
    }

    // Generate file preview
    generatePreview(publicUrl) {
        if (this.fileType.startsWith('image/')) {
            this.isImgSelected = true;
            this.isDocSelected = false;
            this.isVidSelected = false;
            this.isImageFile = false;
            this.filePreview = publicUrl;
            
        } else if (this.fileType.startsWith('video/')) {
            this.isImgSelected = false;
            this.isDocSelected = false;
            this.isVidSelected = true;
            this.isVideoFile = false ;
            this.filePreview = publicUrl;
        } 
        
        else if (this.fileType === 'application/pdf') {
            this.isDocSelected = true;
            this.isImgSelected = false;
            this.isVidSelected = false;
            this.isDocFile = false;
            this.filePreview = publicUrl;
        }
         else {
            this.isImgSelected = false;
            this.isDocSelected = false;
            this.isVidSelected = false;
            
            this.showMessageToast('Error', 'Unsupported file type! Please select an image, PDF, or video.', 'error');
        }
        
        this.isfilename = true;
        this.NoFileSelected = false;
    }

    // Upload file to Apex
    handleUpload() {
        if (this.fileData) {
            this.isLoading = true;
            uploadFile({ base64Data: this.fileData, fileName: this.fileName })
                .then((result) => {
                    this.contentVersionId = result; // Store the returned ContentVersion Id
                    getPublicLink({ contentVersionId: this.contentVersionId })
                    .then((publicUrl) => {
                        this.generatePreview(publicUrl.replace('/sfc/p/#', '/sfc/p/'));
                    })
                    .catch((error) => {
                        
                     this.isLoading = false;
                        console.error('❌ Error fetching public link:', error);
                    });
                    this.uploadFile();
                })
                .catch((error) => {
                    console.error('Error uploading file: ', error);
                    
                     this.isLoading = false;
                    this.showMessageToast('Error', 'Error uploading file!', 'error');
                });
        } else {
            this.showMessageToast('Error', 'Please select a file first!', 'error');

        }
    }

    // Delete file from ContentVersion
    handleDelete() {
        if (this.contentVersionId) {
            deleteFile({ contentVersionId: this.contentVersionId })
                .then((result) => {
                    this.showMessageToast('Success', 'File deleted successfully', 'success');
                    this.resetFileData(); // Reset file data after deletion
                })
                .catch((error) => {
                    console.error('Error deleting file: ', error);
                    this.showMessageToast('Error', 'Error deleting file!', 'error');
                });
        } else {
            this.showMessageToast('Error', 'No file to delete!', 'error');
        }
    }

    // Reset file data after deletion
    resetFileData() {
        this.fileName = null;
        this.fileData = null;
        this.filePreview = null;
        
        if(this.isImgSelected){
            this.isImageFile = true;
        }
        else if(this.isVidSelected){
            this.isVideoFile = true;
        }
        else if(this.isDocSelected){
            this.isDocFile = true;
        }
        this.isImgSelected = false;
        this.isDocSelected = false;
        this.isVidSelected = false;
        this.isfilename = false;
        this.NoFileSelected = true;
        this.contentVersionId = null;
    }

    uploadFile() {
        this.isLoading=true;
        if (!this.file) {
            this.isLoading =false;
            this.showMessageToast('Error', 'Please select a file to upload.', 'error');
            return;
        }
        try {
            startUploadSession({
                fileName: this.fileName,
                fileLength: this.fileSize,
                fileType: this.fileType
            }).then(result=>{
                if (result) {
                    this.uploadSessionId = result;
                    this.uploadChunks();
                } else {
                    console.error('Failed to start upload session.');
                    this.showMessageToast('Error', 'Failed to start upload session.', 'error');
                    this.isLoading=false;
                }
            })
            .catch(error=>{
                console.error('Failed upload session.', error.body);
                this.isLoading=false;
            })
        } catch (error) {
            console.error('Error starting upload session: ', error);
            this.isLoading=false;
        }
    }

    uploadChunks() {
        try {
            let chunkStart = 0;
            const uploadNextChunk = () => {
                
                const chunkEnd = Math.min(chunkStart + this.chunkSize, this.fileSize);
                const chunk = this.file.slice(chunkStart, chunkEnd);
                const reader = new FileReader();
    
                reader.onloadend = async () => {
                    const base64Data = reader.result.split(',')[1]; 
                    const fileChunkWrapper = {
                        uploadSessionId: this.uploadSessionId,
                        fileContent: base64Data,
                        chunkStart: chunkStart,
                        chunkSize: base64Data.length,
                        fileName: this.fileName,
                    };
                    const serializedWrapper = JSON.stringify(fileChunkWrapper);
                    
                        uploadFileChunk({serializedWrapper:serializedWrapper})
                        .then(result=>{
                            if (result) {
                                let serializeResult = JSON.parse(result); 
                                this.headerHandle = serializeResult.headerHandle;
                                this.contentDocumentId =serializeResult.contentDocumentId;

                                chunkStart += this.chunkSize;
                                if (chunkStart < this.fileSize) {
                                    uploadNextChunk(); 
                                } else {
                                    this.isLoading=false;
                                    this.showMessageToast('Success', 'File upload successfully.', 'success');
                                }
                            } else {
                                console.error('Failed to upload file chunk.');
                                this.isLoading=false;
                                this.showMessageToast('Error', 'Failed to upload file chunk.', 'error');
                            }
                        })
                        .catch(error=>{
                            console.error('Failed upload session.', error);
                            this.isLoading=false;
                            this.showMessageToast('Error', error.body.message || 'An error occurred while uploading image.', 'error');
                        })
                };

                reader.readAsDataURL(chunk); 
            };

            uploadNextChunk();
        } catch (error) {
            this.isLoading=false;
            console.error('Error uploading file chunk: ', error);
        }
    }

    handleContentType(event) {
        try {
            this.NoFileSelected=true;
            this.isfilename=false;
            this.selectedContentType = event.target.value;

            if (this.selectedContentType == 'Text') {
                this.IsHeaderText = true;
            } else {
                this.IsHeaderText = false;
            }
            
        if (this.selectedContentType == 'Image' || this.selectedContentType == 'Video' || this.selectedContentType == 'Document' || this.selectedContentType == 'Location') {
            if (this.selectedContentType == 'Image') {
                this.isImgSelected = false;
                this.isDocSelected = false;
                this.isVidSelected = false;
                this.isImageFileUploader=true;
                this.isVideoFileUploader=false;
                this.isImageFile = true;
                this.isVideoFile = false;
                this.isDocFile = false;
                this.isDocFileUploader=false;
                this.isLocation=false;
                this.addMedia = true;
            } else if (this.selectedContentType == 'Video') {
                this.isImgSelected = false;
                this.isDocSelected = false;
                this.isVidSelected = false;
                this.isVideoFile = true;
                this.isDocFile = false;
                this.isImageFile = false;
                this.isImageFileUploader=false;
                this.isVideoFileUploader=true;
                this.isDocFileUploader=false;
                this.isLocation=false;
                this.addMedia = true;
            } else if (this.selectedContentType == 'Document') {
                this.isImgSelected = false;
                this.isDocSelected = false;
                this.isVidSelected = false;
                this.isDocFile = true;
                this.isImageFile = false;
                this.isVideoFile = false;
                this.isImageFileUploader=false;
                this.isVideoFileUploader=false;
                this.isDocFileUploader=true;
                this.isLocation=false;
                this.addMedia = true;
            }
            
            
        }
        else{
            this.isImageFile = false;
            this.isImageFileUploader=false
            this.isVideoFileUploader=false;
            this.isVideoFile = false;
            this.isDocFile = false;
            this.addMedia = false;
            this.isImgSelected = false;
            this.isDocSelected = false;
            this.isVidSelected = false;
            this.isLocation=false;
        }

        } catch (error) {
            console.error('Something wrong while selecting content type: ', JSON.stringify(error));
        }
    }

    handleNextclick() {
        this.iscreatetemplatevisible = false;
        this.iseditTemplatevisible = true;
        
        
        if(this.isStage1){
            this.isStage1 = false;
            this.isStage2=true ;
        }
        else if(this.isStage2){
            this.isStage2 = false;
            this.isStage3=true ;
        }
        else{
            this.isStage1 = true;
        }
    }

    handlePrevclick() {
        this.isAllTemplate = true;
        this.iseditTemplatevisible = true;
        this.clearEditTemplateData();
        
        if(this.isStage2){
            this.isStage2 = false;
            this.isStage1=true ;
            this.isAllTemplate = false;
        }
        else if(this.isStage3){
            this.isStage3 = false;
            this.isStage2=true ;
        }
        else{
            this.isStage1 = true;
        }
      
        
    }

    clearEditTemplateData() {
        switch (this.activeTab) {
            case 'Marketing':
                this.selectedOption = 'custom';
                break;
                case 'Utility':
                    this.selectedOption = 'Custom';
                    
                    break;
                case 'Authentication':
                this.selectedOption = 'One-time passcode';
                
                break;
            
            default:
                break;
        }

        
        this.handleRadioChange({ target: { value: this.selectedOption } });
       
        
        this.templateName = ''; 
        this.selectedContentType = 'None';
        this.header = ''; 
        this.addHeaderVar = false; 
        this.content = ''; 
        this.tempBody = 'Hello';  
        this.addVar=false;
        this.footer='';
        var tempList = [];
        this.buttonList = tempList;
        this.customButtonList = [];
        this.variables = [];
        this.header_variables = [];
        this.buttonDisabled = false;
        this.originalHeader=[];
        this.nextIndex = 1;
        this.headIndex = 1;
        this.createButton=false;
        this.IsHeaderText=false;
        this.isCustom=false;
        this.formatedTempBody=this.tempBody;
        this.visitWebsiteCount = 0;
        this.callPhoneNumber = 0;
        this.copyOfferCode = 0;
        this.flowCount = 0 ;
        this.marketingOpt = 0;
        this.selectContent='Add security recommendation';
        // this.isVideoFileUploader = false;
        // this.isDocFileUploader = false;
        this.addMedia = false;
        this.isDocSelected = false;
        this.isVidSelected = false;
        this.isImgSelected = false;
        this.isDocFile = false;
        // this.isFlowMarketing = false;
        // this.isFlowUtility = false;
        this.isFlowSelected = false;
        
        this.isautofillChecked=false;
        this.isExpiration = false;
        const headerInput = this.template.querySelector('input[name="header"]');
        if (headerInput) {
            headerInput.value = '';  
        }
        
    }
 
    handlediscardclick() {
        this.isAllTemplate = true;
        this.iscreatetemplatevisible = false;
        this.iseditTemplatevisible = false;
    }

    handleCustom(event) {
        this.selectedCustomType = event.target.value;
    }

    handleInputChange = (event) => {
        try {
            const { name, value, checked, dataset } = event.target;
            const index = dataset.index;

            

            switch (name) {
                case 'templateName':
                    
                    this.templateName = value.replace(/\s+/g, '_').toLowerCase();
                    
                    this.checkTemplateExistence();
                    break;
                case 'language':
                    this.selectedLanguage = value;
                    this.languageOptions = this.languageOptions.map(option => ({
                        ...option,
                        isSelected: option.value === this.selectedLanguage
                    }));
                    break;
                case 'footer':
                    this.footer = value;
                    break;
                case 'tempBody':
                    console.log('Temp Body :: ',value);
                    
                    this.tempBody = value.replace(/(\n\s*){3,}/g, '\n\n');

                    this.formatedTempBody = this.formatText(this.tempBody);
                    this.updatePreviewContent(this.formatedTempBody,'body');
                    break;
                case 'btntext':
                    this.updateButtonProperty(index, 'btntext', value);
                    this.validateButtonText(index, value);
                    break;
                case 'selectedUrlType':
                    this.updateButtonProperty(index, 'selectedUrlType', value);
                    break;
                case 'webURL':
                    this.updateButtonProperty(index, 'webURL', value);
                    break;
                case 'selectedCountryType':
                    this.updateButtonProperty(index, 'selectedCountryType', value);
                    this.selectedCountryType = value;
                    break;
                case 'phonenum':
                    this.updateButtonProperty(index, 'phonenum', value);
                    break;
                case 'offercode':
                    this.updateButtonProperty(index, 'offercode', value);
                    break;
                case 'isCheckboxChecked':
                    this.isCheckboxChecked = checked;
                    break;
                case 'isautofillChecked':
                    this.isautofillChecked = checked;
                    break;
                // Change
                case 'selectContent':
                    this.selectContent = value;
                    this.isExpiration = value.includes('Add expiry time for the code');
                    this.addSecurityRecommendation = value.includes('Add security recommendation');
                    this.prevContent = this.addSecurityRecommendation;
                    break;
            
                case 'autofill':
                    this.autofilLabel = value;
                    break;

                case 'expirationTime':
                    this.expirationTime = value;
                    break;
                
                case 'selectedTime':
                    this.selectedTime = value;
                    this.expirationTime = this.convertTimeToSeconds(value); // Convert selected time to seconds
                    break;
                case 'autoCopyCode':
                    this.autoCopyCode = value;
                    break;
                    
                case 'toggle':
                    if(this.isFeatureEnabled){
                        this.isFeatureEnabled = false;
                    }
                    else{
                        this.isFeatureEnabled = checked;
                    }
                    break;
                case 'header':
                    this.header = value;
                    const variableMatches = (value.match(/\{\{\d+\}\}/g) || []).length;
                    if (variableMatches > 1) {
                        this.headerError = 'Only one variable is allowed in the header.';
                    } else {
                        this.headerError = '';
                        this.updatePreviewContent(this.header, 'header');
                    }
                
                    break;
                default:
                    break;
            }
        } catch (error) {
            console.error('Something went wrong: ', error);
        }
    }
    

    validateButtonText(index, newValue) {
        const isDuplicate = this.buttonList.some((button, idx) => button.btntext === newValue && idx !== parseInt(index));
        
        if (index === 0) {
            this.buttonList[index].hasError = false;
            this.buttonList[index].errorMessage = '';
        } else {
            this.buttonList[index].hasError = isDuplicate;
            this.buttonList[index].errorMessage = isDuplicate ? 'You have entered the same text for multiple buttons.' : '';
        }

        this.btntext = newValue;  
        this.updateButtonErrors(); 
    }

    updateButtonProperty(index, property, value) {
        this.buttonList[index][property] = value;
    }

    checkTemplateExistence() {
        try {
            
            if (Array.isArray(this.allTemplates)) {
                this.templateExists = this.allTemplates.some(
                    template => template.Template_Name__c?.toLowerCase() === this.templateName?.toLowerCase()
                );
            } else {
                console.warn('allTemplates is not an array or is null/undefined');
                this.templateExists = false;
            }
        } catch (error) {
            console.error(error.message);
            this.showMessageToast('Error', error.message || 'An error occurred while checking template existence.', 'error');
        }
        
    }

    handleRemove(event) {
        try {
            const index = event.currentTarget.dataset.index;
            const removedButton = this.buttonList[index];
            if (removedButton && removedButton.isVisitSite) {
                this.visitWebsiteCount--;
            } else if (removedButton && removedButton.isCallPhone) {
                this.callPhoneNumber--;
            } else if (removedButton && removedButton.isOfferCode) {
                this.copyOfferCode--;
            }
            else if (removedButton && removedButton.isFlow) {
                this.flowCount--;
            }
            this.buttonList = this.buttonList.filter((_, i) => i !== parseInt(index));
            if (this.buttonList.length == 0) {
                this.createButton = false;
            }
            this.totalButtonsCount--;
            this.updateButtonDisabledState();
        } catch (error) {
            console.error('Error while removing button.',error);
        }
    }

    handleMenuSelect(event) {
        try {
            // const selectedValue = event.detail.value;
            const selectedValue = event.currentTarget.dataset.value; 
            this.menuButtonSelected = selectedValue;
            let buttonData=event.currentTarget.dataset.buttonData;

        
            let newButton = buttonData ? buttonData:{
                id: this.buttonList.length + 1,
                selectedActionType: selectedValue,
                iconName: this.getButtonIcon(selectedValue),
                btntext: '',
                webURL: '',
                phonenum: '',
                offercode: '',
                selectedUrlType: 'Static',
                selectedCountryType: '',
                isCallPhone: false,
                isVisitSite: false,
                isOfferCode: false,
                isFlow:false,
                hasError: false,  
                errorMessage: '' 
            };


            
            this.isAddCallPhoneNumber = false;
            this.isAddVisitWebsiteCount = false;
            this.isAddCopyOfferCode = false;
            this.isAddFlow = false;
        
            switch (selectedValue) {
                case 'QUICK_REPLY':
                    this.isCustom = true;
                    
                    const quickReplyText = buttonData && buttonData.btntext ? buttonData.btntext : 'Quick reply';
                    this.createCustomButton('QUICK_REPLY', quickReplyText);
                    this.isStopMarketing = false;
                    break;
                case 'Marketing opt-out':
                    if (this.marketingOpt < 1) {
                        this.isCustom = true;
                        
                        this.isStopMarketing = true;
                        const stopPromoText = buttonData && buttonData.btntext ? buttonData.btntext : 'Stop promotions';
                        this.createCustomButton('Marketing opt-out', stopPromoText);
                        this.marketingOpt++;
                    }
                    break;
                case 'PHONE_NUMBER':
                    if (this.callPhoneNumber < 1) {
                        this.createButton = true;
                        newButton.isCallPhone = true;
                        newButton.btntext = buttonData?.btntext || 'Call Phone Number';
                        this.btntext = buttonData?.btntext || 'Call Phone Number';
                        this.callPhoneNumber++;
                        this.isAddCallPhoneNumber = true;
                    }
                    break;
                case 'URL':
                    if (this.visitWebsiteCount < 2) {
                        this.createButton = true;
                        newButton.isVisitSite = true;
                        this.isVisitSite = true;
                        newButton.btntext = buttonData?.btntext || 'Visit Website';
                        this.btntext = buttonData?.btntext || 'Visit Website';
                        this.visitWebsiteCount++;
                        this.isAddVisitWebsiteCount = true;
                    }
                    break;
                case 'COPY_CODE':
                    if (this.copyOfferCode < 1) {
                        
                        this.createButton = true;
                        newButton.isOfferCode = true;
                        newButton.btntext = buttonData?.btntext || 'Copy Offer Code';
                        this.btntext = buttonData?.btntext || 'Copy Offer Code';
                        
                        // newButton.btntext = buttonData?.btntext || 'Copy Offer Code';
                        // this.btntext = buttonData?.btntext || 'Copy Offer Code';
                        this.copyOfferCode++;
                        this.isAddCopyOfferCode = true;
                    }
                    break;
                    case 'Flow':
                        
                        if (this.flowCount < 1) {
                            
                            this.createButton = true;
                            newButton.isFlow = true;
                            newButton.btntext = buttonData?.btntext || 'View flow';
                            this.btntext = buttonData?.btntext || 'View flow';
                            
                            // newButton.btntext = buttonData?.btntext || 'Copy Offer Code';
                            // this.btntext = buttonData?.btntext || 'Copy Offer Code';
                            this.flowCount++;
                            this.isAddFlow = true;
                        }
                        break;
                default:
                    newButton.btntext = 'Add Button';
            }
        
            const isDuplicate = this.buttonList.some(button => button.btntext === newButton.btntext);
            if (isDuplicate) {
                newButton.hasError = true;
                newButton.errorMessage = 'You have entered same text for multiple buttons.';
            } else {
                newButton.hasError = false;
                newButton.errorMessage = '';
            }
        
            if (newButton.selectedActionType != 'QUICK_REPLY' && newButton.selectedActionType != 'Marketing opt-out') {
                if(this.isAddCallPhoneNumber || this.isAddCopyOfferCode || this.isAddVisitWebsiteCount || this.isAddFlow){
                    
                    this.buttonList.push(newButton); 
                    this.totalButtonsCount++;
                }
            }
        
            this.updateButtonErrors();
            this.updateButtonDisabledState();
        } catch (error) {
            console.error('Error handling menu selection:', error);
        }
    }
       
    updateButtonErrors(isCustom = false) {
        const buttonListToCheck = isCustom ? this.customButtonList : this.buttonList;
        const buttonTexts = buttonListToCheck.map(button => isCustom ? button.Cbtntext : button.btntext);
        
        const duplicates = {};
        buttonTexts.forEach(text => {
            duplicates[text] = (duplicates[text] || 0) + 1;
        });
    
        buttonListToCheck.forEach((button, idx) => {
            const isDuplicate = duplicates[isCustom ? button.Cbtntext : button.btntext] > 1;
    
            if (idx === 0) {
                button.hasError = false;
                button.errorMessage = '';
            } else {
                if (isDuplicate) {
                    button.hasError = true;
                    button.errorMessage = 'You have entered the same text for multiple buttons.';
                } else {
                    button.hasError = false;
                    button.errorMessage = '';
                }
            }
        });
    }
    
    createCustomButton(btnType, btnText) {
        try {
            const btnTextExists = this.customButtonList.some(button => button.Cbtntext === btnText);
            
            
            let newCustomButton = {
                id: this.customButtonList.length + 1,
                selectedCustomType: btnType,
                Cbtntext: btnText,
                buttonClass: 'button-label-preview',
                showFooterText: btnType === 'Marketing opt-out',
                iconName: this.getButtonIcon(btnType),
                hasError: false,  
                errorMessage: ''  
            };
    
            if (btnTextExists) {
                newCustomButton.hasError = true;
                newCustomButton.errorMessage = 'You have entered same text for multiple buttons.';
            } else {
                newCustomButton.hasError = false;
                newCustomButton.errorMessage = '';
            }
    
            this.customButtonList.push(newCustomButton);
            this.customButtonList = [...this.customButtonList]
            
            this.totalButtonsCount++;
    
            this.updateButtonErrors(true);
            this.updateButtonDisabledState();
        } catch (error) {
            console.error('Error creating custom button:', error);
        }
    }
    

    getButtonIcon(type) {
        const iconMap = {
            'QUICK_REPLY': 'utility:reply',
            'Marketing opt-out': 'utility:reply',
            'PHONE_NUMBER': 'utility:call',
            'URL': 'utility:new_window',
            'COPY_CODE': 'utility:copy',
            'Flow':'utility:file'
        };
        return iconMap[type] || 'utility:question'; 
    }

    handleButtonClick(event) {
        try {
            const buttonId = event.currentTarget.dataset.id;        
            const clickedButton = this.customButtonList.find(button => button.id == buttonId);
        
            if (clickedButton) {
                if (clickedButton.isDisabled) {                    
                    return; 
                }
                let replyMessage = {
                    id: Date.now(),
                    body: `${clickedButton.Cbtntext}`,
                    timestamp: new Date().toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' }),
                    replyToMessage: {
                        body: this.formatedTempBody,
                    }
                };
        
                this.chatMessages = [...this.chatMessages, replyMessage];
    
                clickedButton.isDisabled = true;
                clickedButton.buttonClass = 'button-label-preview disabled'; 
    
                this.customButtonList = [...this.customButtonList];
                this.isRefreshEnabled = false;
            }
        } catch (error) {
            console.error('Error while replying to template.',error);
        }
    }    

    handleCustomText(event) {
        try {
            const index = event.currentTarget.dataset.index; 
            const newValue = event.target.value;
            this.customButtonList[index].Cbtntext = newValue;  
        
            const isDuplicate = this.customButtonList.some((button, idx) => button.Cbtntext === newValue && idx !== parseInt(index));
        
            if (index === 0) {
                this.customButtonList[index].hasError = false;  
                this.customButtonList[index].errorMessage = ''; 
            } else {
                if (isDuplicate) {
                    this.customButtonList[index].hasError = true;
                    this.customButtonList[index].errorMessage = 'You have entered the same text for multiple buttons.';
                } else {
                    this.customButtonList[index].hasError = false;
                    this.customButtonList[index].errorMessage = '';
                }
            }
        
            this.Cbtntext = newValue;  
            this.updateButtonErrors(true); 
        } catch (error) {
            console.error('Error while handling the custom text.',error);
        }
    }

    handleRemoveCustom(event) {
        try {
            const index = event.currentTarget.dataset.index;
            const removedButton = this.customButtonList[index];
        
            if (removedButton && removedButton.showFooterText) {
                this.marketingOpt--;
            }    
            this.customButtonList = this.customButtonList.filter((_, i) => i !== parseInt(index));
            if (this.customButtonList.length === 0) {
                this.isCustom = false;
            }
        
            this.totalButtonsCount--;
        
            if (removedButton?.Cbtntext) {
                const filteredMessages = this.chatMessages.filter(message => {
                    const isReplyToRemoved = message.replyToMessage?.body === this.formatedTempBody && message.body === removedButton.Cbtntext;
                    return !isReplyToRemoved;
                });
                this.chatMessages = [...filteredMessages];
            }
        
            this.customButtonList = [...this.customButtonList];
            this.updateButtonDisabledState();
        } catch (error) {
            console.error('Error while removing custom buttons.',error);
            
        }
    }    

    updateButtonDisabledState() {
        this.isDropdownOpen=false;
        this.isButtonDisabled = this.totalButtonsCount >= 10;
        this.buttonList.forEach(button => {
            button.isDisabled = button.selectedActionType === 'COPY_CODE';
        });
    }

    refreshTempPreview(){
        try {
            this.customButtonList = this.customButtonList.map(button => {
                return {
                    ...button,
                    isDisabled: false, 
                    buttonClass: 'button-label-preview' 
                };
            });
            this.chatMessages = [];
            this.isRefreshEnabled = true;
            
        } catch (error) {
            console.error('Error while refreshing the template.',error);
        }
    }

    addvariable() {
        try {
            this.addVar = true;
            const maxId = this.variables.reduce((max, variable) => {
                return Math.max(max, parseInt(variable.id)); 
            }, 0); 
            
            this.nextIndex = maxId + 1;
            const defaultField = this.fields[0].value; 
            
            const newVariable = {
                id: this.nextIndex,
                object: this.selectedObject,
                field: defaultField,
                alternateText: '',
                index: `{{${this.nextIndex}}}`,        
            };
            this.variables = [...this.variables, newVariable];

            this.tempBody = `${this.tempBody} {{${this.nextIndex}}} `;
            this.formatedTempBody=this.formatText(this.tempBody);
            this.updateTextarea();
            this.updatePreviewContent(this.formatedTempBody, 'body');
            this.nextIndex++;
        } catch (error) {
            console.error('Error in adding variables.',error); 
        } 
    }

    handleVarFieldChange(event) {
        try {
            const variableIndex = String(event.target.dataset.index);
            const fieldName = event.target.value;             
            this.variables = this.variables.map((varItem) =>                
                String(varItem.index) === variableIndex
                    ? {
                          ...varItem,
                          field: fieldName, 
                      }
                    : varItem
            );
            this.formatedTempBody = this.formatText(this.tempBody);
            this.updatePreviewContent(this.formatedTempBody, 'body');
        } catch (error) {
            console.error('Something went wrong while updating variable field.', error);
        }
    }    

    handleObjectChange(event){
        try {
            const selectedObject = event.target.value;
            this.selectedObject = selectedObject;

            // Update all object dropdowns to show the same selected value
            this.template.querySelectorAll('[data-name="objectPicklist"]').forEach(dropdown => {
                dropdown.value = selectedObject;
            });

            getObjectFields({ objectName: selectedObject })
                .then((result) => {
                    this.fields = result.map((field) => ({ label: field, value: field }));

                    // Update variables for both header and body
                    this.variables = this.variables.map(varItem => ({
                            ...varItem,
                            object: selectedObject,
                            field: this.fields[0].value
                    }));
        
                    this.header_variables = this.header_variables.map(varItem => ({
                            ...varItem,
                            object: selectedObject,
                            field: this.fields[0].value
                    }));
        
                    this.formatedTempBody = this.formatText(this.tempBody);
                    this.updateTextarea();
                    this.updatePreviewContent(this.header, 'header');
                    this.updatePreviewContent(this.formatedTempBody, 'body');
                })
                .catch((error) => {
                    console.error('Error fetching fields: ', error);
                });
        } catch (error) {
            console.error('Something went wrong while updating variable object.', error);
        }
    }

    handleAlternateVarChange(event) {
        const variableIndex = String(event.target.dataset.index);
        const alternateText = event.target.value;
        this.variables = this.variables.map(varItem =>
            String(varItem.index) === variableIndex
                ? { ...varItem, alternateText }
                : varItem
        );
    }

    updateTextarea() {
        const textarea = this.template.querySelector('textarea');
        if (textarea) {
            textarea.value = this.tempBody;
        }
        textarea.focus();
    }

    handleVarRemove(event) {
        try {
            const index = event.currentTarget.dataset.index;
            const varIndexToRemove = parseInt(index, 10) + 1;
            const variableToRemove = `{{${varIndexToRemove}}}`;
            let updatedTempBody = this.tempBody.replace(variableToRemove, '');
            this.variables = this.variables.filter((_, i) => i !== parseInt(index));
            this.variables = this.variables.map((varItem, idx) => {
                const newIndex = idx + 1;
                return {
                    ...varItem,
                    id: newIndex,
                    index: `{{${newIndex}}}`
                };
            });
            
            let placeholders = updatedTempBody.match(/\{\{\d+\}\}/g) || [];
            placeholders.forEach((placeholder, idx) => {
                const newIndex = `{{${idx + 1}}}`;
                updatedTempBody = updatedTempBody.replace(placeholder, newIndex);
            });
            this.tempBody = updatedTempBody.trim();
            this.originalTempBody = this.tempBody;
            this.formatedTempBody=this.originalTempBody;
            this.updatePreviewContent(this.tempBody, 'body');
            this.nextIndex = this.variables.length + 1;
            if (this.variables.length === 0) {
                this.addVar = false;
                this.nextIndex = 1;
            }
            this.updateTextarea();
        } catch (error) {
            console.error('Something wrong while removing the variable.',error);
        }
    }
  
    // Header variable add-remove functionality start here
    addheadervariable() {
        try {
            this.addHeaderVar = true;
            const defaultField = this.fields[0].value;
            const newVariable = {
                id: this.headIndex,
                object: this.selectedObject,
                field: defaultField,
                alternateText: '',
                index: `{{${this.headIndex}}}`,        
            };

            this.header_variables = [...this.header_variables, newVariable];
            this.originalHeader = (this.originalHeader || this.header || '') + ` {{${this.headIndex}}}`;
            this.header = this.originalHeader;
            this.updatePreviewContent(this.header, 'header');
            this.headIndex++;
            this.buttonDisabled = true;
        } catch (error) {
            console.error('Error in adding header variables.',error); 
        } 
    }

    handleFieldChange(event) {
        try {
            // const variableId = event.target.dataset.id;
            const variableId = String(event.target.dataset.id); 
            const fieldName = event.target.value;
            this.header_variables = this.header_variables.map(varItem =>
            String(varItem.id) === variableId
                ? {
                        ...varItem,
                        field: fieldName,
                    }
                : varItem
            );
            this.updatePreviewContent(this.header, 'header');
        } catch (error) {
            console.error('Something wrong while header variable input.',error);
        }
    }

    handleAlternateTextChange(event) {
        const variableId = String(event.target.dataset.id); 
        const alternateText = event.target.value;
        this.header_variables = this.header_variables.map(varItem =>
            String(varItem.id) === variableId
                ? { ...varItem, alternateText } 
                : varItem
        );
    }

    updatePreviewContent = (inputContent, type) => {
        try {
            let updatedContent = inputContent;
            
            const variables = type === 'header' ? this.header_variables : this.variables;
            variables.forEach(varItem => {
                const variablePlaceholder = varItem.index; 
                const replacementValue = `{{${varItem.object}.${varItem.field}}}`;
    
                let index = updatedContent.indexOf(variablePlaceholder);
                while (index !== -1) {
                    updatedContent = updatedContent.slice(0, index) + replacementValue + updatedContent.slice(index + variablePlaceholder.length);
                    index = updatedContent.indexOf(variablePlaceholder, index + replacementValue.length); 
                }
            });
        
            if (type === 'header') {
                this.previewHeader = updatedContent;
            } else if (type === 'body') {
                this.previewBody = updatedContent;
            }
        } catch (error) {
            console.error('Something wrong while updating preview.',error);   
        }
    }

    handleHeaderVarRemove(event) {
        try {
            const index = event.currentTarget.dataset.index;
            const varIndexToRemove = parseInt(index, 10) + 1;
            const variableToRemove = `{{${varIndexToRemove}}}`;
            let updatedHeader = this.header.replace(variableToRemove, '');
            this.header_variables = this.header_variables.filter((_, i) => i !== parseInt(index));
            this.header_variables = this.header_variables.map((varItem, idx) => {
                const newIndex = idx + 1;
                return {
                    ...varItem,
                    id: newIndex,
                    index: `{{${newIndex}}}`,
                    placeholder: `Enter content for {{${newIndex}}}`
                };
            });
            let placeholders = updatedHeader.match(/\{\{\d+\}\}/g) || [];
            placeholders.forEach((placeholder, idx) => {
                const newIndex = `{{${idx + 1}}}`;
                updatedHeader = updatedHeader.replace(placeholder, newIndex);
            });
            this.header = updatedHeader.trim();
            this.originalHeader = this.header;
            this.updatePreviewContent(this.originalHeader, 'header');
            this.headIndex = this.header_variables.length + 1;
            if (this.header_variables.length === 0) {
                this.addHeaderVar = false;
                this.buttonDisabled = false;
                this.headIndex = 1;
            }
        } catch (error) {
            console.error('Something wrong while removing header variable.',error);   
        }
    }

    // generateEmojiCategories() {
    //     try{
    //         fetch(emojiData)
    //         .then((response) => response.json())
    //         .then((data) => {
    //             let groupedEmojis = Object.values(
    //                 data.reduce((acc, item) => {
    //                     let category = item.category;
    //                     if (!acc[category]) {
    //                         acc[category] = { category, emojis: [] };
    //                     }
    //                     acc[category].emojis.push(item);
    //                     return acc;
    //                 }, {})
    //             );
        
    //             this.emojiCategories = groupedEmojis; 
    //         })
    //         .catch((e) => console.error('There was an error fetching the emoji.', e));
    //     }catch(e){
    //         console.error('Error in generateEmojiCategories', e);
    //     }
    // }
    generateEmojiCategories() {
        try{
            loadScript(this, EMOJI_LIB + '/emojiData.js')
                .then(() => {
                    console.log('Script loaded. emojiData:', window.emojiData);
                    const groupedEmojis = Object.values(
                        window.emojiData.reduce((acc, item) => {
                            const category = item.category;
                            if (!acc[category]) {
                                acc[category] = { category, emojis: [] };
                            }
                            acc[category].emojis.push(item);
                            return acc;
                        }, {})
                    );
                    this.emojiCategories = groupedEmojis;
                })
                .catch((error) => {
                    console.error('Failed to load emoji data:', error);
                });
        }catch(e){
            console.error('Error in generateEmojiCategories', e);
        }
    }

    // fetchCountries() {
    //     try{
    //         fetch(CountryJson)
    //         .then((response) => response.json())
    //         .then((data) => {
    //             this.countryType = data.map(country => {
    //                 return { label: `${country.name} (${country.callingCode})`, value: country.callingCode };
    //             });
    //         })
    //         .catch((e) => console.error('Error fetching country data:', e));
    //     }catch(e){
    //         console.error('Something wrong while fetching country data:', e);
    //     }
    // }
    fetchCountries() {
        try {
            loadScript(this, EMOJI_LIB + '/countryData.js')
                .then(() => {
                    console.log('Script loaded. countryData:', window.countryData);
                    const formattedCountries = window.countryData.map(country => {
                        return {
                            label: `${country.name} (${country.callingCode})`,
                            value: country.callingCode
                        };
                    });
                    this.countryType = formattedCountries;
                })
                .catch((error) => {
                    console.error('Failed to load country data:', error);
                });
        } catch (e) {
            console.error('Error in fetchCountries:', e);
        }
    }

    // generateEmojiCategories() {
    //     try{
    //         loadScript(this, EMOJI_LIB + '/emojiData.js')
    //             .then(() => {
    //                 const groupedEmojis = Object.values(
    //                     window.emojiData.reduce((acc, item) => {
    //                         const category = item.category;
    //                         if (!acc[category]) {
    //                             acc[category] = { category, emojis: [] };
    //                         }
    //                         acc[category].emojis.push(item);
    //                         return acc;
    //                     }, {})
    //                 );
    //                 this.emojiCategories = groupedEmojis;
    //             })
    //             .catch((error) => {
    //                 console.error('Failed to load emoji data:', error);
    //             });
    //     }catch(e){
    //         console.error('Error in generateEmojiCategories', e);
    //     }
    // }

    // fetchLanguages() {
    //     try{
    //         fetch(LanguageJson)
    //         .then((response) => response.json())
    //         .then((data) => {
    //             this.languageOptions = data.map(lang => {
    //                 return { label: `${lang.language}`, value: lang.code, isSelected: lang.code === this.selectedLanguage  };
    //             });
    //               if (!this.languageOptions.some(option => option.isSelected)) {
    //                 this.selectedLanguage = this.languageOptions[0]?.value || '';
    //                 if (this.languageOptions[0]) {
    //                     this.languageOptions[0].isSelected = true;
    //                 }
    //             }
    //         })
    //         .catch((e) => console.error('Error fetching language data:', e));
    //     }catch(e){
    //         console.error('Something wrong while fetching language data:', e);
    //     }
    // }

    fetchLanguages() {
        try {
            loadScript(this, EMOJI_LIB + '/lanaguageData.js')
                .then(() => {
                    console.log('Script loaded. languageData:', window.languageData);
                    const languageList = window.languageData.map(lang => {
                        return {
                            label: lang.language,
                            value: lang.code,
                            isSelected: lang.code === this.selectedLanguage
                        };
                    });
    
                    // Ensure at least one language is selected
                    if (!languageList.some(option => option.isSelected)) {
                        this.selectedLanguage = languageList[0]?.value || '';
                        if (languageList[0]) {
                            languageList[0].isSelected = true;
                        }
                    }
    
                    this.languageOptions = languageList;
                })
                .catch((error) => {
                    console.error('Failed to load language data:', error);
                });
        } catch (e) {
            console.error('Error in fetchLanguages:', e);
        }
    }

    handleEmoji(event) {
        event.stopPropagation();        
        this.showEmojis = !this.showEmojis;
    
        if (this.showEmojis) {
            this.addOutsideClickListener();
        } else {
            this.removeOutsideClickListener();
        }    
    }

    storeCursor(event) {
        this.cursorStart = event.target.selectionStart;
        this.cursorEnd = event.target.selectionEnd;
    }
    
    
    // handleEmojiSelection(event) {
    //     try {
    //         event.stopPropagation();        
    //         const emojiChar = event.target.textContent;    
    //         const textarea = this.template.querySelector('textarea');        
    //         const currentText = textarea.value || '';
    //         const cursorPos = textarea.selectionStart;
        
    //         const newText = currentText.slice(0, cursorPos) + emojiChar + currentText.slice(cursorPos);    
    //         this.tempBody = newText;
    //         this.formatedTempBody=this.tempBody;
    //         this.previewBody=this.formatedTempBody;
    //         textarea.value = newText;
        
    //         setTimeout(() => {
    //             const newCursorPos = cursorPos + emojiChar.length;    
    //             textarea.focus();    
    //             textarea.setSelectionRange(newCursorPos, newCursorPos);
    //         }, 0); 
    //     } catch (error) {
    //         console.error('Error in emoji selection.',error);
            
    //     }
    // }

    handleEmojiSelection(event) {
        try {
            event.stopPropagation();
            const emojiChar = event.target.textContent;
            const currentText = this.tempBody || '';
    
            const cursorPos = this.cursorStart ?? currentText.length;
    
            const newText = currentText.slice(0, cursorPos) + emojiChar + currentText.slice(cursorPos);
            this.tempBody = newText;
            this.formatedTempBody = newText;
            this.previewBody = newText;
    
            // Update cursor position after insert
            this.cursorStart = cursorPos + emojiChar.length;
            this.cursorEnd = this.cursorStart;
        } catch (error) {
            console.error('Error in emoji selection.', error);
        }
    }
    
    
    // handleFormat(event) {
    //     try {
    //         const button = event.target.closest('button');
    //         const formatType = button.dataset.format;
            
    //         const textarea = this.template.querySelector('textarea');
    //         const cursorPos = textarea.selectionStart;
    //         const currentText = textarea.value;
    //         let marker;
    //         let markerLength;
    //         switch (formatType) {
    //             case 'bold':
    //                 marker = '**';
    //                 markerLength = 1;
    //                 break;
    //             case 'italic':
    //                 marker = '__';
    //                 markerLength = 1;
    //                 break;
    //             case 'strikethrough':
    //                 marker = '~~';
    //                 markerLength = 1;
    //                 break;
    //             case 'codeIcon':
    //                 marker = '``````';
    //                 markerLength = 3;
    //                 break;
    //             default:
    //                 return;
    //         }
    //         const newText = this.applyFormattingAfter(currentText, cursorPos, marker);
    //         const newCursorPos = cursorPos + markerLength;
           
    //         this.tempBody = newText;
    //         this.updateCursor(newCursorPos);
    //     } catch (error) {
    //         console.error('Something wrong while handling rich text.',error);
    //     }
    // }
    handleFormat(event) {
        try {
            const button = event.target.closest('button');
            const formatType = button.dataset.format;
            const currentText = this.tempBody || '';
            const cursorPos = this.cursorStart ?? currentText.length;
    
            let marker = '';
            let markerLength = 0;
    
            switch (formatType) {
                case 'bold':
                    marker = '**';
                    markerLength = 1;
                    break;
                case 'italic':
                    marker = '__';
                    markerLength = 1;
                    break;
                case 'strikethrough':
                    marker = '~~';
                    markerLength = 1;
                    break;
                case 'codeIcon':
                    marker = '``````';
                    markerLength = 3;
                    break;
                default:
                    return;
            }
    
            const newText = this.applyFormattingAfter(currentText, cursorPos, marker);
    
            this.tempBody = newText;
            this.formatedTempBody = newText;
            this.previewBody = newText;
    
            this.cursorStart = cursorPos + markerLength;
            this.cursorEnd = this.cursorStart;
        } catch (error) {
            console.error('Something wrong while handling rich text.', error);
        }
    }
    

    applyFormattingAfter(text, cursorPos, marker) {
        return text.slice(0, cursorPos) + marker + text.slice(cursorPos);
    }

    formatText = (inputText) => {
        try {
            inputText = inputText.replace(/(\n\s*){3,}/g, '\n\n');
            let formattedText = inputText.replaceAll('\n', '<br/>');
            formattedText = formattedText.replace(/\*(.*?)\*/g, '<b>$1</b>');
            formattedText = formattedText.replace(/_(.*?)_/g, '<i>$1</i>');
            formattedText = formattedText.replace(/~(.*?)~/g, '<s>$1</s>');
            formattedText = formattedText.replace(/```(.*?)```/g, '<code>$1</code>');
    
            return formattedText;
        } catch (error) {
            console.error('Error while returning formatted text.',error);
        }
    }

    updateCursor(cursorPos) {
        const textarea = this.template.querySelector('textarea');
        textarea.value = this.tempBody;
        textarea.focus();
        textarea.selectionStart = textarea.selectionEnd = cursorPos;
    }

    validateTemplate() {
        try {
            if (!this.templateName || this.templateName.trim() === '') {
                this.showMessageToast('Error', 'Template Name is required', 'error');
                return false;
            }
        
            if (!this.selectedLanguage) {
                this.showMessageToast('Error', 'Please select a language', 'error');
                return false;
            }
        
            if (!this.tempBody || this.tempBody.trim() === '') {
                this.showMessageToast('Error', 'Template Body is required', 'error');
                return false;
            }
        
            const buttonData = [...this.buttonList, ...this.customButtonList];    
            for (let button of buttonData) {
                if (button.isVisitSite) {
                    if (!button.selectedUrlType || !button.webURL || !this.validateUrl(button.webURL)) {
                        this.showMessageToast('Error', 'Please provide a valid URL that should be properly formatted (e.g., https://example.com)', 'error');
                        return false;
                    }
                } else if (button.isCallPhone) {
                    if (!button.selectedCountryType || !button.phonenum || !this.validatePhoneNumber(button.phonenum)) {
                        this.showMessageToast('Error', 'Please provide a valid country and phone number for the "Call Phone Number" button', 'error');
                        return false;
                    }
                } else if (button.isOfferCode) {            
                    const alphanumericPattern = /^[a-zA-Z0-9]+$/;
                    if (!alphanumericPattern.test(button.offercode.trim())) {
                        this.showMessageToast('Error', 'Offer code must only contain alphanumeric characters (letters and numbers)', 'error');
                        return false;
                    }
                }
        
                if (button.isCustom) {
                    if (!button.Cbtntext || button.Cbtntext.trim() === '') {
                        this.showMessageToast('Error', 'Button text is required for the custom button', 'error');
                        return false;
                    }
                }
            }
            return true;
        } catch (error) {
            console.error('Something went wrong while validating template.',error);
            return false;
        }
       
    }
   
    validateUrl(value) {
        const urlPattern = new RegExp(
            '^(https?:\\/\\/)?(www\\.)?([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,6}($|\\/.*)$'
        );
        const isValid = urlPattern.test(value);
        return isValid;
    }    

    validatePhoneNumber(value) {
        const phonePattern = /^[0-9]{10,}$/;
        return phonePattern.test(value);
    }

    handleConfirm(){
        this.showReviewTemplate=true;
    }
    handleCloseTemplate(){
        this.showReviewTemplate=false;
        this.iseditTemplatevisible=true;
        this.isLoading=false;
    }

    get isSubmitDisabled() {
        const currentTemplate = this.activeTab;
        const areButtonFieldsFilled = this.buttonList.every(button =>
            button.btntext && (button.webURL || button.phonenum || button.offercode || button.isFlow)
        );
        const areCustomButtonFilled = this.customButtonList.every(button => button.Cbtntext);
        const hasCustomButtonError = this.customButtonList.some(button => button.hasError);
        const hasButtonListError = this.buttonList.some(button => button.hasError);
        const headerImageNotSelected = this.selectedContentType === 'Image' && !this.headerHandle;
        const headerVideoNotSelected = this.selectedContentType === 'Video' && !this.headerHandle;
        const headerDocumentNotSelected = this.selectedContentType === 'Document' && !this.headerHandle;
        const headerTextNotSelected = this.selectedContentType === 'Text' && !this.header;
        const hasHeaderError = !!this.headerError;
        let headerFileNotSelected = false;
        if(this.selectedContentType === 'Document'){
            headerFileNotSelected = headerDocumentNotSelected;
        }
        else if(this.selectedContentType === 'Image'){
            headerFileNotSelected = headerImageNotSelected;
        }
        else if(this.selectedContentType === 'Video'){
            headerFileNotSelected = headerVideoNotSelected;
        }
        const result = (() => {
        switch (currentTemplate) {
            case 'Marketing':
                if(this.flowBooleanCheck){
                    return !(this.selectedFlow != undefined && this.templateName && this.tempBody && areButtonFieldsFilled && areCustomButtonFilled && !this.templateExists && !hasCustomButtonError && !hasButtonListError && !headerFileNotSelected && !hasHeaderError && !headerTextNotSelected);
                }
                // return !(this.templateName && this.tempBody && this.isCheckboxChecked && areButtonFieldsFilled && areCustomButtonFilled && !this.templateExists && !hasCustomButtonError && !hasButtonListError && !headerFileNotSelected && !hasHeaderError && !headerTextNotSelected);
                return !(this.templateName && this.tempBody && areButtonFieldsFilled && areCustomButtonFilled && !this.templateExists && !hasCustomButtonError && !hasButtonListError && !headerFileNotSelected && !hasHeaderError && !headerTextNotSelected);
                case 'Utility':
                    if(this.flowBooleanCheck){
                        return !(this.selectedFlow != undefined && this.templateName && this.tempBody && areButtonFieldsFilled && areCustomButtonFilled && !this.templateExists && !hasCustomButtonError && !hasButtonListError && !headerFileNotSelected && !hasHeaderError && !headerTextNotSelected);
                    }
                    return !(this.templateName && this.tempBody && areButtonFieldsFilled && areCustomButtonFilled && !this.templateExists && !hasCustomButtonError && !hasButtonListError && !headerFileNotSelected && !hasHeaderError && !headerTextNotSelected);
                    // break;
                case 'Authentication':
                if (this.value == 'zero_tap') {
                    return !((this.templateName && this.isautofillChecked) && this.autoCopyCode && this.autofilLabel);
                } else if (this.value === 'ONE_TAP') {
                    return !((this.templateName) && this.autoCopyCode && this.autofilLabel);
                } else if (this.value === 'COPY_CODE') {
                    return !(this.templateName  && this.autoCopyCode);
                }else {
                    return true;
                }
            default:
                return true;
        }
        })();
        return result;
    }

    handlePackagename(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const value = event.target.value;

        this.packages[index].errorPackageMessage = '';

        if (!this.isPackageValid(value)) {
            this.packages[index].errorPackageMessage = 'Package name must have at least two segments separated by dots, and each segment must start with a letter and contain only alphanumeric characters or underscores.';
        }

        this.packages[index].packagename = value;
        this.packages[index].curPackageName = value.length; 

        const isDuplicate = this.packages.some((pkg, i) => i < index && pkg.packagename === value);
       
        if (isDuplicate) {
            this.showMessageToast('Error', 'Package name must be unique', 'error');
           
        }
        this.updateErrorMessages();


    }

    
    handleSignaturehash(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const value = event.target.value;

        this.packages[index].errorSignature = '';

        if (!this.isSignatureValid(value)) {
            this.packages[index].errorSignature = 'Signature hash must contain only alphanumeric characters, /, +, = and must be exactly 11 characters long.';
        }

        this.packages[index].signature = value;
        this.packages[index].curHashCode = value.length;
    
        const isDuplicate = this.packages.some((pkg, i) => i < index && pkg.signature === value);
    
        if (isDuplicate) {
            this.showMessageToast('Error', 'Signature hash must be unique', 'error');
           
        }
        this.updateErrorMessages();

    }  
    updateErrorMessages() {
        this.uniqueErrorMessages.packageErrors = [];
        this.uniqueErrorMessages.signatureErrors = [];
        this.appError = false;

        this.packages.forEach(pkg => {
            if (pkg.errorPackageMessage && !this.uniqueErrorMessages.packageErrors.includes(pkg.errorPackageMessage)) {
                this.uniqueErrorMessages.packageErrors.push(pkg.errorPackageMessage);
                this.appError = true; 
            }
            if (pkg.errorSignature && !this.uniqueErrorMessages.signatureErrors.includes(pkg.errorSignature)) {
                this.uniqueErrorMessages.signatureErrors.push(pkg.errorSignature);
                this.appError = true; 
            }
        });
    }

    addPackageApp() {
        if (this.packages.length < this.maxPackages) {
            const newPackage = {
                id: this.packages.length + 1,
                packagename: '',
                signature: '',
                curPackageName: 0,
                curHashCode: 0
            };
            this.packages = [...this.packages, newPackage];
            // this.addAppBtn=true;
        } else {
            console.warn('Maximum number of packages reached.');
        }
    }

    removePackageApp(event) {
        const index = parseInt(event.target.dataset.index, 10);
    
        if (index >= 0 && index < this.packages.length) {
            this.packages = this.packages.filter((pkg, i) => i !== index);
    
            this.packages = this.packages.map((pkg, i) => ({
                ...pkg,
                id: i + 1  
            }));
        } else {
            console.warn('Invalid package index for removal.');
        }
    }
    get showRemoveButton() {
        return this.packages.length > 1;
    }
    
     
    handleSubmit() {
        try {
            if((this.activeTab == 'Marketing' || this.activeTab == 'Utiltiy')&& !this.isCheckboxChecked && this.visitWebsiteCount > 0){
                this.showMessageToast('Error', 'Please select check-box to report website clicks.', 'error');
                return ;
            }
            this.isLoading=true;
            this.showReviewTemplate = false;
            if (!this.validateTemplate()) {
                this.isLoading=false;

                return;
            }     
            const formData = this.packages.map(pkg => ({
                packagename: pkg.packagename,
                signaturename: pkg.signature
            }));
        
            const buttonData = [];

            if (this.buttonList && this.buttonList.length > 0) {
                buttonData.push(...this.buttonList);
            }

            if (this.customButtonList && this.customButtonList.length > 0) {
                
                buttonData.push(...this.customButtonList);
            }
            let fileUrl = null;
                if (this.filePreview) {
                    fileUrl = this.filePreview; // Use ContentVersion if available
                } 
            
            
            // Change
            if(this.activeTab=='Authentication'){
                this.tempBody = ' is your verification code';
            }

            const templateMiscellaneousData = {
                contentVersionId : this.contentVersionId ,
                isImageFile : this.isImageFile,
                isImgSelected : this.isImgSelected,
                isDocSelected : this.isDocSelected,
                isVidSelected : this.isVidSelected,
                isHeaderText : this.IsHeaderText,
                addHeaderVar : this.addHeaderVar,
                addMedia: this.addMedia,
                isImageFileUploader : this.isImageFileUploader,
                isVideoFileUploader : this.isVideoFileUploader,
                isDocFileUploader : this.isDocFileUploader,
                isVideoFile : this.isVideoFile,
                isDocFile : this.isDocFile,

            }

            
            
            const template = {
                templateName: this.templateName ? this.templateName : null,
                templateCategory: this.activeTab ? this.activeTab : null,
                templateType: this.selectedOption ? this.selectedOption : null,
                tempHeaderHandle: this.headerHandle ? this.headerHandle : null,
                tempHeaderFormat: this.selectedContentType ? this.selectedContentType : null,
                tempImgUrl:this.filePreview ? this.filePreview : null,
                tempImgId:this.contentDocumentId ? this.contentDocumentId : null,
                tempImgName:this.fileName ? this.fileName : null,
                tempLanguage: this.selectedLanguage ? this.selectedLanguage : null,
                tempHeaderText: this.header ? this.header : '',
                varAlternateTexts: (this.templateCategory === 'Authentication')
                ? [null]  // Placeholder {{1}} is automatically handled, so no alternate text required
                : this.variables.map(varItem => varItem.alternateText || null),
                tempHeaderExample: (this.tempHeaderExample && this.tempHeaderExample.length > 0) ? this.tempHeaderExample : null,
                headAlternateTexts: this.header_variables.map(varItem => varItem.alternateText || null),
                templateBody: this.tempBody ? this.tempBody : '',
                templateBodyText: (this.templateBodyText && this.templateBodyText.length > 0) ? this.templateBodyText : null,
                tempFooterText: this.footer ? this.footer : null,
                typeOfButton: buttonData.length > 0 ? JSON.stringify(buttonData) : null,
                autofillCheck: this.isautofillChecked ? this.isautofillChecked : null,
                expireTime: this.expirationTime ? this.expirationTime : 300,
                packagename: formData.length > 0 ? formData.map(pkg => pkg.packagename) : null,
                signaturename: formData.length > 0 ? formData.map(pkg => pkg.signaturename) : null,
                selectedFlow : this.selectedFlow ? JSON.stringify(this.selectedFlow) : null,
                templateMiscellaneousData : templateMiscellaneousData ? JSON.stringify(templateMiscellaneousData) : null

            };
            

            const serializedWrapper = JSON.stringify(template);
            if(this.metaTemplateId){
                editWhatsappTemplate({ serializedWrapper: serializedWrapper,templateId:this.metaTemplateId })
                .then(result => {
                    if (result && result.success) { 
                        this.showMessageToast('Success', 'Template successfully edited.', 'success');
                        this.isAllTemplate=true;
                        this.iseditTemplatevisible=false;
                        this.isLoading=false;
                        const templateId = result.templateId;  
                        this.templateId = templateId;
                        this.fetchUpdatedTemplates();
                    } else {
                        const errorResponse = JSON.parse(result.errorMessage); 
                        const errorMsg = errorResponse.error.error_user_msg || 'Due to unknown error'; 
            
                        this.showMessageToast('Error', `Template updation failed, reason - ${errorMsg}`, 'error');
                        this.isLoading = false; 
                    }
                })
                .catch(error => {
                    console.error('Error creating template', error);
                    const errorTitle = 'Template creation failed: ';
                    let errorMsg;        
                    if (error.body && error.body.message) {
                        if (error.body.message.includes('Read timed out')) {
                            errorMsg = 'The request timed out. Please try again.';
                        } else {
                            errorMsg = error.body.message.error_user_title || 'An unknown error occurred';
                        }
                    } else {
                        errorMsg = 'An unknown error occurred';
                    }
                
                    this.showMessageToast('Error', `${errorTitle} - ${errorMsg}`, 'error');
                    this.isLoading = false;
                });
                
            }else{
                createWhatsappTemplate({ serializedWrapper: serializedWrapper })
                .then(result => {
                    if (result && result.success) { 
                        this.showMessageToast('Success', 'Template successfully created', 'success');
                        this.isAllTemplate=true;
                        this.iseditTemplatevisible=false;
                        this.isLoading=false;
                        const templateId = result.templateId;  
                        this.templateId = templateId;
                        this.fetchUpdatedTemplates();
                    } else {
                        const errorResponse = JSON.parse(result.errorMessage); 
                        const errorMsg = errorResponse.error.error_user_msg || errorResponse.error.message || 'Due to unknown error'; 
            
                        this.showMessageToast('Error', `Template creation failed, reason - ${errorMsg}`, 'error');
                        this.isLoading = false; 
                    }
                })
                .catch(error => {
                    console.error('Error creating template', error);
                    const errorTitle = 'Template creation failed: ';
                    let errorMsg;        
                    if (error.body && error.body.message) {
                        if (error.body.message.includes('Read timed out')) {
                            errorMsg = 'The request timed out. Please try again.';
                        } else {
                            errorMsg = error.body.message.error_user_title || 'An unknown error occurred';
                        }
                    } else {
                        errorMsg = 'An unknown error occurred';
                    }
                
                    this.showMessageToast('Error', `${errorTitle} - ${errorMsg}`, 'error');
                    this.isLoading = false;
                });
               
            }
           

        } catch (error) {
            console.error('Unexpected error occurred', error);
            this.showMessageToast('Error', 'An unexpected error occurred while submitting the template.', 'error');
            this.isLoading = false;
        }       
    }

    fetchUpdatedTemplates(dispatchEvent = true) {
        getWhatsAppTemplates()
            .then(data => {
                this.allTemplates = data; 
                if (dispatchEvent) {
                    const event = new CustomEvent('templateupdate', { detail: data });
                    this.dispatchEvent(event);
                }
            })
            .catch(error => {
                console.error('Error fetching templates:', error);
                this.showMessageToast('Error', 'Failed to fetch updated templates.', 'error');
            });
    }
    
    closePreview() {
        this.isLoading = true;     
        setTimeout(() => {
            this.isLoading = false; 
            this.isPreviewTemplate = false;
            // this.clearWrapper();
            this.iseditTemplatevisible = false;
            this.isAllTemplate = true;
        }, 2000);
    }  

    // --------------custom dropdown-----------

    getButtonPath(iconName) {
        return `${buttonIconsZip}/button-sectionIcons/${iconName}.png`;
    }

    toggleDropdown(event) {
        event.stopPropagation();
        this.isDropdownOpen = !this.isDropdownOpen;
        if (this.isDropdownOpen) {
            this.addOutsideClickListener();
        } else {
            this.removeOutsideClickListener();
        }
        this.dropdownClass = this.isDropdownOpen ? 'dropdown-visible' : 'dropdown-hidden';
    }
 
    dropdownOptions = [
        { title: 'Custom', value: 'QUICK_REPLY', iconName: 'custom' },
        { title: 'Marketing Opt-Out', value: 'Marketing opt-out', iconName: 'marketing',description:'Maximum 1 button can be added' },
        { title: 'Call Phone Number', value: 'PHONE_NUMBER', iconName: 'phone', description:'Maximum 1 button can be added'},
        { title: 'Visit Website', value: 'URL', iconName: 'site',description:'Maximum 2 button can be added' },
        { title: 'Copy Offer Code', value: 'COPY_CODE', iconName: 'copy',description:'Maximum 1 button can be added' },
        { title: 'Complete flow', value: 'Flow', iconName: 'flow',description:'Maximum 1 button can be added' }
    ];

    get quickReplyOptions() {
        return this.dropdownOptions
            .filter(option => this.activeTab == 'Utility' ? option.value === 'QUICK_REPLY' : option.value === 'QUICK_REPLY' || option.value === 'Marketing opt-out')
            .map(option => ({
                ...option,
                iconUrl: this.getButtonPath(option.iconName), 
                classes: `dropdown-item ${option.title.toLowerCase().replace(/\s+/g, '-')}` 
            }));
    }
    
    get callToActionOptions() {
        return this.dropdownOptions
            .filter(option => option.value === 'PHONE_NUMBER' || option.value === 'URL' || option.value === 'Flow' || option.value === 'COPY_CODE')
            .map(option => ({
                ...option,
                iconUrl: this.getButtonPath(option.iconName), 
                classes: `dropdown-item ${option.title.toLowerCase().replace(/\s+/g, '-')}` 
            }));
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