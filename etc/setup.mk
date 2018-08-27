all : dirs datas bins

B=bin
S=src
D=data
L=$(shell which env)
luas=$(shell cd $S; ls *.lua)
csvs=$(shell cd $D; ls *.csv)

dirs:
	@mkdir -p bin src data

bins: 
	@$(foreach f,$(subst .lua,,$(luas)),\
		echo "#!$L lua" > $B/$f;\
		echo "package.path = package.path .. ';../$S/?.lua'" >> $B/$f;\
	        echo "require('lib')" >>$B/$f; \
	        echo "main(require('$f'))" >>$B/$f; \
		chmod +x $B/$f; )

datas:
	@$(foreach f,$(subst .csv,,$(csvs)),\
		echo "#!$L sh" > $B/$f;\
		echo "cat ../$D/$f.csv" >> $B/$f;\
		chmod +x $B/$f; )

