***********************************************************
* DISOC-Rio
* Coordenação de mercado de trabalho

* Programa para gerar base para projeto sobre Estigma (baseado no programa do Caxambu)
*
* Data de criação: 15/01/2014
* Data da última alteração: 28/04/2014
* Autor da última alteração: Alessandra Scalioni Brito
**********************************************************;

/*LIBNAME IN1 '\\sbsb2\disoc_rio\Coordenação Trabalho\Base de dados\RAIS\Bases primárias';
LIBNAME IN  '\\sbsb2\disoc_rio\Coordenação Trabalho\Base de dados\RAIS\Bases primárias\Admitidos e desligados';
LIBNAME IN2 '\\sbsb2\disoc_rio\BMT\RAIS\Episódios deslig';
LIBNAME IN3 '\\sbsb2\disoc_rio\Coordenação Trabalho\Base de dados\RAIS\Bases primárias\Ativos'; 
LIBNAME IN7 '\\sbsb2\disoc_rio\BMT\RAIS\Episódios deslig\novo';
LIBNAME IN4 '\\sbsb2\disoc_rio\Coordenação Trabalho\Base de dados\RAIS\Bases primárias\Episódios de desligamento';*/
LIBNAME IN6 '\\sbsb2\disoc_rio\Coordenação Trabalho\Base de dados\RAIS\Bases primárias\Episódios de desligamento\novo';
LIBNAME IN13  '\\sbsb2\disoc_rio\Coordenação Trabalho\Base de dados\RAIS\Bases primárias\vinculos_nasc_morte';
LIBNAME IN5 '\\sbsb2\disoc_rio\BMT\RAIS\Estigma';
LIBNAME IN8 '\\sbsb2\disoc_rio\BMT\RAIS\Estigma\Antigos e Bases Auxiliares';

** colocando o emprego_medio_anual no ano seguinte de empresas que não tinham essa variável (empresas emputadas via nascimento ou morte);
%macro year(A);
data in6.vinculos_emp3&A (keep=o_cnpj emprego_medio_anual); set in13.ciclos_emp&A;
rename cnpj=o_cnpj;
run;
%mend year;
%year(2004);
%year(2003);
%year(2002);
%year(2001);
%year(2000);
%year(1999);
run;

%macro year(A,B); *Merge;
proc sort data=in13.vinculos_emp3&B; by o_cnpj; run;
proc sort data=in6.desligados_final2_&A; by o_cnpj; run;
data in8.desligados_final3&A;
merge in6.desligados_final2_&A (in=A drop=emprego_medio_anual) in6.vinculos_emp3&B (in=B);
by o_cnpj;
if A then output in8.desligados_final3&A;
run;
%mend year;
%year(2005,2004);
%year(2004,2003);
%year(2003,2002);
%year(2002,2001);
%year(2001,2000);
%year(2000,1999);


/*filtros da base primária de 2000 a 2005*************************************************;*/
%macro year(A); *Filtros;
data in8.desligados_final3&A (compress= yes); set IN8.DESLIGADOS_FINAL3&A;
/*só desligados (inclusive aqueles devido à morte da empresa - caso onde o_mes_deslig=0.5)*/
if o_mes_deslig<13; /*a base primária já está com este filtro*/

if o_genero=1; /*só homens*/
if 25<=o_idade1<=60; /*só adultos*/
if o_tipo_vinculo='10' or o_tipo_vinculo='15' or o_tipo_vinculo='20' or o_tipo_vinculo='25'; /*contrato com tempo indeterminado*/
if o_horas>=30; /*mais de 30 horas de jornada*/
if o_subsibge='25' or o_subsibge='24' or o_subsibge='26' then delete; /*tira Agrícola, Adm pública e Outros*/

/*não morreu nem se aposentou*/
if o_causa_desl='0' or o_causa_desl='10' or o_causa_desl='11' or o_causa_desl='12' or o_causa_desl='20' or o_causa_desl='21'
or o_causa_desl='30' or o_causa_desl='31' or o_causa_desl='40' or o_causa_desl='50' or o_causa_desl='99';

if 2011<=o_natjur<=2992; /*empresas com fins lucrativos*/
run;

%mend year;
%year(2005);
%year(2004);
%year(2003);
%year(2002);
%year(2001);
%year(2000);


