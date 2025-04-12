import { LightningElement, api, track, wire } from 'lwc';
import getCombinedData from '@salesforce/apex/ChatWindowController.getCombinedData';
import createChat from '@salesforce/apex/ChatWindowController.createChat';
import createChatForAWSFiles from '@salesforce/apex/ChatWindowController.createChatForAWSFiles';
import updateReaction from '@salesforce/apex/ChatWindowController.updateReaction';
import sendWhatsappMessage from '@salesforce/apex/ChatWindowController.sendWhatsappMessage';
import EMOJI_LIB from '@salesforce/resourceUrl/emojiZip';
import updateStatus from '@salesforce/apex/ChatWindowController.updateStatus';
import NoPreviewAvailable from '@salesforce/resourceUrl/NoPreviewAvailable';
import whatsappAudioIcon from '@salesforce/resourceUrl/whatsAppAudioIcon';
import { loadScript } from 'lightning/platformResourceLoader';
import AWS_SDK from "@salesforce/resourceUrl/AWSSDK";
import getS3ConfigSettings from '@salesforce/apex/AWSFilesController.getS3ConfigSettings';
import getContactsForChat from '@salesforce/apex/ChatWindowController.getContactsForChat';
import createContact from '@salesforce/apex/ChatWindowController.createContact';
import deleteContact from '@salesforce/apex/ChatWindowController.deleteContact';
import PROFILE from '@salesforce/resourceUrl/defaultProfile';
import WBCChatBG from '@salesforce/resourceUrl/WBCChatBG';

export default class ChatWindow extends LightningElement {
    @track contacts = [];
    @track filteredContacts = [];
    @track profileUrl = PROFILE;
    @track backgroundStyle = `background-image: url(${WBCChatBG});`;
    
    //Data Variables
    @api height;
    @track chats = [];

    @track recordData;
    @track groupedChats = [];
    @track messageText = '';
    @track selectedTemplate = null;
    @track allTemplates = [];
    @track templateSearchKey = null;
    @track emojiCategories = [];
    @track isEmojiLoaded = false;
    @track replyToMessage = null;
    @track reactToMessage = null;
    @track noteText = '';

    //Control Variables
    @track showSpinner = false;
    @track noChatMessages = true;
    @track showEmojiPicker = false;
    @track showAttachmentOptions = false;
    // showSendOptions = false;
    @track scrollBottom = false;
    @track showReactEmojiPicker = false;
    @track sendOnlyTemplate = false;

    @track acceptedFormats = [];
    @track showFileUploader = false;
    @track showTemplateSelection = false;
    @track showTemplatePreview = false;
    @track uploadFileType = null;
    @track NoPreviewAvailable = NoPreviewAvailable;
    @track headphone = whatsappAudioIcon;
    @track audioPreview = false;
    @track audioURL = '';
    @track isAWSEnabled = false;
    @track confData;
    @track s3;
    @track isAwsSdkInitialized = true;
    @track selectedFilesToUpload = [];
    @track selectedFileName;
    @track showCreateContactPopup = false;
    @track showDeleteContactPopup = false;
    @track nameValue = '';
    @track phoneValue = '';
    @track intervalId;

    @track objectApiName = 'WBConnect_Contact__c';
    @track recordId;
    @track phoneNumber;
    @track recordName;

    @track replyBorderColors = ['#34B7F1', '#FF9500', '#B38F00', '#ffa5c0', '#ff918b'];

    @track subscription = {};
    @track channelName = '/event/Chat_Message__e';

    //Get Variables
    get showPopup(){
        return this.showFileUploader || this.showTemplateSelection || this.showTemplatePreview || this.audioPreview;
    }
    
    get displayBackDrop(){
        return this.showEmojiPicker || this.showAttachmentOptions || this.showFileUploader || this.showTemplateSelection || this.showTemplatePreview || this.audioPreview;
    }

    get uploadLabel(){
        return 'Upload '+ this.uploadFileType || 'File';
    }

    get filteredTemplate(){
        let searchedResult = (this.allTemplates?.filter(template => template.Template_Name__c.toLowerCase().includes(this.templateSearchKey?.toLowerCase())));
        return this.templateSearchKey ? (searchedResult.length > 0 ? searchedResult : null) : this.allTemplates;
    }

    get recordMobileNumber(){
        return this.phoneNumber;
    }

    get replyToTemplateId(){
        return this.allTemplates.find(t => t.Id == this.replyToMessage.Whatsapp_Template__c)?.Template_Name__c || null;
    }

    connectedCallback(){
        try {
            this.getS3ConfigDataAsync();
            this.generateEmojiCategories();
            this.getContactsForChat();
            this.refreshDataIn5Secs();
        } catch (e) {
            console.error('Error in connectedCallback:::', e.message);
        }
    }

    renderedCallback(){
        try {
            if(this.scrollBottom){
                let chatDiv = this.template.querySelector('.chat-div');
                if(chatDiv){
                    chatDiv.scrollTop = chatDiv.scrollHeight;
                }
                this.scrollBottom = false;
            }
            if (this.isAwsSdkInitialized) {
                Promise.all([loadScript(this, AWS_SDK)])
                    .then(() => {
                        console.log('Script loaded successfully');
                    })
                    .catch((error) => {
                        console.error("error -> ", error);
                    });

                this.isAwsSdkInitialized = false;
            }
        } catch (e) {
            console.error('Error in function renderedCallback:::', e.message);
        }
    }

