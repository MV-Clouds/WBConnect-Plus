import { LightningElement, track, api } from 'lwc';
import logoImg from '@salesforce/resourceUrl/WBConnectplusLogo'; // Logo image
import Login_BG from '@salesforce/resourceUrl/Login_BG'; // Logo image
import LoginIllustrationImg from '@salesforce/resourceUrl/LoginIllustration'; // Logo image
import poweredByMVCImg from '@salesforce/resourceUrl/poweredByMVC'; // Logo image

export default class Wbc_loginpage extends LightningElement {
    @track email;
    @track password;
    @track error;
    @track isLoading = false;

    // Public properties configurable in Experience Builder
    @api startUrl = '/'; // Default redirect location after login
    @api forgotPasswordUrl = '/ForgotPassword'; // Default Forgot Password page URL
    @api selfRegisterUrl = '/SelfRegister'; // Default Self Registration page URL
    logoUrl = logoImg;
    LoginIllustration = LoginIllustrationImg;
    poweredByMVC = poweredByMVCImg
    backgroundStyle = `background-image: url(${Login_BG});`;

    get forgotPasswordUrlComputed() {
        return this.forgotPasswordUrl && this.forgotPasswordUrl.startsWith('/') ? this.forgotPasswordUrl : '/ForgotPassword';
    }

    get selfRegisterUrlComputed() {
        return this.selfRegisterUrl && this.selfRegisterUrl.startsWith('/') ? this.selfRegisterUrl : '/SelfRegister';
    }


    handleEmailChange(event) {
        this.email = event.target.value;
        this.error = undefined;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
        this.error = undefined;
    }

    handleLogin(event) {
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

        login({
            username: this.email,
            password: this.password,
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