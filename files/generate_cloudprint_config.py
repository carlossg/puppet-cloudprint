#!/usr/bin/python
#
# Copyright 2012 Google Inc. All Rights Reserved.

"""Generate CloudPrint Proxy Config File.

Given a Google Account email and password, generates a config file for the
CloudPrint proxy to use. For instructions on how to use this file, see:
"Install Google Cloud Print on a Linux server"
http://support.google.com/chromeos/a/bin/answer.py?&answer=2616503.
"""

import getpass
import sys
import urllib

__author__ = 'gene@google.com (Gene Gutnik)'

CONFIG_FILE = """{
  "cloud_print": {
    "email": "%s",
    "auth_token": "%s",
    "xmpp_auth_token": "%s",
    "proxy_id": "%s",
    "enabled": true,
    "print_system_settings": {
      "print_server_urls": [
        "%s"
      ]
    }
  }
}
"""

CONFIG_FILE_WO_SERVER = """{
  "cloud_print": {
    "email": "%s",
    "auth_token": "%s",
    "xmpp_auth_token": "%s",
    "proxy_id": "%s",
    "enabled": true
  }
}
"""


def GetAuth(query_params):
  stream = urllib.urlopen('https://www.google.com/accounts/ClientLogin',
                          urllib.urlencode(query_params))

  for line in stream:
    if line.strip().startswith('Auth='):
      return line.strip().replace('Auth=', '')

  return None


if __name__ == '__main__':
  email = None
  password = None
  proxy_id = None
  printserver = None

  if len(sys.argv) >= 5:
    printserver = sys.argv[4]
  if len(sys.argv) >= 4:
    proxy_id = sys.argv[3]
  if len(sys.argv) >= 3:
    password = sys.argv[2]
  if len(sys.argv) >= 2:
    email = sys.argv[1]

  while not email:
    email = raw_input('Email Address: ')

  while not password:
    password = getpass.getpass('Password for %s: ' % email)

  while not proxy_id:
    proxy_id = raw_input('Connector Id: ')

  if not printserver:
    printserver = raw_input('Printserver URL with port (keep empty to skip): ')

  params = {'accountType': 'GOOGLE',
            'Email': email,
            'Passwd': password,
            'service': 'cloudprint',
            'source': 'CP-GenConfig'}

  auth_token = GetAuth(params)
  params['service'] = 'chromiumsync'
  xmpp_auth_token = GetAuth(params)

  filename = proxy_id + '.conf'
  config_file = open(filename, 'w')
  if printserver:
    config_file.write(CONFIG_FILE % (email, auth_token, xmpp_auth_token,
                                     proxy_id, printserver))
  else:
    config_file.write(CONFIG_FILE_WO_SERVER % (email, auth_token,
                                               xmpp_auth_token, proxy_id))
  config_file.close()
  print 'Config file %s generated for proxy %s' % (filename, proxy_id)