%macro year(A); *criando variáveis; 
data in8.desligados_final3&A (drop= emp_jan emp_fev emp_mar emp_abr emp_mai emp_jun emp_jul emp_ago emp_set emp_out emp_nov emp_dez same_cnpj o_rem_dez rem_dez_r idade_firma o_idadefirma ind_simples o_simples emp_3112 o_emp3112 reemprego_imediato erro erro2 teste); 
set in8.desligados_final3&A;
/**Variáveis para as tabulações**/
if o_cnpj=cnpj and o_cnpj ne "" and cnpj ne "" then cond_cgc=1; else cond_cgc=0; /*reemprego no mesmo cnpj*/
if o_cbo=cbo and o_cbo ne "" and cbo ne "" then cond_ocup=1; else cond_ocup=0; /*na mesma CBO*/
if o_subsibge=subs_ibge and o_subsibge ne "" and subs_ibge ne "" then cond_setor=1; else cond_setor=0; /*no mesmo setor*/

/*Dummy se desligamento involuntário*/
if (o_causa_desl=10 or o_causa_desl=11 or o_causa_desl=30 or o_causa_desl=31) then o_DESLIG_FIRMA=1; ELSE o_DESLIG_FIRMA=0;
/*Dummy se o desligamento foi por morte verdadeira da firma*/ /*já tem na base primária*/
/*if o_morte_final=1 then deslig_morte=1; else deslig_morte=0; */

/*Tamanho do estabelecimento */
SELECT;
WHEN (0<o_tam<55)                      tam2=1; 
WHEN (55<=o_tam<250)                    tam2=2; 
WHEN (250<=o_tam<1000)                   tam2=3; 
WHEN (1000<=o_tam)    					 tam2=4; 
OTHERWISE                                tam2=.;
END;
if o_mes_deslig=0.5 and 0<emprego_medio_anual<55 then tam2=1;
if o_mes_deslig=0.5 and 55<=emprego_medio_anual<250 then tam2=2;
if o_mes_deslig=0.5 and 250<=emprego_medio_anual<1000 then tam2=3;
if o_mes_deslig=0.5 and 1000<=emprego_medio_anual then tam2=4;

  /*original*/
if 0<o_tam<10 then o_tam_estab=1;
if 10<=o_tam<100 then o_tam_estab=2;
if o_tam>=100 then o_tam_estab=3;

if o_mes_deslig=0.5 and 0<emprego_medio_anual<10 then o_tam_estab=1;
if o_mes_deslig=0.5 and 10<=emprego_medio_anual<100 then o_tam_estab=2;
if o_mes_deslig=0.5 and 100<=emprego_medio_anual then o_tam_estab=3;

  /*reemprego*/
if 0<tam<=9 then tam_estab=1;
if 10<=tam<=99 then tam_estab=2;
if tam>=100 then tam_estab=3;

/*Mudança entre classes de tamanho*/
if o_tam_estab=tam_estab then cond_tam=1; else cond_tam=0; /*reemprego na mesma classe de tamanho do estabelecimento*/

if o_tam_estab=1 and tam_estab=2 then mov12=1; else mov12=0;
if o_tam_estab=1 and tam_estab=3 then mov13=1; else mov13=0;
if o_tam_estab=2 and tam_estab=1 then mov21=1; else mov21=0;
if o_tam_estab=2 and tam_estab=3 then mov23=1; else mov23=0;
if o_tam_estab=3 and tam_estab=1 then mov31=1; else mov31=0;
if o_tam_estab=3 and tam_estab=2 then mov32=1; else mov32=0;

/*Faixa de idade*/

if o_idade1<=39 then f_age=1; 
if 39<o_idade1<=60 then f_age=2;

/*faixa de escolaridade*/
select;
	when (1<=o_grau_instr1<=4)							f_educ=1; /*0 a 7 anos*/
	when (5<=o_grau_instr1<=6)							f_educ=2; /*8 a 10 anos*/
	when (7<=o_grau_instr1<=11)							f_educ=3; /*mais de 10*/
	otherwise;											/*ignorado*/
end;

/*categórica para tempo de emprego*/
select;
	when (o_temp_empr<12)							    f_tempo=1; /*menos de 1 ano*/
	when (12<=o_temp_empr<36)							f_tempo=2; /*1 a 3 anos*/
	when (o_temp_empr>=36)								f_tempo=3; /*3 e mais*/
	otherwise;										
end;

/**Variáveis da regressão**/

/*Diferença de tempo de emprego*/
if mes_adm^=. then d_temp_empr=sum(temp_empr,-o_temp_empr); else d_temp_empr=.; 

/*Reemprego com contrato CLT indeterminado*/
if tipo_vinculo^=. then do;
if tipo_vinculo='10' or tipo_vinculo='15' or tipo_vinculo='20' or tipo_vinculo='25' then clt=1; else clt=0; end;
/*se clt for missing é porque não foi reempregado*/