    getContactsForChat(){
        getContactsForChat()
            .then(result => {
                this.contacts = Object.values(result).map(item => ({
                    Id: item.Id,
                    Name: item.Name,
                    Phone: item.Phone,
                    unreadOutboundCount: item.unreadOutboundCount > 0 ? item.unreadOutboundCount : null,
                }));
                this.filteredContacts = [...this.contacts];

                const defaultContact = this.filteredContacts.find(contact => contact.unreadOutboundCount > 0);
                if(this.recordId != null){
                    if (defaultContact?.Id == this.recordId ) {
                        this.getInitialData(true);
                    }
                }
            })
            .catch(error => {
                console.error('Error fetching chat data:', error);
            });
    }

    handleContactsSearch(event) {
        const searchTerm = event.target.value.toLowerCase(); // Convert to lowercase for case-insensitive search
        console.log('Search term: ', searchTerm);

        if (searchTerm) {
            this.filteredContacts = this.contacts.filter(con =>
                con.Name && con.Name.toLowerCase().includes(searchTerm)
            );
        } else {
            this.filteredContacts = [...this.contacts]; // Reset to original list if search term is empty
        }
    }

    handleContactClick(event) {
        const contactId = event.currentTarget.dataset.id;
        console.log('Clicked contactId Id:', contactId);
        
        this.recordId = contactId;
        this.getInitialData();
        this.showSpinner = true;
    }

    handleNewContactClick(){
        this.showCreateContactPopup = true;
    }

    handleNewConInputChange(event) {
        const field = event.target.dataset.field;
        if (field === 'name') {
            this.nameValue = event.target.value;
        } else if (field === 'phone') {
            this.phoneValue = event.target.value;
        }
    }

    handleCreatePopup(){
        // Validate required fields
        if (!this.nameValue || this.nameValue.trim() === '' || !this.phoneValue || this.phoneValue.trim() === '') {
            this.showMessageToast('Error', 'Name & Phone is required.', 'error');
            return;
        }
        console.log(this.nameValue, this.phoneValue);
        
        // Call Apex to create Contact
        createContact({ name: this.nameValue, phone: this.phoneValue})
            .then(result => {
                console.log({result});
                this.showMessageToast('Success', 'Contact Created Successfully!', 'success');
                this.getContactsForChat();
                this.recordId = result;
                this.handleCloseCreatePopup(); // Close popup after success
                this.getInitialData();
                this.showSpinner = true;
            })
            .catch(error => {
                this.showMessageToast('Error', error.body.message, 'error');
            });
    }

    handleCloseCreatePopup(){
        this.showCreateContactPopup = false;
    }

    handleDeleteContactClick(){
        this.showDeleteContactPopup = true;
    }

    handleDeleteNoPopup(){
        this.showDeleteContactPopup = false;
    }

    handleDeleteYesPopup(){
        deleteContact({conId: this.recordId})
            .then(result => {
                console.log({result});
                this.showMessageToast('Success', 'Contact Deleted Successfully!', 'success');
                this.getContactsForChat();
                this.recordName = null;
                this.phoneNumber = null;
                this.recordId = null;
                this.handleDeleteNoPopup();
            })
            .catch(error => {
                this.showMessageToast('Error', error.body.message, 'error');
            })
    }

    refreshDataIn5Secs(){
        this.intervalId = setInterval(() => {
            this.getContactsForChat();
            // this.getInitialData(true);
        }, 5000);
    }

    // Fetch Initial Data
    getInitialData(hideSpinner){
        if(!hideSpinner || hideSpinner == false){
            this.showSpinner = true;
        }
        console.log('Method called at:', new Date().toLocaleTimeString());
        try {
            getCombinedData({ contactId: this.recordId, objectApiName: this.objectApiName })
                .then(combinedData => {

                    if(combinedData.record){
                        if(!combinedData.phoneNumber){
                            this.showMessageToast('Something went wrong!', 'The record does not have a mobile number.', 'error');
                            this.showSpinner = false;
                            return;
                        }
                        combinedData.phoneNumber = combinedData.phoneNumber.replaceAll(' ', '');
                        this.recordData = combinedData.record;
                    }else{
                        this.showMessageToast('Something went wrong!', 'Couldn\'t fetch data of record', 'error');
                        this.showSpinner = false;
                        return;
                    }

                    this.allTemplates = combinedData.templates.length > 0 ? combinedData.templates : null;
                    
                    this.chats = JSON.parse(JSON.stringify(combinedData.chats));
                    this.phoneNumber = combinedData.phoneNumber;
                    this.recordName = combinedData.recordName;
                    this.showSpinner = false;
                    this.processChats(true, hideSpinner);
                    
                    let chatIdsToSeen = [];
                    this.chats.filter(ch => ch.Type_of_Message__c != 'Outbound Messages').forEach(ch =>{
                        if(ch.Message_Status__c!='Seen') chatIdsToSeen.push(ch.Id);
                    })
                    if(chatIdsToSeen.length > 0){
                        updateStatus({messageIds: chatIdsToSeen})
                        .then(result => {
                            this.filteredContacts = this.filteredContacts.map(contact => {
                                if (contact.Id === this.recordId) {
                                    const updatedCount = contact.unreadOutboundCount - result.length;
                                    return {
                                        ...contact,
                                        unreadOutboundCount: updatedCount > 0 ? updatedCount : null// set to null if <= 0
                                    };
                                }
                                return contact;
                            });
                        })
                    }
                })
                .catch(e => {
                    this.showSpinner = false;
                    console.error('Error in getCombinedData:', e.message);
                });
        } catch (e) {
            this.showSpinner = false;
            console.error('Error in function getInitialData:::', e.message);
        }
    }

