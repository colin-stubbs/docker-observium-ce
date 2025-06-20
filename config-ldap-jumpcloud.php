<?php

## Check https://docs.observium.org/config_options/ for documentation of possible settings

## It's recommended that settings are edited in the web interface at /settings/ on your observium installation.
## Authentication and Database settings must be hardcoded here because they need to work before you can reach the web-based configuration interface

// Debugging
//define("OBS_DEBUG", "1");

// Database config
// --- This MUST be configured
$config['db_host']      = getenv('OBSERVIUM_DB_HOST');
$config['db_name']      = getenv('OBSERVIUM_DB_NAME');
$config['db_user']      = getenv('OBSERVIUM_DB_USER');
$config['db_pass']      = getenv('OBSERVIUM_DB_PASS');

// Base URL for site
// --- This MUST be configured
$config['base_url'] = getenv('OBSERVIUM_BASE_URL');

// Authentication Model
$config['auth_mechanism'] = "ldap";    // default, other options: ldap, http-auth, please see documentation for config help

// LDAP based auth
$config['auth_ldap_server']  = "ldap.jumpcloud.com";
$config['auth_ldap_starttls'] = "require";
$config['auth_ldap_binddn'] = "uid=svc-ldap,ou=Users,o=CHANGE_ME,dc=jumpcloud,dc=com"; 
$config['auth_ldap_bindpw'] = "CHANGE_ME";
$config['auth_ldap_suffix'] = "ou=Users,o=CHANGE_ME,dc=jumpcloud,dc=com";
$config['auth_ldap_groupbase'] = "ou=Users,o=CHANGE_ME,dc=jumpcloud,dc=com";
$config['auth_ldap_groupmembertype'] = "fulldn";
$config['auth_ldap_groupmemberattr'] = "member";
$config['auth_ldap_groups']['cn=CHANGE_ME,ou=Users,o=CHANGE_ME,dc=jumpcloud,dc=com']['level'] = 10;

// EOF