/*Grau de instrução novo*/
select;
		when (1<=o_grau_instr1<=4)					educa='Até 1º incomp.';
		when (5<=o_grau_instr1<=6)					educa='Até 2º incomp.';
		when (7<=o_grau_instr1<=9)					educa='Até sup. comp.';
		otherwise;
end;


/*Se a pessoa foi reempregada, quantos meses ficou fora da formalidade*/ /*DIF JÁ TEM NA BASE*/
/*if mes_adm^=. and ano2=1 then do; 
 dif=sum(mes_adm,-o_mes_deslig)+12; end;
if mes_adm^=. and ano2^=1 then do;
 dif=sum(mes_adm,-o_mes_deslig); end;
if o_mes_deslig=0.5 then dif=.;
if mes_adm=99 then dif=.; */

/*Dummy se re-emprego no mesmo mês ou mês seguinte*/
if dif^=. then do;
 if dif=0 or dif=1 then r_imediato=1; else r_imediato=0; end;

/*Se a recontratação foi feita em até 1 ano (12 meses)*/
if 0<=dif<=12 then y=1; else y=0; 
if dif=. then y=.;

age=o_idade1;
age2=o_idade1**2;
d_age=(2*age*dif)+dif**2; /*usa?*/
/*ctrl_x_cond_ocup=ctrl*cond_ocup;*/

/*Tempo fora da formalidade*/	
select;
	when(dif=0) 									tff=1; /*Menos de 1 mês*/
	when(dif=1) 									tff=2; /*Até 1 mês*/
	when(dif in (2, 3)) 							tff=3; /*2 a 3 meses*/
	when(dif in (4, 5, 6)) 						    tff=4; /*4 a 6 meses*/
	when(dif in (7, 8, 9, 10, 11)) 					tff=5; /*7 a 11 meses*/
	when(12<=dif<99) 								tff=6; /*12 a 23 meses*/
		otherwise;
	end;

/*Grandes regiões*/
select;
	when (o_uf in ('11', '12', '13', '14', '15', '16', '17'))				gr=1; /*Norte*/
	when (o_uf in ('21', '22', '23', '24', '25', '26', '27', '28', '29'))   gr=2; /*Nordeste*/
	when (o_uf in ('31', '32', '33', '35'))									gr=3; /*Sudeste*/
	when (o_uf in ('41', '42', '43'))										gr=4; /*Sul*/
	when (o_uf in ('50', '51', '52', '53'))									gr=5; /*Centro Oeste*/
		otherwise;
	end;

SELECT;
WHEN (1<=o_subsibge<=13)                        setor=1; /*industria*/
WHEN (o_subsibge=15)                         setor=3; /*construção*/
WHEN (16<=o_subsibge<=17)                    setor=4; /*comercio*/
WHEN (18<=o_subsibge<=23 or o_subsibge=14)  setor=5; /*serviços*/
OTHERWISE                                     setor=.;
END;

if clt=. then nao_reemprego=1; else nao_reemprego=0; * dummy se não foi reempregado;

/*Dummy se reemprego é no mesmo ano*/
if mes_adm^=. and ano2=. then m_ano=1; else m_ano=0;
/*se for reempregado e não for ano2 é porque foi no mesmo ano*/

/*Diferença de salário*/
if rem_med_r^=. then do;
 dif_y=sum(rem_med_r,-o_rem_med); end;

/**Variáveis do modelo OLS**/

/*Logaritmo da renda de re-emprego*/
 if o_rem_med=0 then o_rem_med=0.00000001;
 if rem_med_r=0 then rem_med_r=0.00000001;
if  rem_med_r=. then yt1=.;
	else yt1=log(rem_med_r);
if rem_med_r=. or o_rem_med=. then yt2=.;
	else yt2=log(rem_med_r)-log(o_rem_med);

	/*Logaritmo da renda de pré-desligamento*/
if  o_rem_med=. then yt3=.;
	else yt3=log(o_rem_med);

*Atribuindo uma Descrição para as variáveis novas; /*Caxambu*/
	label
		cond_ocup="Ocupação de re-emprego igual ao de desligamento (2 dígitos)"
		cond_setor="Setor de re-emprego igual ao de desligamento"
		cond_cgc="Estabelecimento de re-emprego igual ao de desligamento"
		cond_tam="Classe de tamanho de re-emprego igual ao de desligamento"
		f_age="Idade"
		f_educ="Grau de instrução"
		f_tempo="Tempo de emprego"
		y="Conseguiu um novo emprego em até um ano"
		educa="Grau de instrução"
		age="Idade"
		age2="Idade ao quadrado"
		gr="Grandes regiões"
		tff="Tempo fora do formal"
		yt1="Log da renda de re-emprego"
		yt2="Variação do log da renda"
		yt3="Log da renda de pre-desligamento";
