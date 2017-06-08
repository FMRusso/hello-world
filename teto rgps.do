

cd "C:\Users\b210139945\Desktop\PNAD\Pnad STATA\Sem norte rural"

local anos "2009 2011 2012"
foreach y in `anos' {

use pesdom_`y'_stata_def,clear


** Posição no domicílio
recode v0401 (1=1 "chefe de família") (2=2 "cônjuge") (3=3 "filho") (4/8=4 "outro"), gen(pdom)
gen respons= (pdom==1)
gen conjuge= (pdom==2)
gen filho= (pdom==3)
gen outro= (pdom>3)

bysort domicilioid: egen Nfilhos=total(filho) 

gen teto=.
replace teto=832.66  if ano==1995 
replace teto=957.56  if ano==1996
replace teto=1031.87 if ano==1997
replace teto=1081.50 if ano==1998
replace teto=1255.32 if ano==1999
replace teto=1430.00 if ano==2001  
replace teto=1561.56 if ano==2002
replace teto=1869.34 if ano==2003 
replace teto=2508.72 if ano==2004
replace teto=2668.15 if ano==2005
replace teto=2801.82 if ano==2006   
replace teto=2894.28 if ano==2007 
replace teto=3038.99 if ano==2008
replace teto=3218.90 if ano==2009
replace teto=3691.74 if ano==2011
replace teto=3691.74 if ano==2011
replace teto=3916.20 if ano==2012 


*** Trazendo o valor de salmt para valor corrente

gen salmt_ndef=salmt*def

gen d_acimat=.
replace d_acimat=1 if salmt_ndef>=teto & salmt_ndef<9999999999
replace d_acimat=0 if salmt_ndef<teto

label var educa "anos de estudo"
label var pos_ocup "posição na ocupação"
label var renda2 "renda todas as fontes2"
label var salmp "salário trab principal"
label var salmt "salário todos trabs"
label var d_acimat "salmt acima teto RGPS"
label var teto "teto RGPS"
label var Nfilhos "número de filhos"
label var prev "contribui prev"
label var prev_pri "contribui prev privada"
label var ocup_ibge "dummy ocupação"
label var chefed "chefe do domicílio"
label var def "deflator PNAD 2012"
label var salmt_ndef "salmt valores ano corrente"
label var rdpc "renda domiciliar per capita"


keep uf ano domicilioid peso ocup_ibge pea_ibge prev_pri prev pos_ocup salmt salmt_ndef salmp renda2 rdpc  idade genero cor chefed educa Nfilhos def d_acimat teto v4011 v0402 v4723 v9060 v9122 v9123 v1251 v1254 v1257 v1260  reg1 ativi







	save base_`y'_RGPS
}




append using "C:\Users\b210139945\Desktop\Teto RGPS\base_1996_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_1997_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_1998_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_1999_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2001_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2002_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2003_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2004_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2005_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2006_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2007_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2008_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2009_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2011_RGPS.dta"
append using "C:\Users\b210139945\Desktop\Teto RGPS\base_2012_RGPS.dta"



rename reg1 regiao
rename ativi setor_atividade



** Compatibilizando variáveis de 1995 a 2012

replace v9060=. if v9060==9