    processChats(needToScroll, dontScroll){
        try {
            this.noChatMessages = this.chats?.length < 1 ? true : false;
            if(this.noChatMessages) {
                this.sendOnlyTemplate = true;
                this.noteText = 'The conversation hasn\'t started yet. Begin by sending a template!';
                return;
            }
            this.chats = this.chats?.map(ch => {
                ch.isText = ch.Message_Type__c == 'Text';
                ch.isImage = ch.Message_Type__c == 'Image';
                ch.isVideo = ch.Message_Type__c == 'Video';
                ch.isAudio = ch.Message_Type__c == 'Audio';
                ch.isDoc = ch.Message_Type__c == 'Document';
                ch.isFlow = ch.Message_Type__c == 'Interactive';
                ch.isOther = !['Text', 'Image', 'Template', 'Video', 'Document', 'Audio', 'Interactive'].includes(ch.Message_Type__c) ;
                ch.isTemplate = ch.Message_Type__c == 'Template';
                ch.messageBy = ch.Type_of_Message__c == 'Outbound Messages' ? 'You' : this.recordName;
                if ((ch.isDoc || ch.isAudio) && ch.File_Data__c) {
                    if(ch.Message__c.includes('amazonaws.com') && ch.isDoc){
                        ch.isAWSFile = true;
                        const fileData = JSON.parse(ch.File_Data__c);
                        const fileName = fileData?.fileName;
                        const mimeType = fileData?.mimeType;
                        ch.fileName = fileName;
                        if(mimeType.includes('pdf')){
                            ch.isPreviewable = true;
                        } else {
                            ch.isPreviewable = false;
                        }
                    } else {
                        ch.isAWSFile = false;
                        try {
                            const fileData = JSON.parse(ch.File_Data__c);
                            const fileName = fileData?.fileName;
                            ch.fileName = fileName;
                            ch.contentDocumentId = fileData?.documentId;
                            ch.fileUrl = `/sfc/servlet.shepherd/version/download/${fileData?.contentVersionId}?as=${fileName}`;
                            ch.fileThumbnail = `/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${fileData?.contentVersionId}`;
                        } catch (error) {
                            console.error("Error parsing File_Data__c:", error);
                        }
                    }
                }
                return ch;
            });

            this.showSpinner = true;
            let today = new Date();
            let yesterday = new Date(today);
            yesterday.setDate(yesterday.getDate() - 1);
            
            let options = { 
                day: '2-digit', 
                month: 'short', 
                year: 'numeric' 
            };
            let groupedChats = this.chats?.reduce((acc, ch) => {
                let createDate = new Date(ch.CreatedDate).toLocaleDateString('en-GB', options);
                let dateGroup = createDate == today.toLocaleDateString('en-GB', options) ? 'Today' : (createDate == yesterday.toLocaleDateString('en-GB', options) ? 'Yesterday' : createDate);
                let yourReaction= ch.Reaction__c?.split('<|USER|>')[0];
                let userReaction= ch.Reaction__c?.split('<|USER|>')[1];
                let chat = {
                    ...ch,
                    className: ch.Type_of_Message__c === 'Outbound Messages' ? 'sent-message' : 'received-message',
                    isTick : ['Sent', 'Delivered', 'Seen'].includes(ch.Message_Status__c), 
                    isFailed: ch.Message_Status__c === 'Failed',
                    isSending: ch.Message_Status__c == null,
                    dateGroup: dateGroup,
                    yourReaction: yourReaction,
                    userReaction: userReaction,
                    isReaction: yourReaction || userReaction,
                    replyTo: this.chats?.find( chat => chat.Id === ch.Reply_to__c)
                };
                
                if (!acc[chat.dateGroup]) {
                    acc[chat.dateGroup] = [];
                }
                acc[chat.dateGroup].push(chat);
                return acc;
            }, {});
    
            this.groupedChats = Object.entries(groupedChats).map(([date, messages]) => ({
                date,
                messages
            }));
            
            this.showSpinner = false;
            if(needToScroll && !dontScroll){
                this.scrollBottom = true;
            }
            this.checkLastMessage();
            console.log(this.groupedChats);
        } catch (e) {
            console.error('Error in function processChats:::', e.message);
            this.showSpinner = false;
        }
    }
    
    checkLastMessage(){
        this.showSpinner = true;
        try {
            let interactionMessages = this.chats.filter(msg => msg.Last_Interaction_Date__c);            
            let lastInteraction = interactionMessages?.sort((a, b) => new Date(b.Last_Interaction_Date__c) - new Date(a.Last_Interaction_Date__c))[0];

            if (lastInteraction) {
                let currentTime = new Date();
                let messageTime = new Date(lastInteraction.Last_Interaction_Date__c);
                let timeDifferenceInMilliseconds = currentTime - messageTime;
                let hoursDifference = timeDifferenceInMilliseconds / (1000 * 60 * 60);

                if (hoursDifference > 24){
                    this.sendOnlyTemplate = true;
                    this.noteText = "Only template can be sent as no messages were received from this contact in last 24 hours.";
                }else{
                    this.sendOnlyTemplate = false;
                }
            }else{
                this.sendOnlyTemplate = true;
                this.noteText = "Only template can be sent as no messages were received from this contact in last 24 hours.";
            }
            this.showSpinner = false;
        } catch (e) {
            this.showSpinner = false;
            console.error('Error in function checkLastMessage:::', e.message);
        }
    }

    handleBackDropClick(){
        try {
            this.closeAllPopups();
            this.reactToMessage = null;
            this.showReactEmojiPicker = false;
            this.showFileUploader = false;
            this.showTemplateSelection = false;
            this.showTemplatePreview = false;
            this.acceptedFormats = [];
            this.uploadFileType = null;
            this.showEmojiPicker = false;
            this.showAttachmentOptions = false;
            this.selectedTemplate = null;
            this.audioPreview = false;
            this.audioURL = '';
            this.selectedFileName = null;
            this.selectedFilesToUpload = [];
            this.template.querySelector('input[type="file"]').value = null;
        } catch (e) {
            console.error('Error in function handleBackDropClick:::', e.message);
        }
    }