run;
%mend year;
%year(2005);
%year(2004);
%year(2003);
%year(2002);
%year(2001);
%year(2000);

/*Empilhando todos os anos*/
data in8.estigma_final_novo (compress= yes);
set in8.desligados_final32000 in8.desligados_final32001 in8.desligados_final32002 in8.desligados_final32003
in8.desligados_final32004 in8.desligados_final32005;
run;

/* ACRESCENTANDO NA BASE FINAL O ACOMPANHAMENTO DOS TRABALHADORES DESLIGADOS
ATÉ AQUI TEMOS SOMENTE A OBSERVAÇÃO NO ANO DE DESLIGAMENTO */

*Criando a varivel com pis e o_cnpj concatenados;
%macro desligados(A);
data in8.desligados&A (keep=pis o_cnpj pis_cnpj ano1); set in8.estigma_final_novo;
if ano1=&A;
if o_mes_adm=0;
length pis_cnpj $ 29;
pis_cnpj=catt(of pis o_cnpj);
run;
proc sort data=in8.desligados&A; by pis_cnpj; run;
%mend desligados;
%desligados(2005);
%desligados(2004);
%desligados(2003);
%desligados(2002);
%desligados(2001);

*deixando só as variáveis de interesse e criando pis_cnpj p a base vinculos;
%macro macro2(A);
data in8.vinculos&A (keep= adm_nasc	ANO	ano_adm	causa_desli	cnae4d	cnpj	codemun	cpf	data_adm	DESLIG_MORTE	emp_3112	fx_educ	fx_idade	genero	GRAU_INSTR1	horas_contr	idade1	ind_hir	ind_sep	mes_adm	mes_deslig	nasc_CNPJ	NAT_JUR	pis	rem_dez	rem_dez_r	rem_med_r	rem_media	subs_ibge	temp_empr	tipo_adm	tipo_vinculo	uf	pis_cnpj); set in13.vinculos_nasc_morte_final&A;
length pis_cnpj $ 29;
pis_cnpj=catt(of pis cnpj);
if emp_3112=1;
run;
%mend macro2;
%macro2(2004);
%macro2(2003);
%macro2(2002);
%macro2(2001);
%macro2(2000);

*Acompanhamento dos desligados;
%macro acompanhamento(A,B);
data in8.acompanhamento&A&B;
	merge in8.desligados&A (in=w) in8.vinculos&B (in=q);
	by pis_cnpj;
	if w and q;
run;
data in8.ficam&A&B (keep=pis_cnpj); set in8.acompanhamento&A&B;
if ano_adm<&B;
run;
%mend acompanhamento;
%acompanhamento(2005,2004);
%acompanhamento(2004,2003);
%acompanhamento(2003,2002);
%acompanhamento(2002,2001);
%acompanhamento(2001,2000);

%macro acompanhamento2(A,B,C);
data in8.acompanhamento&A&C;
	merge in8.ficam&A&B (in=w) in8.vinculos&C (in=q);
	by pis_cnpj;
	if w and q;
run;
data in8.ficam&A&C (keep=pis_cnpj); set in8.acompanhamento&A&C;
if ano_adm<&C;
run;
%mend acompanhamento2;
%acompanhamento2(2005,2004,2003);
%acompanhamento2(2004,2003,2002);
%acompanhamento2(2003,2002,2001);
%acompanhamento2(2002,2001,2000);

%macro acompanhamento3(A,B,C,D);
data in8.acompanhamento&A&D;
	merge in8.ficam&A&C (in=w) in8.vinculos&D (in=q);
	by pis_cnpj;
	if w and q;
run;
data in8.ficam&A&D (keep=pis_cnpj); set in8.acompanhamento&A&D;
if ano_adm<&D;
run;
%mend acompanhamento3;
%acompanhamento3(2005,2004,2003,2002);
%acompanhamento3(2004,2003,2002,2001);
%acompanhamento3(2003,2002,2001,2000);

%macro acompanhamento4(A,B,C,D,E);
data in8.acompanhamento&A&E;
	merge in8.ficam&A&D (in=w) in8.vinculos&E (in=q);
	by pis_cnpj;
	if w and q;
run;
data in8.ficam&A&E (keep=pis_cnpj); set in8.acompanhamento&A&E;
if ano_adm<&E;
run;
%mend acompanhamento4;
%acompanhamento4(2005,2004,2003,2002,2001);
%acompanhamento4(2004,2003,2002,2001,2000);

