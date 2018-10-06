ok:
	@cd ..; . etc/ide

eg1:ok; @lib
eg2:ok; @weather | dom
eg3:ok; @weatherLong  | dom
eg4:ok; @auto  | dom

eg4a:; @make eg4 | cut -d, -f 4,5,8,9 | sort -t, -n -k 4  | sed 's/,/,	/g'

eg4best:; @make eg4a | tail
eg4worst:; @make eg4a | head

# curl -R -O http://www.lua.org/ftp/lua-5.3.5.tar.gz
# tar zxf lua-5.3.5.tar.gz
# cd lua-5.3.5
# make linux test
# sudo make install

patch:
	sudo apt-get install libreadline-dev 
	sudo apt-get install bsdutils