    closeAllPopups(){
        this.template.host.style.setProperty("--max-height-for-attachment-options","0rem");
        this.template.host.style.setProperty("--max-height-for-send-options","0rem");
        this.template.host.style.setProperty("--height-for-emoji","0rem");
    }

    handleToggleActions(event){
        try {
            event.currentTarget.classList.toggle('show-options');
        } catch (e) {
            console.error('Error in function handleToggleActions:::', e.message);
        }
    }

    handleHideActions(event){
        try {
            event.currentTarget?.querySelector('.action-options-btn')?.classList.remove('show-options');
        } catch (e) {
            console.error('Error in function handleHideActions:::', e.message);
        }
    }

    handleChatAction(event){
        try {
            let actionType = event.currentTarget.dataset.action;
            let chatId = event.currentTarget.dataset.chat;
            if(actionType === 'reply'){
                this.replyToMessage = this.chats?.find( chat => chat.Id === chatId);
                this.template.querySelector('.message-input').focus();
            }else if(actionType === 'react'){
                this.reactToMessage = chatId;
                this.showReactEmojiPicker = true;
            }else if(actionType === 'copy'){
                navigator.clipboard.writeText(event.currentTarget.dataset.message);
                this.showMessageToast('Success!', 'The message text has been copied to clipboard.', 'success');
            }else if(actionType === 'cancel-reply'){
                this.replyToMessage = null;
            }else if(actionType === 'cancel-react'){
                this.reactToMessage = null;
                this.showReactEmojiPicker = false;
            }
        } catch (e) {
            console.error('Error in function handleReply:::', e.message);
        }
    }

    handleReactWithEmoji(event){
        try {
            if(this.reactToMessage){
                let chat = this.chats?.find( ch => ch.Id === this.reactToMessage);                
                chat.Reaction__c = event.target.innerText + (chat.Reaction__c ? chat.Reaction__c.slice(chat.Reaction__c.indexOf('<|USER|>')) : '<|USER|>');
                this.reactToMessage = null;
                this.showReactEmojiPicker = false;
                this.updateMessageReaction(chat);
            }
        } catch (e) {
            console.error('Error in function handleReactWithEmoji:::', e.message);
        }
    }

    handleRemoveReaction(event){
        try {
            let chat = this.chats?.find( chat => chat.Id === event.currentTarget.dataset.chat);
            chat.Reaction__c = chat.Reaction__c?.slice(chat.Reaction__c.indexOf('<|USER|>'));
            this.updateMessageReaction(chat);
        } catch (e) {
            console.error('Error in function handleRemoveReaction:::', e.message);
        }
    }

    handleReplyMessageClick(event){
        try {            
            let replyTo = event.currentTarget.dataset.replyTo;

            let replyToChatEle = this.template.querySelector(`.message-full-length-div[data-id="${replyTo}"]`);
            if(!replyToChatEle){
                return;
            }
            replyToChatEle.scrollIntoView({behavior: 'smooth', block:'center'});

            let chatBlink = [
                { backgroundColor: "#a9a9a990" },
                { backgroundColor: "transparent" },
            ];
            
            let blinkTiming = {
                duration: 1000,
                iterations: 1,
            };
            let observer = new IntersectionObserver(
                (entries) => {
                    entries.forEach((entry) => {
                        if (entry.isIntersecting) {
                            replyToChatEle.animate(chatBlink, blinkTiming);
                            observer.unobserve(entry.target);
                        }
                    });
                },
                { threshold: 0.1 }
            );
    
            // Start observing the element
            observer.observe(replyToChatEle);
            
        } catch (e) {
            console.error('Error in function handleReplyMessageClick:::', e.message);
        }
    }
    handleToggleImagePreview(event){
        try {
            let isMobileDevice = /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent); 
            if(isMobileDevice){
                return;
            }
            let action = event.currentTarget.dataset.action;
            
            if(action == 'open'){
                event.currentTarget.classList.add('show-image-preview');
            }else if(action == 'close'){
                this.template.querySelector('.show-image-preview').classList.remove('show-image-preview');
                event.stopPropagation()
            }
        } catch (e) {
            console.error('Error in function handleToggleImagePreview:::', e.message);
        }
    }

    handleToggleAudioPreview(event){
        let isMobileDevice = /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent); 
        if(isMobileDevice){
            return;
        }
        let audioURL = event.currentTarget.dataset.url;
        this.audioPreview = !this.audioPreview;
        this.audioURL = audioURL;
    }

    handleTogglePDFPreview(event){
        let isMobileDevice = /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent); 
        if(isMobileDevice){
            return;
        }
        let action = event.currentTarget.dataset.action;
        
        if(action == 'open'){
            event.currentTarget.classList.add('pdf-preview');
        }else if(action == 'close'){
            this.template.querySelector('.pdf-preview').classList.remove('pdf-preview');
            event.stopPropagation()
        }
    }