%macro acompanhamento5(A,B,C,D,E,F);
data in8.acompanhamento&A&F;
	merge in8.ficam&A&E (in=w) in8.vinculos&F (in=q);
	by pis_cnpj;
	if w and q;
run;
%mend acompanhamento5;
%acompanhamento5(2005,2004,2003,2002,2001,2000);

%macro anos(A,B);
data in8.acompanhamento&A&b; set in8.acompanhamento&A&B;
ano1=&A;
ano=&B;
run;
%mend anos;
%anos(2005,2004);
%anos(2005,2003);
%anos(2005,2002);
%anos(2005,2001);
%anos(2005,2000);
%anos(2004,2003);
%anos(2004,2002);
%anos(2004,2001);
%anos(2004,2000);
%anos(2003,2002);
%anos(2003,2001);
%anos(2003,2000);
%anos(2002,2001);
%anos(2002,2000);
%anos(2001,2000);

data in8.acompanhamento2005; set in8.acompanhamento20052004 in8.acompanhamento20052003 in8.acompanhamento20052002 in8.acompanhamento20052001 in8.acompanhamento20052000; run;
data in8.acompanhamento2004; set in8.acompanhamento20042003 in8.acompanhamento20042002 in8.acompanhamento20042001 in8.acompanhamento20042000; run;
data in8.acompanhamento2003; set in8.acompanhamento20032002 in8.acompanhamento20032001 in8.acompanhamento20032000; run;
data in8.acompanhamento2002; set in8.acompanhamento20022001 in8.acompanhamento20022000; run;
data in8.acompanhamento2001; set in8.acompanhamento20012000; run;

*Variáveis que iniciam com "a_" são somente para as observações de acompanhamento;
%macro variaveis(A);
data in8.acompanhamento&A (drop=mes_adm mes_deslig emp_3112 original rem_dez_r fx_educ fx_idade rem_media); set in8.acompanhamento&A;

o_mes_adm=mes_adm*1;
o_mes_deslig=mes_deslig*1;

acompanhamento=1;
rename 	
	ano1=a_ano_desligamento
	ano=ano1
	causa_desli=o_causa_desl
	genero=o_genero
	idade1=o_idade1
	rem_med_r=o_rem_med
	subs_ibge=o_subsibge
	temp_empr=o_temp_empr
	tipo_adm=o_tipo_adm
	tipo_vinculo=o_tipo_vinculo
	uf=o_uf;

/*Faixa de idade*/
if o_idade1<=39 then f_age=1; 
if 39<o_idade1<=60 then f_age=2;

/*faixa de escolaridade*/
select;
	when (1<=grau_instr1<=4)							f_educ=1; /*0 a 7 anos*/
	when (5<=grau_instr1<=6)							f_educ=2; /*8 a 10 anos*/
	when (7<=grau_instr1<=11)							f_educ=3; /*mais de 10*/
	otherwise;											/*ignorado*/
end;

/*categórica para tempo de emprego*/
select;
	when (o_temp_empr<12)							    f_tempo=1; /*menos de 1 ano*/
	when (12<=o_temp_empr<36)							f_tempo=2; /*1 a 3 anos*/
	when (o_temp_empr>=36)								f_tempo=3; /*3 e mais*/
	otherwise;										
end;

run;
%mend variaveis;
%variaveis(2005);
%variaveis(2004);
%variaveis(2003);
%variaveis(2002);
%variaveis(2001);


/*data in8.estigma_final_acomp_copia; set in8.estigma_final_acomp; run;*/
data in8.estigma_final_acomp (drop= dif educa genero o_genero grau_instr1 ind_hir ind_sep m_ano mes mes_deslig mes_deslig1 mov12 mov13 mov21 mov23 mov31 mov32 o_mes_adm o_mes_adm2 o_mes_deslig2 tff) ; set in8.estigma_final_novo in8.acompanhamento2005 in8.acompanhamento2004 in8.acompanhamento2003 in8.acompanhamento2002 in8.acompanhamento2001 ; run;
*ano de morte do cnpj;
data in8.mortecnpj (keep=ano1 o_cnpj); set in8.estigma_final_acomp;
if o_morte_cnpj=1;
run;

proc means data=in8.mortecnpj max noprint ;
var ano1;
class o_cnpj;
output out=in8.mortecnpj2 (drop=_FREQ_ _TYPE_)
max=ano_morte_cnpj;
run;
*ano_morte_cnpj=. se empresa não morreu no período observado;

