admins = {
   "gabriel@xmpp.partner.codes",
}

modules_enabled = {
   "roster";
   "saslauth";
   "tls";
   "dialback";
   "disco";

   "private"; -- Private XML storage (for room bookmarks, etc.)
   "vcard"; -- Allow users to set vCards

   "legacyauth";
   "version";
   "uptime";
   "time";
   "ping";
   "register";
   "posix";
   "bosh";
   --"console"; -- telnet to port 5582 (needs console_enabled = true)
   --"httpserver"; -- Serve static files from a directory over HTTP
};
log = {
   debug = "/var/log/prosody/prosody.log";
   error = "/var/log/prosody/prosody.err";
}
authentication = "internal_hashed"
allow_registration = true;
consider_bosh_secure = true;
cross_domain_bosh = true;
bosh_max_inactivity = 300; -- 5 minutes
bosh_max_requests = 20;
bosh_default_hold = 5;
daemonize = true;
pidfile = "/var/run/prosody/prosody.pid";

storage = "sql"
sql = {
   driver = "MySQL"; -- May also be "MySQL" or "SQLite3" (case sensitive!)
   database = "{{ prosody_partner_codes_mysql_db }}"; -- The database name to use. For SQLite3 this the database filename (relative to the data storage directory).
   host = "localhost"; -- The address of the database server (delete this line for Postgres)
   port = 3306; -- For databases connecting over TCP
   username = "{{ prosody_partner_codes_mysql_user }}"; -- The username to authenticate to the database
   password = "{{ prosody_partner_codes_mysql_password }}"; -- The password to authenticate to the database
}

bosh_ports = {
   {
      port = 5280;
      path = "http-bind";
   },
   {
      port = 5281;
      path = "http-bind";
      ssl = {
         key = "{{ partner_codes_tls_path }}/certs/xmpp.partner.codes/privkey.pem;";
         certificate = "{{ partner_codes_tls_path }}/certs/xmpp.partner.codes/fullchain.pem;";
      }
   }
}

https_ssl = {
   key = "{{ partner_codes_tls_path }}/certs/xmpp.partner.codes/privkey.pem;";
   certificate = "{{ partner_codes_tls_path }}/certs/xmpp.partner.codes/fullchain.pem;";
}

VirtualHost "xmpp.partner.codes"
-- Assign this host a certificate for TLS, otherwise it would use the one
-- set in the global section (if any).
-- Note that old-style SSL on port 5223 only supports one certificate, and will always
-- use the global one.
ssl = {
   key = "{{ partner_codes_tls_path }}/certs/xmpp.partner.codes/privkey.pem;";
   certificate = "{{ partner_codes_tls_path }}/certs/xmpp.partner.codes/fullchain.pem;";
}

Component "conference.xmpp.partner.codes" "muc"
