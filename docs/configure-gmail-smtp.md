## Install the Required Packages
```
sudo apt update
sudo apt install postfix mailutils
```

## Configure Postfix
During the installation process, you will be prompted to select the configuration type.

Choose "Internet Site" and press Enter.

Enter the fully qualified domain name (FQDN) for your server when prompted. This should be the domain name associated with your server.


## Configure Gmail as the Relay Host
```
sudo vi /etc/postfix/main.cf

relayhost = [smtp.gmail.com]:587
myhostname = <YOUR_HOST_NAME>
```

## Configure Gmail Credentials
1. Enable less secure app for your account

https://myaccount.google.com -> search `"App password"`

Select app: `"Other"`
Select device: `"costOptimzationFramework"`

2. Copy password
xxxxhanrwffhwxfpmlihxxxx


3. Open the Postfix SASL password file
```
sudo vi /etc/postfix/sasl_passwd

[smtp.gmail.com]:587    shehzadshaik91@gmail.com:xxxxhanrwffhwxfpmlihxxxx
```

4. Set the appropriate permissions on the SASL password file
```
sudo chmod 600 /etc/postfix/sasl_passwd
```

5. Generate the Postfix lookup table
```
sudo postmap /etc/postfix/sasl_passwd
```

7. Enable SASL authentication for postfix
```
sudo vi /etc/postfix/main.cf

smtp_tls_security_level = encrypt
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
```

## Restart Postfix
```
sudo systemctl restart postfix
```

## Test the Email Sending
1. Use the `mail` command to send a test email:
```
echo "Test email body" | mail -s "Test Email" shehzadshaikh@live.in
```


2. Send html email using `sendmail`
```
sendmail shehzadshaikh@live.in <<EOF
From: no-reply-cof@rtlab.com
To: shehzadshaikh@live.in
Subject: HTML Format Email
Content-Type: text/html

$(cat ./mail-content.html)
EOF
```