proc sort data=in8.mortecnpj2;by o_cnpj;run;

data in8.estigma_final_acomp2; set in8.estigma_final_acomp; if acompanhamento=1 and o_cnpj=. then o_cnpj=cnpj; run;
proc sort data=in8.estigma_final_acomp2;by o_cnpj;run;
data in8.estigma_final_acomp_morte;
	merge in8.estigma_final_acomp2 in8.mortecnpj2;
	by o_cnpj;
run;


data in8.estigma_final; set in8.estigma_final_acomp_morte;
if acompanhamento=. and ano1=. then delete;

*Tempo_ate_morte: ano de observação até o ano de morte;
tempo_ate_morte=ano_morte_cnpj-ano1;

*tempo_deslig_morte: tempo entre o desligamento e a morte da empresa;
tempo_deslig_morte=tempo_ate_morte;
if acompanhamento=1 then tempo_deslig_morte=ano_morte_cnpj-a_ano_desligamento;

*morte_periodo: dummy se morte entre 2000 e 2005;
if 2000<=ano_morte_cnpj<=2005 then morte_periodo=1;

*desligado_morte: dummy se foi desligado por morte;
if tempo_deslig_morte=0 then desligado_morte=1; else desligado_morte=0;

*amostra;
if ano_morte_cnpj=2003 and tempo_deslig_morte<=3 then amostra=1;
if ano_morte_cnpj=2004 and tempo_deslig_morte<=3 then amostra=2;
if ano_morte_cnpj=2005 and tempo_deslig_morte<=3 then amostra=3;
run;

/*proc freq data=in8.estigma_final; table tempo_deslig_morte ano_morte_cnpj*tempo_deslig_morte;run;

data in8.estigma_final; set in8.estigma_final;
if acompanhamento=1 then o_rem_med=rem_med_r;
run;*/

data in8.estigma_final (compress=yes drop=mes_deslig2 mes_adm2 mes_adm1); set in8.estigma_final; 
*mes_adm é igual a mes_adm2;
*mes_adm1 só tem 0;
*mes_deslig é igual a mes_deslig2;
label 
	amostra="1 se desligado entre 2000 e 2003 de firmas que fecham em 2003, 2 se desligado entre 2000 e 2004 de firmas que fecham em 2004, e 3 para 2005"
	desligado_morte="Dummy se o trabalhador é desligado no ano da morte"
	morte_periodo="Se a empresa morreu entre 2000 e 2005 (acompanhamento recebe 0)"
	tempo_ate_morte="Tempo em anos entre a observação e a morte da empresa"
	ano_morte_cnpj="Ano da morte do cnpj"
	tempo_deslig_morte="Tempo entre o desligamento e a morte da empresa (igual para o mesmo pis_cnpj)"
	clt="Reemprego com contrato CLT indeterminado, se clt for missing é porque não foi reempregado"
	cnae4d="CNAE 4 dígitos"
	cnpj="cnpj da empresa"
	d_age="(2*age*dif)+dif**2"
	d_temp_empr="Diferença de tempo de emprego"
	deslig_morte="Dummy se o desligamento foi por morte verdadeira da firma"
	dif="Se a pessoa foi reempregada, quantos meses ficou fora da formalidade"
	dif_y="Diferença de salário"
	idade1="Idade no reemprego"
	m_ano="dummy se foi reempregado no mesmo ano"
	mov12="Original em uma empresa de tamanho 1 e reemprego em uma empresa de tamanho 2"
	mov13="Original em uma empresa de tamanho 1 e reemprego em uma empresa de tamanho 3"
	mov21="Original em uma empresa de tamanho 2 e reemprego em uma empresa de tamanho 1"
	mov23="Original em uma empresa de tamanho 2 e reemprego em uma empresa de tamanho 3"
	mov31="Original em uma empresa de tamanho 3 e reemprego em uma empresa de tamanho 1"
	mov32="Original em uma empresa de tamanho 3 e reemprego em uma empresa de tamanho 2"
	nao_reemprego="dummy se não foi reempregado"
	o_DESLIG_FIRMA="Dummy se desligamento involuntário"
	o_cnae="CANE da empresa original"
	o_cnpj="CNPJ empresa original"
	o_grau_instr1="Anos de escolaridade no emprego original"
	o_morte_cnpj="Dummmy morte do cnpj original"
	o_nasc_cnpj="Dummmy nascimento do cnpj original"
	o_tam="Tamanho do estabelecimento original"
	o_tam_estab="Tamanho do estabelecimento original: 1 se 0 a 1; 2 se 10 a 99; 3 se >100"
	r_imediato="Dummy se reemprego foi no mesmo mês ou no mês seguinte"
	tam="Tamanho do estabelecimento de reemprego"
	tam_estab="Tamanho do estabelecimento de reemprego: 1 se 0 a 10; 2 se 10 a 99; 3 se >100"
	a_ano_desligamento="Ano de desligamento das observações de acompanhamento"
	ano1="Ano da observação (desligamento) do emprego original"
	ano2="Ano da observação do reemprego"
	emprego_medio_anual="Emprego médio anual do cnpj"
	mes=""
	mes_adm=""
	mes_deslig=""
	mes_deslig1=""
	morte_cnpj="Dummy de morte do cnpj no ano da obsevação"
	o_cnae="Cnae do emprego original"
	o_mes_adm="Mês de admissão do emprego original"
	o_mes_adm2=""
	o_mes_deslig="Mês de desligamento do emprego original"
	o_mes_deslig2=""
	pis_cnpj="Pis e cnpj concatenados"
	reemp_nasc="Dummy reemprego foi por nascimento"
	setor="1 industria, 3 construção, 4 comercio e 5 serviços"
	tam2="Tamanho do estabelecimento original: 1 se o_tam de 0 a 55; 2 se 55 a 205; 3 se 250 a 1000; e 4 se mais de 1000";
