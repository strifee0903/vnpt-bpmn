const nodemailer = require('nodemailer');
const { SMTP_MAIL, SMTP_PASSWORD } = process.env;

const sendMail = async (email, mailSubject, content) => {
    try {
        if (!SMTP_MAIL || !SMTP_PASSWORD) {
            throw new Error('SMTP credentials are missing in environment variables');
        }

        const transport = nodemailer.createTransport({
            host: 'smtp.gmail.com',
            port: 587,
            secure: false,
            requireTLS: true,
            auth: {
                user: SMTP_MAIL,
                pass: SMTP_PASSWORD,
            },
        });

        const mailOptions = {
            from: SMTP_MAIL,
            to: email,
            subject: mailSubject,
            html: content,
        };

        const info = await transport.sendMail(mailOptions);
        console.log('Mail sent successfully:- ', info.response);
        return info;
    } catch (error) {
        console.error('Error sending email:', error);
        throw new Error(`Failed to send email: ${error.message}`);
    }
};

module.exports = sendMail;