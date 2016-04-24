#!/bin/bash

main() {
	getUpdate
	correctTime
	getTorSoftware
	createInfo
	service tor restart
}

getUpdate(){
	apt-get update
	apt-get upgrade
}

correctTime(){
	apt-get install --yes --force-yes  openntpd ntpdate
	ntpdate -q ntp.ubuntu.com
}

getTorSoftware(){
	DISTRIB_CODENAME=`lsb_release -c -s`
	echo "deb http://deb.torproject.org/torproject.org $DISTRIB_CODENAME main" | sudo tee -a /etc/apt/sources.list.d/torproject.list
	gpg --keyserver keys.gnupg.net --recv 886DDD89
	gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
	apt-cache polycy tor
	apt-get update
	apt-get install --yes tor
	apt-get install --yes --force-yes  deb.torproject.org-keyring
}

createRandomInfo(){
	NICK=`date +%s | sha256sum | base64 | head -c 11 ; echo`
	DOT=`strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 5 | tr -d '\n'; echo`
	COM=`strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 3 | tr -d '\n'; echo`


	echo "Nickname $NICK
	ContactInfo Person <$NICK@$DOT.$COM> 
	ExitPolicy reject *:* # no exits allowed 
	ExitPolicy reject6 *:*

	ORPort 9001
	DirPort 9030
	ExitPolicy reject *:*

	DisableDebuggerAttachment 0
	" > /etc/tor/torrc
}

main "$@"
#https://unindented.org/articles/run-a-tor-relay-on-ubuntu-trusty/
