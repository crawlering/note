# install squid

	
* adduser squid
* ./configure \
        --prefix=/usr \
        --exec-prefix=/usr \
        --includedir=/usr/include \
        --datadir=/usr/share \
        --libdir=/usr/lib64 \
        --libexecdir=/usr/lib64/squid \
        --localstatedir=/var \
        --sysconfdir=/etc/squid \
        --sharedstatedir=/var/lib \
        --with-logdir=/var/log/squid \
        --with-pidfile=/var/run/squid.pid \
        --with-default-user=squid \
        --enable-silent-rules \
        --enable-dependency-tracking \
        --with-openssl \
        --enable-icmp \
        --enable-delay-pools \
        --enable-useragent-log \
        --enable-esi \
        --enable-follow-x-forwarded-for \
        --enable-auth \
	 --enable-ssl-crtd \
        --disable-arch-native
        --with-openssl    

* cd /etc/squid
mkdir ssl_cert
chown squid:squid ssl_cert
chmod 600 ssl_cert
cd ssl_cert
openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout myCA.pem  -out myCA.pem


* openssl x509 -in myCA.pem -outform DER -out myCA.der
You might determine that your CA should be valid for longer than 1 year.
This .der will be the certificate your client needs to trust
 
* chown root:root /usr/lib64/squid/pinger

* Your squid.conf should look something like this:

```bash
#
# Recommended minimum configuration:
#
 
# Example rule allowing access from your local networks.
# Adapt to list your (internal) IP networks from where browsing
# should be allowed
acl localnet src 10.0.0.0/8	# RFC1918 possible internal network
acl localnet src 172.16.0.0/12	# RFC1918 possible internal network
acl localnet src 192.168.0.0/16	# RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines
acl localnet src 127.0.0.1
 
acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl CONNECT method CONNECT
 
 
sslproxy_cert_error allow all
#disable this in production, it is dangerous but useful for testing
sslproxy_flags DONT_VERIFY_PEER
#
# Recommended minimum Access Permission configuration:
#
# Deny requests to certain unsafe ports
http_access deny !Safe_ports
 
# Deny CONNECT to other than secure SSL ports
http_access deny CONNECT !SSL_ports
 
# Only allow cachemgr access from localhost
http_access allow localhost manager
http_access deny manager
 
# We strongly recommend the following be uncommented to protect innocent
# web applications running on the proxy server who think the only
# one who can access services on "localhost" is a local user
#http_access deny to_localhost
 
#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#
 
# Example rule allowing access from your local networks.
# Adapt localnet in the ACL section to list your (internal) IP networks
# from where browsing should be allowed
http_access allow localnet
http_access allow localhost
 
# And finally deny all other access to this proxy
http_access deny all
 
# Squid normally listens to port 3128
http_port 3128
 
# Uncomment and adjust the following to add a disk cache directory.
#cache_dir ufs /var/cache/squid 100 16 256
 
# Leave coredumps in the first cache dir
coredump_dir /var/cache/squid
 
 
 
http_port x.x.x.x:3129 ssl-bump  \
  cert=/etc/squid/ssl_cert/myCA.pem \
  generate-host-certificates=on dynamic_cert_mem_cache_size=4MB
 
#this is what generates certs on the fly. Point to the CA you generated above.
 
https_port x.x.x.x:3130 ssl-bump intercept \
  cert=/etc/squid/ssl_cert/myCA.pem \
  generate-host-certificates=on dynamic_cert_mem_cache_size=4MB
 
acl step1 at_step SslBump1
 
ssl_bump peek step1
ssl_bump stare all
ssl_bump bump all
always_direct allow all
 
 
#
# Add any of your own refresh_pattern entries above these.
#
refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern ^gopher:	1440	0%	1440
refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
refresh_pattern .		0	20%	4320
```

* Make sure there are no errors in /var/log/squid
sudo netstat -peant | grep ":3130"

* iptables -t nat -I PREROUTING -p tcp --dport y.y.y.y:443 -j DNAT --to x.x.x.x:3130