run;

/****************************************************************************************************************/
/****************************************** Calculando as estatísticas ******************************************/
/****************************************************************************************************************/

*ITEM i);
ods html body='\\sbsb2\disoc_rio\BMT\RAIS\Estigma\ESTATISTICA1.xls' style=minimal ;

proc means data=in8.estigma_final mean;
var o_rem_med rem_med_r;
where o_deslig_firma=1 and acompanhamento=.; /*desligamento involuntário*/
output out=estigma (drop= _freq_ _type_)
mean=o_rem_med rem_med_r;
run;

proc means data=in8.estigma_final mean;
var o_rem_med rem_med_r;
where o_mes_deslig=0.5 and o_morte_cnpj=1; /*desligamento por fechamento da firma*/
output out=estigma5b (drop= _freq_ _type_)
mean=o_rem_med rem_med_r;
run;

proc freq data=in8.estigma_final;
table f_educ f_age f_tempo setor o_tam_estab gr;
where o_deslig_firma=1; /*desligamento involuntário*/
run;

proc freq data=in8.estigma_final;
table tam2;
where o_deslig_firma=1; /*desligamento involuntário*/
run;

proc freq data=in8.estigma_final;
table f_educ f_age f_tempo setor o_tam_estab gr;
where o_mes_deslig=0.5 and o_morte_cnpj=1; /*desligamento por fechamento da firma*/
run;

proc freq data=in8.estigma_final;
table tam2;
where o_mes_deslig=0.5 and o_morte_cnpj=1; /*desligamento por fechamento da firma*/
run;
proc freq data=in8.estigma_final; table nao_reemprego; where o_deslig_firma=1; run; /*desligamento involuntário*/
proc freq data=in8.estigma_final; table nao_reemprego; where o_mes_deslig=0.5 and o_morte_cnpj=1; run; /*desligamento por fechamento da firma*/

ods html close;

/*ITEM ii)restringir também para estabelecimentos que morrem de 2000 a 2005*/
ods html body='\\sbsb2\disoc_rio\BMT\RAIS\Estigma\ESTATISTICA2.xls' style=minimal ;

proc means data=in8.estigma_final mean;
var o_rem_med rem_med_r ;
where o_deslig_firma=1 and morte_periodo=1; /*desligamento involuntário*/
output out=estigma (drop= _freq_ _type_)
mean=o_rem_med rem_med_r ;
run;

proc means data=in8.estigma_final mean;
var o_rem_med rem_med_r ;
where o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1; /*desligamento por fechamento da firma*/
output out=estigma (drop= _freq_ _type_)
mean=o_rem_med rem_med_r ;
run;


proc freq data=in8.estigma_final;
table f_educ f_age f_tempo setor o_tam_estab gr;
where o_deslig_firma=1 and morte_periodo=1; /*desligamento involuntário*/
run;

proc freq data=in8.estigma_final;
table tam2;
where o_deslig_firma=1 and morte_periodo=1; /*desligamento involuntário*/
run;

proc freq data=in8.estigma_final;
table f_educ f_age f_tempo setor o_tam_estab gr;
where o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1; /*desligamento por fechamento da firma*/
run;

proc freq data=in8.estigma_final;
table tam2;
where o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1; /*desligamento por fechamento da firma*/
run;