// Emoji Support
    generateEmojiCategories() {
        try{
            loadScript(this, EMOJI_LIB + '/emojiData.js')
                .then(() => {
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

    handleEmojiButtonClick(){
        try {
            this.showEmojiPicker = !this.showEmojiPicker;
            this.closeAllPopups();
            this.template.host.style.setProperty("--height-for-emoji",this.showEmojiPicker ? "20rem" : "0rem");
            if(this.showEmojiPicker){
                this.template.querySelector('.emoji-picker-div').scrollTop = 0;
            }
        } catch (e) {
            console.error('Error in function handleEmojiButtonClick:::', e.message);
        }
    }

    handleEmojiClick(event){
        try {
            let textareaMessageElement = this.template.querySelector('.message-input');
            let textareaMessage = textareaMessageElement.value;
            let curPos = textareaMessageElement.selectionStart;
            textareaMessageElement.value = textareaMessage.slice(0, curPos) + event.target.innerText + textareaMessage.slice(curPos);
            textareaMessageElement.focus();
            textareaMessageElement.setSelectionRange(curPos + event.target.innerText.length,curPos + event.target.innerText.length); 
        } catch (e) {
            console.error('Error in function handleEmojiClick:::', e.message);
        }
    }
    handleMessageTextChange(event) {
        try {
            let isMobileDevice = /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent); 
            let textareaMessageElement = this.template.querySelector('.message-input');
            if (!isMobileDevice && event.key === 'Enter') {
                if (event.shiftKey || event.ctrlKey || event.altKey || event.metaKey) {
                    return;
                }
                event.preventDefault();
                this.handleSendMessage();
                textareaMessageElement.blur();
                return;
            }
            textareaMessageElement.style.height = 'auto';
            textareaMessageElement.style.height = `${textareaMessageElement.scrollHeight}px`;
            this.showAttachmentOptions = false;
            this.template.host.style.setProperty("--max-height-for-attachment-options","0rem");
        } catch (e) {
            console.error('Error in function handleMessageTextChange:::', e.message);
        }
    }
    
// Attachments Support
    handleAttachmentButtonClick(){
        try {
            this.showAttachmentOptions = !this.showAttachmentOptions;
            this.closeAllPopups();
            this.template.host.style.setProperty("--max-height-for-attachment-options",this.showAttachmentOptions ? "13rem" : "0rem");
        } catch (e) {
            console.error('Error in function handleAttachmentButtonClick:::', e.message);
        }
    }

    handleAttachmentOptionClick(event) {
        try {
            let mediaType = event.target.dataset.media;
            this.checkLastMessage();
            if(this.sendOnlyTemplate && mediaType != 'Template'){
                this.showMessageToast(`Cannot send ${mediaType}!`, 'You don\'t have any response from contact in last 24 hours.', 'info');
                return;
            }
            
            switch (mediaType) {
                case 'Template':
                    this.showTemplatePreview = false;
                    this.showTemplateSelection = true;
                    this.replyToMessage = null;
                    break;
                case 'Image':
                    this.showFileUploader = true;
                    this.acceptedFormats = ['.jpg', '.png', '.jpeg', '.jpe'];
                    this.uploadFileType = 'Image';
                    break;
                case 'Document':
                    this.showFileUploader = true;
                    this.acceptedFormats = ['.txt', '.xls', '.xlsx', '.doc', '.docx', '.ppt', '.pptx', '.pdf'];
                    this.uploadFileType = 'Document';
                    break;
                case 'Video':
                    this.showFileUploader = true;
                    this.acceptedFormats = ['.3gp', '.mp4'];
                    this.uploadFileType = 'Video';
                    break;
                case 'Audio':
                    this.showFileUploader = true;
                    this.acceptedFormats = ['.aac', '.amr', '.mp3', '.m4a', '.ogg'];
                    this.uploadFileType = 'Audio';
                    break;
                default:
                    this.showMessageToast('Something went wrong!', 'Could not process request, please try again.', 'error');
                    break;
            }
            this.closeAllPopups();
        } catch (e) {
            console.error('Error in function handleAttachmentOptionClick:::', e.message);
        }
    }

    handleUploadFinished(event){
        this.showSpinner = true;
        try {
            if(!(event.detail.files.length > 0)){
                this.handleBackDropClick();
                this.showSpinner = false;
                return;
            }
            var messageType = '';
            if(event.detail.files[0].mimeType.includes('image/')){
                messageType = 'Image';
            } else if (event.detail.files[0].mimeType.includes('application/') || event.detail.files[0].mimeType.includes('text/')){
                messageType = 'Document';
            } else if (event.detail.files[0].mimeType.includes('audio/')){
                messageType = 'Audio';
            } else if(event.detail.files[0].mimeType.includes('video/')){
                messageType = 'Video';
            }
            createChat({chatData: {message: event.detail.files[0].contentVersionId, templateId: this.selectedTemplate, messageType: messageType, recordId: this.recordId, replyToChatId: this.replyToMessage?.Id || null, phoneNumber: this.phoneNumber}})
            .then(chat => {
                if(chat){
                    this.chats.push(chat);
                    this.processChats(true);
                    
                    let imagePayload = this.createJSONBody(this.phoneNumber, messageType, this.replyToMessage?.WhatsAppMessageId__c || null, {
                        link: chat.Message__c,
                        fileName: event.detail.files[0].name || 'whatsapp file'
                    });
                    sendWhatsappMessage({jsonData: imagePayload, chatId: chat.Id, isReaction: false, reaction: null})
                    .then(result => {
                        if(result.errorMessage == 'METADATA_ERROR'){
                            this.showMessageToast('Something went wrong!', 'Please add/update the configurations for the whatsapp.', 'error');
                        }
                        let resultChat = result.chat;
                        this.chats.find(ch => ch.Id === chat.Id).Message_Status__c = resultChat.Message_Status__c;
                        this.chats.find(ch => ch.Id === chat.Id).WhatsAppMessageId__c = resultChat?.WhatsAppMessageId__c;
                        this.messageText = '';
                        this.template.querySelector('.message-input').value = '';
                        this.replyToMessage = null;
                        this.showSpinner = false;
                        this.processChats(true);
                    })
                    .catch((e) => {
                        this.showSpinner = false;
                        console.error('Error in handleUploadFinished > sendWhatsappMessage :: ', e);
                    })
                    this.handleBackDropClick();
                }else{
                    this.showSpinner = false;
                    this.showMessageToast('Something went wrong!', 'The photo is not sent, please make sure image size does not exceed 5MB.', 'error');
                    console.error('there was some error sending the message!');
                }
            })
            .catch((e) => {
                this.showSpinner = false;
                this.showMessageToast('Something went wrong!', 'The photo could not be sent, please try again.', 'error');
                console.error('Error in handleUploadFinished > createChat :: ', e);
            })
            this.uploadFileType = null;
            this.showFileUploader = false;
            this.acceptedFormats = [];
        } catch (e) {
            this.showSpinner = false;
            this.showMessageToast('Something went wrong!', 'The photo could not be sent, please try again.', 'error');
            console.error('Error in function handleUploadFinished:::', e.message);
        }
    }

    handleDocError(event){
        event.target.onerror=null; 
        event.target.src = this.NoPreviewAvailable;
    }
    
    handleImageError(event){
        try {
            event.currentTarget.src = "/resource/Alt_Image";
            event.currentTarget.parentNode.classList.add('not-loaded-image');
        } catch (e) {
            console.error('Error in function handleImageError:::', e.message);
        }
    }

    handleSearchTemplate(event){
        try {
            this.templateSearchKey = event.target.value || null;
        } catch (e) {
            console.error('Error in function handleSearchTemplate:::', e.message);
        }
    }

    handleShowTemplatePreview(event){
        try {
            if(event.currentTarget.dataset.id){
                this.selectedTemplate = event.currentTarget.dataset.id;
                this.showTemplateSelection = false;
                this.showTemplatePreview = true;
            }
        } catch (e) {
            console.error('Error in function handleShowTemplatePreview:::', e.message);
        }
    }

    handleBackToList(){
        try {
            this.selectedTemplate = null;
            this.showTemplatePreview = false;
            this.showTemplateSelection = true;
        } catch (e) {
            console.error('Error in function handleBackToList:::', e.message);
        }
    }

    handleTemplateSent(event){
        try {
            this.showTemplateSelection = false;
            if(event.detail.errorMessage == 'METADATA_ERROR') this.showMessageToast('Something went wrong!', 'Please add/update the configurations for the whatsapp.', 'error');
            let chat = event.detail.chat;
            this.chats.push(chat);
            this.handleBackDropClick();
            this.showSpinner = false;
            this.processChats(true);
        } catch (e) {
            console.error('Error in function handleTemplateSent:::', e.message);
        }
    }

    createJSONBody(to, type, replyId, data){
        try {
                let payload = `{ "messaging_product": "whatsapp", 
                                "to": "${to}",
                                "type": "${type}"`;
                if(replyId) payload += `, "context": {"message_id": "${replyId}"}`;
            
                if (type === "text") {
                    payload += `, "text": { "body": "${data.textBody.replace(/\n/g, "\\n")}" }`;
                } else if (type === "Image") {
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(data.link, "text/html");
                    payload += `, "image": { "link": "${doc.documentElement.textContent}" } `;
                }
                else if (type === "Video") {
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(data.link, "text/html");
                    payload += `, "video": { "link": "${doc.documentElement.textContent}" } `;
                }
                else if (type === "Document") {
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(data.link, "text/html");
                    payload += `, "document": { "link": "${doc.documentElement.textContent}", "filename": "${data.fileName}" } `;
                } else if (type === "Audio") {
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(data.link, "text/html");
                    payload += `, "audio": { "link": "${doc.documentElement.textContent}" } `;
                } else if (type === "reaction"){
                    payload += `, "reaction": { 
                        "message_id": "${data.reactToId}",
                        "emoji": "${data.emoji}"
                        }`;
                }
                payload += ` }`;
                
                return payload;
        } catch (e) {
            console.error('Error in function createJSONBody:::', e.message);
        }
    }

// Sending the message
    // handleOpenSendOptions(){
    //     try {
    //         this.showSendOptions = ! this.showSendOptions;
    //         this.closeAllPopups();
    //         this.template.host.style.setProperty("--max-height-for-send-options",this.showSendOptions ? "7rem" : "0rem");
    //     } catch (e) {
    //         console.error('Error in function handleOpenSendOptions:::', e.message);
    //     }
    // }

    updateMessageReaction(chat){
        // this.showSpinner = true;
        try {
            updateReaction({chatId: chat.Id, reaction:chat.Reaction__c})
            .then(ch => {
                // this.showSpinner = false;
                this.processChats();
                let reactPayload = this.createJSONBody(this.phoneNumber, "reaction", this.replyToMessage?.WhatsAppMessageId__c || null, {
                    reactToId : chat.WhatsAppMessageId__c,
                    emoji: chat.Reaction__c?.split('<|USER|>')[0]
                });
                console.error('ReactPayload :: ', reactPayload);
                
                sendWhatsappMessage({jsonData: reactPayload, chatId: chat.Id, isReaction: true, reaction: chat.Reaction__c})
                .then(result => {
                    if(result.errorMessage == 'METADATA_ERROR'){
                        this.showMessageToast('Something went wrong!', 'Please add/update the configurations for the whatsapp.', 'error');
                    }

                    let resultChat = result.chat;
                    this.chats.find(ch => ch.Id === chat.Id).Reaction__c = resultChat.Reaction__c;
                    this.processChats();
                })
                .catch((e) => {
                    // this.showSpinner = false;
                    console.error('Error in updateMessageReaction > sendWhatsappMessage :: ', e);
                })
            })
            .catch((e) => {
                // this.showSpinner = false;
                this.showMessageToast('Something went wrong!', 'The reaction could not be updated, please try again.', 'error');
                console.error('Error in updateMessageReaction > updateReaction :: ', e);
            })
        } catch (e) {
            // this.showSpinner = false;
            this.showMessageToast('Something went wrong!', 'The reaction could not be updated, please try again.', 'error');
            console.error('Error in function updateMessageReaction:::', e.message);
        }
    }

    handleSendMessage(){
        this.showSpinner = true;
        try {
            this.handleBackDropClick();
            this.template.querySelector('.dropdown-menu')?.classList?.add('hidden');
            this.messageText = this.template.querySelector('.message-input').value;
            this.checkLastMessage();
            if(this.sendOnlyTemplate){
                this.showMessageToast('Cannot send text message!', 'You don\'t have any response from this contact in last 24 hours.', 'info');
                return;
            }
            if(this.messageText.trim().length < 1){
                this.showMessageToast('Something went wrong!', 'Please enter a message to send.', 'error');
                this.showSpinner = false;
                return;
            }
            if(this.sendOnlyTemplate){
                this.showMessageToast('Cannot send text message.', 'You don\'t have any message from this contact since last 24 hours.', 'info');
                this.showSpinner = false;
                return;
            }
            createChat({chatData: {message: this.messageText, templateId: this.selectedTemplate, messageType: 'text', recordId: this.recordId, replyToChatId: this.replyToMessage?.Id || null, phoneNumber: this.phoneNumber}})
            .then(chat => {
                if(chat){
                    let textPayload = this.createJSONBody(this.phoneNumber, "text", this.replyToMessage?.WhatsAppMessageId__c || null, {
                        textBody: this.messageText
                    });
                    let textareaMessageElement = this.template.querySelector('.message-input');
                    this.chats.push(chat);
                    this.showSpinner = false;
                    this.messageText = '';
                    this.replyToMessage = null;
                    this.processChats(true);
                    textareaMessageElement.value = '';
                    textareaMessageElement.style.height = 'auto';
                    textareaMessageElement.style.height = `${textareaMessageElement.scrollHeight}px`;

                    sendWhatsappMessage({jsonData: textPayload, chatId: chat.Id, isReaction: false, reaction: null})
                    .then(result => {
                        if(result.errorMessage == 'METADATA_ERROR'){
                            this.showMessageToast('Something went wrong!', 'Please add/update the configurations for the whatsapp.', 'error');
                        }
                        let resultChat = result.chat;
                        this.chats.find(ch => ch.Id === chat.Id).Message_Status__c = resultChat.Message_Status__c;
                        this.chats.find(ch => ch.Id === chat.Id).WhatsAppMessageId__c = resultChat?.WhatsAppMessageId__c;
                        this.showSpinner = false;
                        this.processChats();
                    })
                    .catch((e) => {
                        this.showSpinner = false;
                        console.error('Error in handleSendMessage > sendWhatsappMessage :: ', e);
                    })
                }else{
                    this.showSpinner = false;
                    this.showMessageToast('Something went wrong!', 'Message could not be sent, please try again.', 'error');
                    console.error('there was some error sending the message!');
                }
            })
            .catch((e) => {
                this.showMessageToast('Something went wrong!', (e.body.message == 'STORAGE_LIMIT_EXCEEDED' ? 'Storage Limit Exceeded, please free up space and try again.' : 'Message could not be sent, please try again.'), 'error');
                this.showSpinner = false;
                console.error('Error in handleSendMessage > createChat :: ', e);
            })
        } catch (e) {
            this.showSpinner = false;
            this.showMessageToast('Something went wrong!', 'Message could not be sent, please try again.', 'error');
            console.error('Error in handleSendMessage:::', e.message);
        }
    }

    getS3ConfigDataAsync() {
        try {
            getS3ConfigSettings()
                .then(result => {
                    console.log('result--> ', result);
                    if (result != null) {
                        this.confData = result;
                        this.isAWSEnabled = true;
                    }
                }).catch(error => {
                    console.error('error in apex -> ', error.stack);
                });
        } catch (error) {
            console.error('error in getS3ConfigDataAsync -> ', error.stack);
        }
    }

    async handleSelectedFiles(event) {
        try {
            const file = event.target.files[0];
            if (file) {
                let fileType = file.type;
                let fileSizeMB = Math.floor(file.size / (1024 * 1024));
                let isValid = false;
                let maxSize = 0;
                console.log(fileType, fileSizeMB);
    
                if (fileType.includes('image/')) {
                    maxSize = 5;
                    isValid = fileSizeMB <= maxSize;
                } else if (fileType.includes('video/') || fileType.includes('audio/')) {
                    maxSize = 16;
                    isValid = fileSizeMB <= maxSize;
                } else if (fileType.includes('application/') || fileType.includes('text/')) {
                    maxSize = 100;
                    isValid = fileSizeMB <= maxSize;
                }
    
                if (isValid) {
                    this.selectedFilesToUpload.push(file);
                    this.selectedFileName = file.name;
                } else {
                    this.showMessageToast('Error', `${file.name} exceeds the ${maxSize}MB limit`, 'error');
                }
            }
        } catch (error) {
            console.error('Error in file upload:', error);
        }
    }

    removeFile() {
        this.selectedFileName = null;
        this.selectedFilesToUpload = [];
        this.template.querySelector('input[type="file"]').value = null;
    }

    async handleUploadClick(){
        if(this.selectedFilesToUpload.length > 0){
            this.showSpinner = true;
            await this.uploadToAWS(this.selectedFilesToUpload);
        }
    }

    async uploadToAWS() {
        try {
            this.showSpinner = true;
            this.initializeAwsSdk(this.confData);
            console.log(this.selectedFilesToUpload);
            const uploadPromises = this.selectedFilesToUpload.map(async (file) => {
                this.showSpinner = true;
                let objKey = this.renameFileName(this.selectedFileName);

                let params = {
                    Key: objKey,
                    ContentType: file.type,
                    Body: file,
                    ACL: "public-read"
                };

                let upload = this.s3.upload(params);

                return await upload.promise();
            });
            console.log(uploadPromises);
            // Wait for all uploads to complete
            const results = await Promise.all(uploadPromises);
            results.forEach((result) => {
                if (result) {
                    console.log({result});
                    let bucketName = this.confData.S3_Bucket_Name__c;
                    let objKey = result.Key;
                    let awsFileUrl = `https://${bucketName}.s3.amazonaws.com/${objKey}`;

                    var messageType = '';
                    if(this.selectedFilesToUpload[0].type.includes('image/')){
                        messageType = 'Image';
                    } else if (this.selectedFilesToUpload[0].type.includes('application/') || this.selectedFilesToUpload[0].type.includes('text/')){
                        messageType = 'Document';
                    } else if (this.selectedFilesToUpload[0].type.includes('audio/')){
                        messageType = 'Audio';
                    } else if(this.selectedFilesToUpload[0].type.includes('video/')){
                        messageType = 'Video';
                    }
                    createChatForAWSFiles({chatData: {message: awsFileUrl, fileName: objKey, mimeType: this.selectedFilesToUpload[0].type, messageType: messageType, recordId: this.recordId, replyToChatId: this.replyToMessage?.Id || null, phoneNumber: this.phoneNumber}})
                        .then(chat => {
                            if(chat){
                                this.chats.push(chat);
                                this.processChats(true);
                                
                                let imagePayload = this.createJSONBody(this.phoneNumber, messageType, this.replyToMessage?.WhatsAppMessageId__c || null, {
                                    link: chat.Message__c,
                                    fileName: objKey || 'whatsapp file'
                                });
                                sendWhatsappMessage({jsonData: imagePayload, chatId: chat.Id, isReaction: false, reaction: null})
                                    .then(result => {
                                        if(result.errorMessage == 'METADATA_ERROR'){
                                            this.showMessageToast('Something went wrong!', 'Please add/update the configurations for the whatsapp.', 'error');
                                        }
                                        let resultChat = result.chat;
                                        this.chats.find(ch => ch.Id === chat.Id).Message_Status__c = resultChat.Message_Status__c;
                                        this.chats.find(ch => ch.Id === chat.Id).WhatsAppMessageId__c = resultChat?.WhatsAppMessageId__c;
                                        this.messageText = '';
                                        this.template.querySelector('.message-input').value = '';
                                        this.replyToMessage = null;
                                        this.showSpinner = false;
                                        this.processChats(true);
                                    })
                                    .catch((e) => {
                                        this.showSpinner = false;
                                        console.error('Error in handleUploadFinished > sendWhatsappMessage :: ', e);
                                    })
                                this.handleBackDropClick();
                            }else{
                                this.showSpinner = false;
                                this.showMessageToast('Something went wrong!', 'The photo is not sent, please make sure image size does not exceed 5MB.', 'error');
                                console.error('there was some error sending the message!');
                            }
                        })
                        .catch((e) => {
                            this.showSpinner = false;
                            this.showMessageToast('Something went wrong!', 'The photo could not be sent, please try again.', 'error');
                            console.error('Error in handleUploadFinished > createChat :: ', e);
                        })
                    this.uploadFileType = null;
                    this.showFileUploader = false;
                    this.acceptedFormats = [];
                    this.removeFile();
                }
            });

        } catch (error) {
            this.showSpinner = false;
            console.error("Error in uploadToAWS: ", error);
        }
    }

    initializeAwsSdk(confData) {
        try {
            let AWS = window.AWS;

            AWS.config.update({
                accessKeyId: confData.AWS_Access_Key__c,
                secretAccessKey: confData.AWS_Secret_Access_Key__c
            });

            AWS.config.region = confData.S3_Region_Name__c;

            this.s3 = new AWS.S3({
                apiVersion: "2006-03-01",
                params: {
                    Bucket: confData.S3_Bucket_Name__c
                }
            });

        } catch (error) {
            console.error("error initializeAwsSdk ", error);
        }
    }

    renameFileName(filename) {
        try {
            let originalFileName = filename;
            let extensionIndex = originalFileName.lastIndexOf('.');
            let baseFileName = originalFileName.substring(0, extensionIndex);
            let extension = originalFileName.substring(extensionIndex + 1);
            
            let objKey = `${baseFileName}.${extension}`
                .replace(/\s+/g, "_");
            return objKey;
        } catch (error) {
            console.error('error in renameFileName -> ', error.stack);            
        }
    }

    async downloadRowImage(event) {
        try {
            const fileName = event.currentTarget.dataset.name;
            const vfPageUrl = `/apex/FileDownloadVFPage?fileName=${encodeURIComponent(fileName)}`;
            window.open(vfPageUrl, '_blank');
        } catch (error) {
            this.showSpinner = false;
            console.error('Error downloading file:', error.stack);
        }
    }

    getMimeType(fileName) {
        const extension = fileName.split('.').pop().toLowerCase();
        const mimeTypes = {
            pdf: 'application/pdf',
            doc: 'application/msword',
            docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            ppt: 'application/vnd.ms-powerpoint',
            pptx: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            xls: 'application/vnd.ms-excel',
            xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            txt: 'text/plain'
        };
        return mimeTypes[extension] || 'application/octet-stream';
    }

    downloadBlob(blob, fileName) {
        try {
            const blobUrl = window.URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = blobUrl;
            link.download = fileName;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            window.URL.revokeObjectURL(blobUrl);
            this.showSpinner = false;
        } catch (error) {
            console.error('error in downloadBlob : ' , error);
        }
    }

    showMessageToast(title, message, status){
        const messageContainer = this.template.querySelector('c-message-popup')
        messageContainer?.showMessageToast({
            status: status,
            title: title,
            message : message
        });
    }

    disconnectedCallback() {
        // Clear the interval when component is removed
        clearInterval(this.intervalId);
    }
}