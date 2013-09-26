puppet-cloudprint
=================

Puppet module for Google Cloudprint service installation and configuration.

From instructions in Google support [Install Google Cloud Print on a Linux server](http://support.google.com/a/bin/answer.py?hl=en&answer=2906017)


# Usage

    class { 'cloudprint':
      username  => 'johndoe@gmail.com',
      password  => 'mypassword',
      connector => 'my_printer',
      server    => 'http://localhost:631',
    }

* Username: The Google account to which you want to register printers. For enterprises, this is often an account that multiple admins can access rather than a personal account.
* Password: The password for the account above. If the account requires 2-step verification, you may need to enter an application-specific password.
* Connector ID: A unique ID for this Cloud Print Connector instance. For example: googleprinters_mtv_building44.
* Print Server: If you don't have a specific CUPS print server you want to use, leave this field empty and click Enter to use the default print server of the host machine. To use a specific CUPS print server, enter its name in this format: http://printserver.google.com:631. If you need to use multiple CUPS print servers from the same connector, edit the config file manually.
