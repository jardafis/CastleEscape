#!/bin/bash
set -e
set -u

list="SECTION \
	PUBLIC \
	EXTERN \
	MODULE \
	INCLUDE \
	BINARY \
	DB \
	DW \
	DEFC \
	ADC \
	ADD \
	AND \
	BIT \
	CALL \
	CCF \
	CP \
	CPD \
	CPDR \
	CPI \
	CPIR \
	CPL \
	DAA \
	DEC \
	DI \
	DJNZ \
	EI \
	EX \
	EXX \
	HALT \
	IM \
	IN \
	INC \
	IND \
	INDR \
	INI \
	INIR \
	JP \
	JR \
	LD \
	LDD \
	LDDR \
	LDI \
	LDIR \
	NEG \
	NOP \
	OR \
	OTDR \
	OTIR \
	OUT \
	OUTD \
	OUTI \
	POP \
	PUSH \
	RES \
	RET \
	RETI \
	RETN \
	RL \
	RLA \
	RLC \
	RLCA \
	RLD \
	RR \
	RRA \
	RRC \
	RRCA \
	RRD \
	RST \
	SBC \
	SCF \
	SET \
	SLA \
	SSL \
	SL1 \
	SRA \
	SRL \
	SUB \
	XOR \
	HLX \
	PUSHALL \
	POPALL \
	ENTRY \
	EXIT \
	ADDHL \
	ADDDE \
	ADDBC"

for file in $@
do
	echo "Processing $file"
	cp $file $file.bak

	for directive in `echo $list`
	do
		numSpace=$(expr 8 - ${#directive})
		printf -v cmd "s/^\\\s*\\\b${directive}\\\b\\\s*/        ${directive,,}%${numSpace}s/i"
		sed -i -e "${cmd}" $file
	done

	sed -i -e "s/\s*;/;/" $file
	perl -pe 's/^(.+?)(?=;)/$1 . " "x(40-length($1))/e' $file > $file.tmp
	mv -f $file.tmp $file
	sed -i -e "s/^;/        ;/" $file

done

