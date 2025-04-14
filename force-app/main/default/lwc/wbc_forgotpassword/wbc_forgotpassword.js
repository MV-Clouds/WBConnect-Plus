import { LightningElement, track, api } from 'lwc';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo';
import Login_BG from '@salesforce/resourceUrl/Login_BG';
import forgotPassIllustrationImg from '@salesforce/resourceUrl/forgotPassIllustration';
import verifyCodeillustrationImg from '@salesforce/resourceUrl/verifyCodeillustration';
import setPasswordIllustrationImg from '@salesforce/resourceUrl/setPasswordIllustration';
import poweredByMVCImg from '@salesforce/resourceUrl/poweredByMVC';
import forgotPassword from '@salesforce/apex/LoginController.forgotPassword';
import { NavigationMixin } from "lightning/navigation";

export default class Wbc_forgotpassword extends NavigationMixin(LightningElement) {
    @track email;
    @track verificationCode;
    @track newpassword;
    @track repassword;
    @track error;
    @track message;
    @track isLoading = false;
    isDisbaled = false;
    isEmailPage = true;
    isVerifyCodePage = false;
    isSetPasswordPage = false;

    @api startUrl = '/login'; // Default redirect location on back to login click
    logoUrl = logoImg;
    forgotPassIllustration = forgotPassIllustrationImg;
    verifyCodeillustration = verifyCodeillustrationImg;
    setPasswordIllustration = setPasswordIllustrationImg;
    poweredByMVC = poweredByMVCImg
    backgroundStyle = `background-image: url(${Login_BG});`;

    handleEmailChange(event) {
        this.email = event.target.value;
        this.error = undefined;
    }

    handleCodeChange(event) {
        this.verificationCode = event.target.value;
        this.error = undefined;
    }

    handleNewPasswordChange(event) {
        this.newpassword = event.target.value;
        this.error = undefined;
    }

    handleRePasswordChange(event) {
        this.repassword = event.target.value;
        this.error = undefined;
    }

    handleSubmit(event) {
        event.preventDefault(); 

        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            this.error = 'Please fill in all required fields.';
            return;
        }

        this.isLoading = true;
        this.isDisbaled = true;
        this.error = undefined;

        forgotPassword({ usernameval: this.email })
            .then(result => {
                console.log(result);
                this.isLoading = false;
                this.isDisbaled = false;
                if (result[0] === 'Success') {
                    this.message = 'You will receive an email with a password reset link. Please check your inbox.';
                    this.error = null; // clear any previous error
                } else if (result[0] === 'Error') {
                    this.error = result[1]; // Show specific error from Apex
                    this.message = null;   // clear success message
                }
            })
            .catch(error => {
                console.error('Forgot Password Error:', error);
                this.error = this.getErrorMessage(error);
                this.isLoading = false;
                this.isDisbaled = false;
            });
    }

    handleVerify(event){
        event.preventDefault(); 

        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            this.error = 'Please fill in all required fields.';
            return;
        }

        this.isLoading = true;
        this.error = undefined;
    }

    handleSetPassword(event){
        event.preventDefault(); 

        let isValid = true;
        this.template.querySelectorAll('lightning-input').forEach(input => {
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        });

        if (!isValid) {
            this.error = 'Please fill in all required fields.';
            return;
        }

        this.isLoading = true;
        this.error = undefined;
    }

    getErrorMessage(error) {
        let message = 'Unknown error';
        
        if (error && error.body && error.body.message) {
            message = error.body.message;
        }
        
        else if (error && error.message) {
            message = error.message;
        } else if (typeof error === 'string') {
            message = error;
        }
        return message;
    }

    navigateToLogin(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Login',
            },
        });
    }
}