proc freq data=in8.estigma_final; table nao_reemprego; where o_deslig_firma=1 and morte_periodo=1; run; /*desligamento involuntário*/
proc freq data=in8.estigma_final; table nao_reemprego; where o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1; run; /*desligamento por fechamento da firma*/

ods html close;

/*ITEM iii)além do filtro anterior, restringir para trabalhadores desligados no ano que os estabelecimentos aparecem pela última
vez (note que o trabalhador desligado em qualquer ano entre 2000 e o ano da última aparição entra no ii, 
mas só entra no iii se for desligado no próprio ano da última aparição)*/

ods html body='\\sbsb2\disoc_rio\BMT\RAIS\Estigma\ESTATISTICA3.xls' style=minimal ;

proc means data=in8.estigma_final mean;
var o_rem_med rem_med_r ;
where o_deslig_firma=1 and morte_periodo=1 and tempo_deslig_morte=0; /*desligamento involuntário*/
output out=estigma (drop= _freq_ _type_)
mean=o_rem_med rem_med_r ;
run;

proc means data=in8.estigma_final mean;
var o_rem_med rem_med_r ;
where o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1 and tempo_deslig_morte=0; /*desligamento por fechamento da firma*/
output out=estigma (drop= _freq_ _type_)
mean=o_rem_med rem_med_r ;
run;


proc freq data=in8.estigma_final;
table f_educ f_age f_tempo setor o_tam_estab gr;
where o_deslig_firma=1 and morte_periodo=1 and tempo_deslig_morte=0; /*desligamento involuntário*/
run;

proc freq data=in8.estigma_final;
table tam2;
where o_deslig_firma=1 and morte_periodo=1 and tempo_deslig_morte=0; /*desligamento involuntário*/
run;

proc freq data=in8.estigma_final;
table f_educ f_age f_tempo setor o_tam_estab gr;
where o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1 and tempo_deslig_morte=0; /*desligamento por fechamento da firma*/
run;

proc freq data=in8.estigma_final;
table tam2;
where o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1 and tempo_deslig_morte=0; /*desligamento por fechamento da firma*/
run;

proc freq data=in8.estigma_final; table nao_reemprego; where o_deslig_firma=1 and morte_periodo=1 and tempo_deslig_morte=0; run; /*desligamento involuntário*/
proc freq data=in8.estigma_final; table nao_reemprego; where o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1 and tempo_deslig_morte=0; run; /*desligamento por fechamento da firma*/

ods html close;

*Item 4 a);
proc sort data=in8.estigma_final; by tempo_deslig_morte; run;
proc means data=in8.estigma_final mean;
var o_rem_med;
class ano_morte_cnpj ano1;
types ano_morte_cnpj*ano1;
by tempo_deslig_morte;
where 1<=amostra<=3;
output out=in8.estatistica4
mean=rem_med;
run;

*Item 4 b);
proc means data=in8.estigma_final mean;
var o_rem_med;
class tempo_deslig_morte tempo_ate_morte;
types tempo_deslig_morte*tempo_ate_morte;
where 1<=amostra<=3;
output out=in8.estatistica4b
mean=rem_med;
run;

*Item 5 a);
proc means data=in8.estigma_final mean;
var o_rem_med;
class tempo_deslig_morte tempo_ate_morte;
types tempo_deslig_morte tempo_ate_morte;
where 1<=amostra<=3;
output out=in8.estatistica5a
mean=rem_med;
run;

*Item 5 b);
proc freq data=in8.estigma_final; table f_educ f_age f_tempo; run;
proc freq data=in8.estigma_final; table f_educ*tempo_ate_morte 		f_age*tempo_ate_morte 		f_tempo*tempo_ate_morte; run;
proc freq data=in8.estigma_final; table f_educ*tempo_deslig_morte 	f_age*tempo_deslig_morte 	f_tempo*tempo_deslig_morte; run;



*Teste para ver os casos a mais dos itens ii) e iii) em relação à programação antiga;
data teste2 ; set in8.estigma_final;
if o_mes_deslig=0.5 and o_morte_cnpj=1 and morte_periodo=1 and tempo_deslig_morte=0; /*desligamento por fechamento da firma*/
run;

data teste3 (keep=pis_cnpj velho); set in8.estigma_final_iii;
length pis_cnpj $ 29;
pis_cnpj=catt(of pis o_cnpj);
velho=1;
run;

proc sort data=teste2; by pis_cnpj;run;
proc sort data=teste3; by pis_cnpj;run;
data in8.testemerge;
merge teste2 teste3;
by pis_cnpj;
run;


proc sort data=in8.estigma_final; by pis_cnpj;run;








