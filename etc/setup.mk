exe=luajit

L=$(PWD)
B=$L/bin
S=$L/src
D=$L/data
E=$(shell which env)
luas=$(shell cd $S; ls *.lua)
csvs=$(shell cd $D; ls *.csv)


all : dodatas dobins
dobins: 
	@$(foreach f,$(subst .lua,,$(luas)),\
		echo "#!$E $(exe)" > $B/$f;\
		echo "package.path = package.path .. ';../src/?.lua'" >> $B/$f;\
	        echo "require('lib')" >>$B/$f; \
	        echo "main(require('$f'))" >>$B/$f; \
		chmod +x $B/$f; )

dodatas:
	@$(foreach f,$(subst .csv,,$(csvs)),\
		echo "#!$E sh" > $B/$f;\
		echo "cat $D/$f.csv" >> $B/$f;\
		chmod +x $B/$f; )

