import { LightningElement, track, api } from 'lwc';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo';
import Login_BG from '@salesforce/resourceUrl/Login_BG';
import forgotPassIllustrationImg from '@salesforce/resourceUrl/forgotPassIllustration';
import verifyCodeillustrationImg from '@salesforce/resourceUrl/verifyCodeillustration';
import setPasswordIllustrationImg from '@salesforce/resourceUrl/setPasswordIllustration';
import poweredByMVCImg from '@salesforce/resourceUrl/poweredByMVC';

export default class Wbc_forgotpassword extends LightningElement {
    @track email;
    @track verificationCode;
    @track newpassword;
    @track repassword;
    @track error;
    @track isLoading = false;
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
        this.error = undefined;

        // Use the startUrl configured in Experience Builder
        const finalStartUrl = this.startUrl && this.startUrl.startsWith('/') ? this.startUrl : '/';

        getVerificationCode({
            username: this.email,
            startUrl: finalStartUrl // Pass the desired relative start URL
        })
        .then(result => {
            console.log('Login successful, redirecting to:', result);
            // Redirect the user using client-side navigation to the relative path
            // window.location.href = result; // This causes full page reload
            // Better: Use relative path navigation if possible
            // If result is null/undefined, maybe default to '/'
            const destinationUrl = result || finalStartUrl;
            window.location.pathname = destinationUrl; // Navigate to relative path

            
        })
        .catch(error => {
            console.error('Login Error:', error);
            this.error = this.getErrorMessage(error);
            this.isLoading = false;
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
}